(* Plan:

   1. Given a directory of markdown files
   2. Convert each file to HTML, translating code blocks to appropriate divs
   3. Wrap the output in the right stuff for SimpleCSS, plus the defnsat stuff.
   4. Stick in a thing to load the js_of_ocaml javascript to do the widget(s)

 *)

module Html_of_formula = Fol_formula.Formula.Make_HTML_Formatter (Html_static)

let template ~title:title_text ?(sub_title="") ~script_url navigation_html body_html =
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
                a ~attrs:[A.href "index.html"] (text "Contents");
                a ~attrs:[A.href "coursework2025-26.html"] (text "Coursework");
              ]
          ];
          div ~attrs:[ A.class_ "navigation" ] navigation_html;

          main body_html;

          footer @| [
              text "Source code for these pages ";
              a ~attrs:[A.href "https://github.com/msp-strath/cs208-logic"]
                (text "on GitHub");
              text ". ";
              text "Styling provided by ";
              a ~attrs:[A.href "https://simplecss.org/"]
                (text "SimpleCSS");
              text "."
            ]
        ]
    ]

let code_render ~self ~attributes ~kind content = match kind with
  (* FIXME: find a way to synchronise this with frontend.ml, and to
     syntax check the configurations. *)
  | "lmt" | "tickbox" | "textbox" | "entrybox" | "selection"
  | "rules" | "rules-display" | "focused-nd"
  | "focused-tree" | "focused-freeentry"
  | "model-checker"
  | "ask"
  | "hoare"
  | "formulaentry" as kind ->
     let open Html_static in
     let id = List.assoc_opt "id" attributes in
     let attrs =
       [ raw_attr "data-widget" kind ]
       @ (match id with Some id -> [ raw_attr "data-key" id ] | None -> [])
     in
     div ~attrs (text content)
  | "youtube" ->
     let identifier = String.trim content in
     let open Html_static in
     iframe
       ~attrs:[
         raw_attr "width" "560";
         raw_attr "height" "315";
         A.src ("https://www.youtube-nocookie.com/embed/" ^ identifier);
         raw_attr "frameborder" "0";
         raw_attr "allow" "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share";
         raw_attr "allowfullscreen" ""
       ]
       empty
  | "download" ->
     let filename = String.trim content in
     let open Html_static in
     button
       ~attrs:[ A.id "download"
              ; raw_attr "data-filename" filename ]
       (text "Download")
  | "pikchr" ->
     (match Opikchr.pikchr ~src:content () with
      | Ok (svg, width, height) ->
         let open Html_static in
         div
           ~attrs:[
             A.style (Printf.sprintf "width: %dpx; height: %dpx; margin: auto" width height)
           ]
           (raw_text svg)
      | Error html ->
         (* FIXME: ought to abort the processing here? *)
         Html_static.raw_text html)
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
     details
       ((match title with None -> empty | Some t -> summary (text t))
        ^^ self body)
  | "aside" ->
     let open Html_static in
     let body = Omd.of_string content in
     aside (self body)
  | "formula" ->
     let open Fol_formula in
     (match Formula.of_string content with
      | Ok fmla ->
         let open Html_static in
         div ~attrs:[ A.class_ "displayedformula" ]
           (Html_of_formula.html_of_formula fmla)
      | Error (`Parse err) ->
         (* FIXME: just log the error? *)
         failwith (Parser_util.Driver.string_of_error err))
  | "comment" ->
     Html_static.empty
  | "" ->
     Html_static.(pre (code (text content)))
  | tag ->
     failwith ("Unknown block tag: " ^ tag)

module OmdRender =
  Html_of_omd.Make (Html_static)
    (struct
      module Html = Html_static

      open Html

      let raw_html _ = text "RAW HTML NOT SUPPORTED"
      let link_href href = href
      let img_href href = href
      let code = code_render
    end)

(* TODO:

   1. Local link rewriting and checking [MOSTLY DONE]
   2. Check the widget ids for site-uniqueness
      - Determine a schema for the site
   3. More filters:
      - Syntax highlighted formulas [ MOSTLY DONE ]
      - Better ways of displaying proof rules [ COLOURS ARE TOO DIM ON DARK MODE; FONT IS SMALL ]
      - Better tables; incl computed truth tables
 *)

(* FIXME: does not descend into 'aside' and 'details' elements: no way
   to represent nested blocks like these in the Omd format. Maybe
   translate to a better format after reading the file? *)
let rewrite_links ~link ~img : Omd.doc -> Omd.doc =
  let rec rewrite_inline = function
    | Omd.Concat (attrs, inlines) ->
       Omd.Concat (attrs, List.map rewrite_inline inlines)
    | (Omd.Text _ | Omd.Code _ | Omd.Hard_break _ | Omd.Soft_break _ | Omd.Html _) as inline ->
       inline
    | Omd.Emph (attrs, inline) ->
       Omd.Emph (attrs, rewrite_inline inline)
    | Omd.Strong (attrs, inline) ->
       Omd.Strong (attrs, rewrite_inline inline)
    | Omd.Link (attrs, { label; destination; title }) ->
       Omd.Link (attrs,
                 { label = rewrite_inline label
                 ; destination = link destination
                 ; title })
    | Omd.Image (attrs, { label; destination; title }) ->
       Omd.Image (attrs,
                 { label = rewrite_inline label
                 ; destination = img destination
                 ; title })
  and rewrite_block = function
    | Omd.Paragraph (attrs, inline) ->
       Omd.Paragraph (attrs, rewrite_inline inline)
    | Omd.List (attrs, list_type, spacing, items) ->
       Omd.List (attrs, list_type, spacing, List.map rewrite_blocks items)
    | Omd.Blockquote (attrs, blocks) ->
       Omd.Blockquote (attrs, rewrite_blocks blocks)
    | (Omd.Thematic_break _ | Omd.Code_block _ | Omd.Html_block _) as block ->
       block
    | Omd.Heading (attrs, level, inline) ->
       Omd.Heading (attrs, level, rewrite_inline inline)
    | Omd.Definition_list (attrs, defns) ->
       Omd.Definition_list
         (attrs,
          List.map
            (fun { Omd.term; defs } ->
              { Omd.term = rewrite_inline term; defs = List.map rewrite_inline defs })
            defns)
    | Omd.Table (attrs, header, rows) ->
       Omd.Table (attrs,
                  List.map (fun (inline, align) -> (rewrite_inline inline, align)) header,
                  List.map (List.map rewrite_inline) rows)
  and rewrite_blocks blocks =
    List.map rewrite_block blocks
  in
  rewrite_blocks

let rec html_of_toc sections =
  let open Html_static in
  ul (concat_map
        (fun (Html_of_omd.Section { title; id; subsections }) ->
          let title = match id with
            | None ->
               OmdRender.of_inline title
            | Some id ->
               a ~attrs:[ A.href ("#" ^ id) ] (OmdRender.of_inline title)
          in
          li (title ^^ html_of_toc subsections))
        sections)

let ( / ) = Filename.concat

type page =
  { title : string [@warning "-69"]
  ; body  : Omd.doc
  ; toc   : Html_of_omd.section list
  }

let rec find_section_by_id id =
  List.find_map (check_section_by_id id)
and check_section_by_id sought_id = function
  | Html_of_omd.Section { title; id = Some id; subsections = _ } when String.equal id sought_id ->
     Some title
  | Html_of_omd.Section { subsections; _ } ->
      find_section_by_id sought_id subsections

module KeyMap = Map.Make (String)

type site = page KeyMap.t

let rewrite_internal_link site link =
  if String.starts_with ~prefix:"http" link then
    (* assume this is an external link *)
    link
  else if String.starts_with ~prefix:"mailto:" link then
    link
  else
    ((* FIXME: use parser combinators *)
      match String.index_opt link '.' with
      | None ->
         failwith ("No '.' found: " ^ link)
      | Some idx ->
         let key = String.sub link 0 idx in
         let ext, fragment =
           match String.index_from_opt link idx '#' with
           | None ->
              String.sub link idx (String.length link - idx), None
           | Some idx' ->
              String.sub link idx (idx' - idx),
              Some (String.sub link (idx'+1) (String.length link - idx' - 1))
         in
         match ext with
         | ".md" ->
            (match KeyMap.find_opt key site, fragment with
            | None, _ ->
               failwith ("base page not found: " ^ link ^ " : " ^ key)
            | Some _, None ->
               (* FIXME: check the fragment link*)
               key ^ ".html"
            | Some page, Some fragment ->
               (match find_section_by_id fragment page.toc with
               | None ->
                  failwith ("bad fragment in " ^ link)
               | Some _title ->
                  key ^ ".html" ^ "#" ^ fragment))
         | ".pdf" ->
            (* FIXME: do fragment links make sense here? link to individual pages? *)
            link
         | ext ->
            failwith ("unknown internal extension: " ^ link ^ " : " ^ ext))

let is_page_filename nm =
  not (String.starts_with ~prefix:"." nm)
  && Filename.check_suffix nm ".md"

let page_of_omd doc =
  let toc = Html_of_omd.toc_of_blocks doc in
  match toc with
  | [] ->
     { title = ""
     ; body = doc
     ; toc = []
     }
  | Html_of_omd.Section { subsections; title; _ } :: rest ->
     { title = Html_of_omd.text_of_inline title
     ; body  = doc
     ; toc   = subsections @ rest
     }

let read_site input_dir : site =
  input_dir
  |> Sys.readdir
  |> Array.to_seq
  |> Seq.filter is_page_filename
  |> Seq.map (fun filename ->
         let key = Filename.remove_extension filename in
         let doc = In_channel.with_open_text (input_dir / filename) Omd.of_channel in
         key, page_of_omd doc)
  |> KeyMap.of_seq

let write_site output_dir site =
  (* Write out the HTML files *)
  site
  |> KeyMap.to_seq
  |> Seq.iter begin fun (key, page) ->
       let html =
         template
           ~title:"CS208 Logic & Algorithms"
           ~sub_title:"Semester 1: Logic"
           ~script_url:"frontend.bc.js"
           (Html_static.(concat_list [
                             b (text "Contents");
                             html_of_toc page.toc
           ]))
           (OmdRender.of_doc page.body)
       in
       Out_channel.with_open_text
         (output_dir / key ^ ".html")
         (fun ch ->
           Html_static.Render.to_channel ~doctype:true ch html)
       end
(* FIXME: also write out the CSS and JS files, and delete any extra
   files *)

let check_site_links site =
  KeyMap.mapi
    (fun key page ->
      Printf.eprintf "Checking: %s\n" key;
      { page with body = rewrite_links ~link:(rewrite_internal_link site) ~img:Fun.id page.body })
    site

let () =
  match Sys.argv with
  | [| _prog_name; input_dir; output_dir |] ->
     let site = read_site input_dir in
     let site = check_site_links site in
     write_site output_dir site
  | _ ->
     Printf.eprintf "Usage: %s <input-dir> <output-dir>"
       Sys.argv.(0)
