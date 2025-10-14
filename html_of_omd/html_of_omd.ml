module type HTML = sig
  type 'act t
  type 'act attribute

  val empty : 'act t
  val ( ^^ ) : 'act t -> 'act t -> 'act t
  val concat_map : ('a -> 'act t) -> 'a list -> 'act t
  val text : string -> _ t
  val h1 : ?attrs:'act attribute list -> 'act t -> 'act t
  val h2 : ?attrs:'act attribute list -> 'act t -> 'act t
  val h3 : ?attrs:'act attribute list -> 'act t -> 'act t
  val h4 : ?attrs:'act attribute list -> 'act t -> 'act t
  val h5 : ?attrs:'act attribute list -> 'act t -> 'act t
  val h6 : ?attrs:'act attribute list -> 'act t -> 'act t
  val p : ?attrs:'act attribute list -> 'act t -> 'act t
  val blockquote : ?attrs:'act attribute list -> 'act t -> 'act t
  val hr : ?attrs:'act attribute list -> unit -> 'act t
  val pre : ?attrs:'act attribute list -> 'act t -> 'act t
  val ol : ?attrs:'act attribute list -> 'act t -> 'act t
  val ul : ?attrs:'act attribute list -> 'act t -> 'act t
  val li : ?attrs:'act attribute list -> 'act t -> 'act t
  val dl : ?attrs:'act attribute list -> 'act t -> 'act t
  val dd : ?attrs:'act attribute list -> 'act t -> 'act t
  val dt : ?attrs:'act attribute list -> 'act t -> 'act t
  val em : ?attrs:'act attribute list -> 'act t -> 'act t
  val strong : ?attrs:'act attribute list -> 'act t -> 'act t
  val code : ?attrs:'act attribute list -> 'act t -> 'act t
  val br : ?attrs:'act attribute list -> unit -> 'act t
  val a : ?attrs:'act attribute list -> 'act t -> 'act t
  val img : attrs:'act attribute list -> 'act t
  val table : ?attrs:'act attribute list -> 'act t -> 'act t
  val tbody : ?attrs:'act attribute list -> 'act t -> 'act t
  val thead : ?attrs:'act attribute list -> 'act t -> 'act t
  val tr : ?attrs:'act attribute list -> 'act t -> 'act t
  val td : ?attrs:'act attribute list -> 'act t -> 'act t
  val th : ?attrs:'act attribute list -> 'act t -> 'act t

  module A : sig
    val href : string -> _ attribute
    val title : string -> _ attribute
    val src : string -> _ attribute
    val align : string -> _ attribute
    val alt : string -> _ attribute
    val id : string -> _ attribute
  end
end

let text_of_inline inline =
  let b = Buffer.create 512 in
  let rec render : _ Omd.inline -> unit = function
    | Omd.Concat (_, inlines) -> List.iter render inlines
    | Omd.Text (_, str) | Omd.Code (_, str) -> Buffer.add_string b str
    | Omd.Emph (_, content)
    | Omd.Strong (_, content)
    | Omd.Link (_, { label = content; _ })
    | Omd.Image (_, { label = content; _ }) ->
        render content
    | Omd.Hard_break _ | Omd.Soft_break _ -> Buffer.add_char b ' '
    | Omd.Html (_, _) -> ()
  in
  render inline;
  Buffer.contents b

type section =
  Section of
    { title       : Omd.attributes Omd.inline
    ; id          : string option
    ; subsections : section list
    }

let toc_of_blocks blocks =
  let rec toc level gathered = function
    | [] ->
       List.rev gathered, []
    | Omd.Heading (attrs, hlevel, inlines) :: blocks as all_blocks ->
       if hlevel = level then
         let subsections, blocks = toc (level + 1) [] blocks in
         let id = List.assoc_opt "id" attrs in
         let section = Section { title = inlines; id; subsections } in
         toc level (section :: gathered) blocks
       else if hlevel < level then
         List.rev gathered, all_blocks
       else
         (* Insert a blank section heading to make the nesting work out *)
         let subsections, blocks = toc (level + 1) [] all_blocks in
         let section = Section { title = Omd.Text ([], ""); id = None; subsections } in
         toc level (section :: gathered) blocks
    | (Omd.Paragraph _ | Omd.List _ | Omd.Blockquote _
       | Omd.Thematic_break _ | Omd.Code_block _ | Omd.Html_block _
       | Omd.Definition_list _ | Omd.Table _) :: blocks ->
       toc level gathered blocks
  in
  let sections, _ = toc 1 [] blocks in
  sections

