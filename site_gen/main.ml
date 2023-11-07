(* Plan:

   1. Given a directory of markdown files
   2. Convert each file to HTML, translating code blocks to appropriate divs
   3. Wrap the output in the right stuff for SimpleCSS, plus the defnsat stuff.
   4. Stick in a thing to load the js_of_ocaml javascript to do the widget(s)

 *)

module Of_Omd = Html_of_omd.Make (Html_static)

let template ~title:title_text ?(sub_title="") ~script_url body_html =
  let open Html_static in
  let (@|) elem elems = elem (concat_list elems) in
  html @| [
      head @| [
        meta ~attrs:[A.charset "utf8"];
        meta ~attrs:[
            A.name "viewport";
            A.content "width=device-width, initial-scale=1.0"
          ];
        link ~attrs:[
            A.rel "stylesheet";
            (* A.href "https://cdn.simplecss.org/simple.min.css" *)
            A.href "simple.min.css"
          ];
        link ~attrs:[
            A.rel "stylesheet";
            A.href "local.css"
          ];
        script ~attrs:[A.src script_url; raw_attr "defer" "yes"] "";
        title title_text
      ];
      body @| [
          header @| [
            h1 (text title_text);
            p (text sub_title);
            nav @| [
                a ~attrs:[A.href "contents.html"] (text "Contents");
                a ~attrs:[A.href "coursework1.html"] (text "Coursework 1");
              ]
          ];
          main body_html;
          footer @| [
              text "Source code for these pages ";
              a ~attrs:[A.href "https://github.com/bobatkey/interactive-logic-course"]
                (text "on GitHub");
              text ". ";
              text "Styling provided by ";
              a ~attrs:[A.href "https://simplecss.org/"]
                (text "SimpleCSS");
              text "."
            ]
        ]
    ]

let code_render renderer ids attributes kind content =
  match kind with
  | "lmt" | "tickbox" | "textbox" | "entrybox" | "selection"
  | "rules" | "rules-display" | "focused-nd"
  | "focused-tree" | "focused-freeentry"
  | "model-checker"
  | "formulaentry" as kind ->
     let open Html_static in
     let id =
       match List.assoc_opt "id" attributes with
       | None -> None
       | Some id when List.mem id !ids ->
          failwith ("Duplicate id: " ^ id)
       | Some id ->
          ids := id :: !ids;
          Some id
     in
     let attrs =
       [ raw_attr "data-widget" kind ]
       @ (match id with Some id -> [ raw_attr "data-key" id ] | None -> [])
     in
     Some (div ~attrs (text content))
  | "youtube" ->
     let identifier = String.trim content in
     let open Html_static in
     Some (iframe
             ~attrs:[
               raw_attr "width" "560";
               raw_attr "height" "315";
               A.src ("https://www.youtube-nocookie.com/embed/" ^ identifier);
               raw_attr "frameborder" "0";
               raw_attr "allow" "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share";
               raw_attr "allowfullscreen" ""
             ]
             empty)
  | "download" ->
     let filename = String.trim content in
     let open Html_static in
     Some (button
             ~attrs:
             [ A.id "download"
             ; raw_attr "data-filename" filename
             ]
             (text "Download"))
  | "pikchr" ->
     (match Opikchr.pikchr ~src:content () with
      | Ok (svg, width, height) ->
         let open Html_static in
         Some (div ~attrs:[
                   A.style (Printf.sprintf "width: %dpx; height: %dpx; margin: auto"
                              width
                              height)
                 ]
                 (raw_text svg))
      | Error html ->
         Some (Html_static.raw_text html))
  | "details" ->
     let open Html_static in
     let title, body =
       match String.index_opt content '\n' with
       | None ->
          None,
          Omd.of_string content
       | Some i ->
          Some (String.sub content 0 i),
          Omd.of_string (String.sub content (i+1) (String.length content - i - 1))
     in
     Some (details
             ((match title with None -> empty | Some t -> summary (text t))
              ^^ renderer body))
  | "formula" ->
     let open Fol_formula in
     (match Formula.of_string content with
      | Ok fmla ->
         let open Html_static in
         Some (div ~attrs:[ A.class_ "displayedformula" ]
                 (text (Formula.to_string fmla)))
      | Error (`Parse err) ->
         (* FIXME: just log the error? *)
         failwith (Parser_util.Driver.string_of_error err))
  | _ ->
     None


let process_file input_dir output_dir filename =
  let input_path = Filename.concat input_dir filename in
  let output_path = Filename.concat output_dir (Filename.chop_extension filename ^ ".html") in
  let doc =
    In_channel.with_open_text input_path
      Omd.of_channel
  in
  let ids = ref [] in
  let rec renderer doc =
    Of_Omd.render (code_render renderer ids) doc
  in
  let html =
    template
      ~title:"CS208 Logic & Algorithms"
      ~sub_title:"Semester 1: Logic"
      ~script_url:"frontend.bc.js"
      (renderer doc)
  in
  Printf.printf "Page: %s; ids: [ %s ]\n" filename (String.concat ", " !ids);
  Out_channel.with_open_text
    output_path
    (fun ch -> Html_static.Render.to_channel ~doctype:true ch html)

let () =
  match Sys.argv with
  | [| _prog_name; input_dir; output_dir |] ->
     let markdown_files =
       Sys.readdir input_dir
       |> Array.to_seq
       |> Seq.filter (fun nm ->
              not (String.starts_with ~prefix:"." nm) &&
                String.ends_with ~suffix:".md" nm)
       |> List.of_seq
     in
     List.iter (process_file input_dir output_dir) markdown_files
  | _ ->
     Printf.eprintf "Usage: %s <input-dir> <output-dir>"
       Sys.argv.(0)
