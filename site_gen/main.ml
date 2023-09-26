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
                  A.href "https://cdn.simplecss.org/simple.min.css"
                ];
              link ~attrs:[
                  A.rel "stylesheet";
                  A.href "local.css"
                ];
              title title_text
            ];
        body @@
          concat_list [
              header (h1 (text title_text));
              main body_html;
              footer (text "Using SimpleCSS");
              script ~attrs:[A.src script_url] ""
            ]
      ]

let code_render _attrs kind content =
  match kind with
  | "lmt" ->
     let open Html_static in
     Some (div ~attrs:[ raw_attr "data-widget" "lmt" ] (text content))
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
  | _ ->
     None


let process_file input_dir output_dir filename =
  let input_path = Filename.concat input_dir filename in
  let output_path = Filename.concat output_dir (Filename.chop_extension filename ^ ".html") in
  let doc =
    In_channel.with_open_text input_path
      Omd.of_channel
  in
  let html =
    template ~title:"CS208"
      ~script_url:"lmt.bc.js"
      ~body:(Of_Omd.render code_render doc)
  in
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