module type CUSTOM = sig
  module Html : HTML

  val raw_html : string -> _ Html.t
  val link_href : string -> string (* Should produce a link for an href *)
  val img_href : string -> string
  val code : self:(Omd.doc -> 'a Html.t) -> attributes:(string * string) list -> kind:string -> string -> 'a Html.t
end

module Make (Html : HTML) (Custom : CUSTOM with module Html = Html) = struct
  let ( ^^ ) = Html.( ^^ )

  let rec of_inline = function
    | Omd.Concat (_attrs, content) ->
       Html.concat_map of_inline content
    | Text (_attrs, content) ->
       Html.text content
    | Emph (_attrs, content) ->
       Html.em (of_inline content)
    | Strong (_attrs, content) ->
       Html.strong (of_inline content)
    | Code (_attrs, content) ->
       (* FIXME: upadte this *)
       Html.code (Html.text content)
    | Hard_break _attrs ->
       Html.br ()
    | Soft_break _attrs ->
       Html.text " "
    | Link (_attrs, { label; destination; title = _ }) ->
          (* FIXME: buttons with Event handlers? *)
          let destination = Custom.link_href destination in
          Html.a ~attrs:[ Html.A.href destination ] (of_inline label)
    | Image (_attrs, { label; destination; title }) ->
       let destination = Custom.img_href destination in
       let attrs = [ Html.A.src destination; Html.A.alt (text_of_inline label) ] in
       let attrs =
         match title with
         | None -> attrs
         | Some title -> Html.A.title title :: attrs
       in
       Html.img ~attrs
    | Html (_attrs, string) ->
      Custom.raw_html string

  let alignment_attributes = function
    | Omd.Default -> []
    | Left -> [ Html.A.align "left" ]
    | Right -> [ Html.A.align "right" ]
    | Centre -> [ Html.A.align "center" ]

  let table_header headers =
    Html.thead
      (Html.tr
         (Html.concat_map
            (fun (header, alignment) ->
              Html.th ~attrs:(alignment_attributes alignment) (of_inline header))
            headers))

  let table_body headers rows =
    Html.tbody
      (Html.concat_map
         (fun row ->
           Html.tr
             (Html.concat_map
                (fun ((_, alignment), cell) ->
                  Html.td ~attrs:(alignment_attributes alignment) (of_inline cell))
                (List.combine headers row)))
         rows)

  let rec of_doc blocks =
    Html.concat_map of_block blocks

  and of_block = function
    | Omd.Paragraph (_attrs, inline) ->
       Html.p (of_inline inline)
    (* FIXME: handle 'start' for numbered lists; and tight vs loose
       spacing. *)
    | List (_attrs, Ordered (_, _), _, items) ->
       Html.ol (Html.concat_map (fun doc -> Html.li (of_doc doc)) items)
    | List (_attrs, Bullet _, _, items) ->
       Html.ul (Html.concat_map (fun doc -> Html.li (of_doc doc)) items)
    | Blockquote (_attrs, doc) -> Html.blockquote (of_doc doc)
    | Thematic_break _attrs ->
       Html.hr ()
    | Heading (attrs, level, content) ->
       (let attrs = match List.assoc_opt "id" attrs with None -> [] | Some name -> [ Html.A.id name ] in
        match level with
        | 1 -> Html.h1 ~attrs (of_inline content)
        | 2 -> Html.h2 ~attrs (of_inline content)
        | 3 -> Html.h3 ~attrs (of_inline content)
        | 4 -> Html.h4 ~attrs (of_inline content)
        | 5 -> Html.h5 ~attrs (of_inline content)
        | 6 -> Html.h6 ~attrs (of_inline content)
        | _ -> Html.p (of_inline content))
    | Code_block (attributes, kind, content) ->
       Custom.code ~self:of_doc ~attributes ~kind content
    | Html_block (_attrs, html_str) ->
       Custom.raw_html html_str
    | Definition_list (_attrs, defns) ->
       Html.dl
         (Html.concat_map
            (fun { Omd.term; defs } ->
              Html.dt (of_inline term)
              ^^ Html.concat_map (fun inlines -> Html.dd (of_inline inlines)) defs)
            defns)
    | Table (_attrs, headers, []) ->
       Html.table (table_header headers)
    | Table (_attrs, headers, rows) ->
       Html.table (table_header headers ^^ table_body headers rows)
end
