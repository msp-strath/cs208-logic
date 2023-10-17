(* Plan:

   1. Given a directory of markdown files
   2. Convert each file to HTML, translating code blocks to appropriate divs
   3. Wrap the output in the right stuff for SimpleCSS, plus the defnsat stuff.
   4. Stick in a thing to load the js_of_ocaml javascript to do the widget(s)

 *)

module Of_Omd = Html_of_omd.Make (Html_static)

let template ~title:title_text ~body:body_html ~script_url =
  let open Html_static in
  html @@
    concat_list [
        head @@
          concat_list [
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
        body @@
          concat_list [
              header (h1 (text title_text));
              main body_html;
              footer (text "Source code for these pages "
                      ^^ a ~attrs:[A.href "https://github.com/bobatkey/interactive-logic-course"]
                           (text "on GitHub")
                      ^^ text ". "
                      ^^ text "Styling provided by "
                      ^^ a ~attrs:[A.href "https://simplecss.org/"]
                           (text "SimpleCSS")
                      ^^ text ".")
            ]
      ]

let code_render ids attributes kind content =
  match kind with
  | "lmt" | "tickbox" | "textbox" | "entrybox"
  | "rules" | "rules-display" | "focused-nd" | "focused-tree" as kind ->
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
     let pikchr_output, pikchr_input =
       Unix.open_process_args "pikchr" [|""; "--svg-only"; "-"|]
     in
     let svg =
       Fun.protect
         ~finally:(fun () -> ignore (Unix.close_process (pikchr_output, pikchr_input)))
         (fun () ->
           Out_channel.output_string pikchr_input content;
           Out_channel.close pikchr_input;
           In_channel.input_all pikchr_output)
     in
     Some (Html_static.raw_text svg)
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
  let html =
    template ~title:"CS208"
      ~script_url:"frontend.bc.js"
      ~body:(Of_Omd.render (code_render ids) doc)
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
