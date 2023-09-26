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

module Make (Html : HTML) = struct
  let ( ^^ ) = Html.( ^^ )

  let alignment_attributes = function
    | Omd.Default -> []
    | Left -> [ Html.A.align "left" ]
    | Right -> [ Html.A.align "right" ]
    | Centre -> [ Html.A.align "center" ]

  let render ?link_proc ?raw_html code_render blocks =
    let rec of_inline = function
      | Omd.Concat (_attrs, content) -> Html.concat_map of_inline content
      | Text (_attrs, content) -> Html.text content
      | Emph (_attrs, content) -> Html.em (of_inline content)
      | Strong (_attrs, content) -> Html.strong (of_inline content)
      | Code (_attrs, content) -> Html.code (Html.text content)
      | Hard_break _attrs -> Html.br ()
      | Soft_break _attrs -> Html.text " "
      | Link (_attrs, { label; destination; title = _ }) ->
          (* FIXME: buttons with Event handlers? *)
          let destination =
            match link_proc with
            | None -> destination
            | Some proc -> proc `Link destination
          in
          Html.a ~attrs:[ Html.A.href destination ] (of_inline label)
      | Image (_attrs, { label; destination; title }) ->
          let destination =
            match link_proc with
            | None -> destination
            | Some proc -> proc `Img destination
          in
          let attrs =
            [ Html.A.src destination; Html.A.alt (text_of_inline label) ]
          in
          let attrs =
            match title with
            | None -> attrs
            | Some title -> Html.A.title title :: attrs
          in
          Html.img ~attrs
      | Html (_attrs, string) -> (
          match raw_html with
          | None -> Html.text "Raw HTML not supported"
          | Some fn -> fn string)
    in
    let table_header headers =
      let open Html in
      thead
        (tr
           (concat_map
              (fun (header, alignment) ->
                th ~attrs:(alignment_attributes alignment) (of_inline header))
              headers))
    in
    let table_body headers rows =
      let open Html in
      tbody
        (concat_map
           (fun row ->
             tr
               (concat_map
                  (fun ((_, alignment), cell) ->
                    td ~attrs:(alignment_attributes alignment) (of_inline cell))
                  (List.combine headers row)))
           rows)
    in
    let rec of_doc blocks = Html.concat_map of_block blocks
    and of_block = function
      | Omd.Paragraph (_attrs, inline) -> Html.p (of_inline inline)
      (* FIXME: handle 'start' for numbered lists; and tight vs loose
         spacing. *)
      | List (_attrs, Ordered (_, _), _, items) ->
          Html.ol (Html.concat_map (fun doc -> Html.li (of_doc doc)) items)
      | List (_attrs, Bullet _, _, items) ->
          Html.ul (Html.concat_map (fun doc -> Html.li (of_doc doc)) items)
      | Blockquote (_attrs, doc) -> Html.blockquote (of_doc doc)
      | Thematic_break _attrs -> Html.hr ()
      | Heading (_attrs, 1, content) -> Html.h1 (of_inline content)
      | Heading (_attrs, 2, content) -> Html.h2 (of_inline content)
      | Heading (_attrs, 3, content) -> Html.h3 (of_inline content)
      | Heading (_attrs, 4, content) -> Html.h4 (of_inline content)
      | Heading (_attrs, 5, content) -> Html.h5 (of_inline content)
      | Heading (_attrs, 6, content) -> Html.h6 (of_inline content)
      | Heading (_attrs, _, content) -> Html.p (of_inline content)
      | Code_block (attrs, kind, content) -> (
          match code_render attrs kind content with
          | None -> Html.pre (Html.code (Html.text content))
          | Some html -> html)
      | Html_block (_attrs, html_str) -> (
          match raw_html with
          | None -> Html.text "Raw HTML not supported"
          | Some fn -> fn html_str)
      | Definition_list (_attrs, defns) ->
          Html.dl
            (Html.concat_map
               (fun { Omd.term; defs } ->
                 Html.dt (of_inline term)
                 ^^ Html.concat_map (fun inl -> Html.dd (of_inline inl)) defs)
               defns)
      | Table (_attrs, headers, []) -> Html.table (table_header headers)
      | Table (_attrs, headers, rows) ->
          Html.table (table_header headers ^^ table_body headers rows)
    in
    of_doc blocks
end
