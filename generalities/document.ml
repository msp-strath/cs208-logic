type url = string

type inline =
  | Text of string
  | Strong of inline list
  | Emphasis of inline list
  | Code of string
  | Link of { content : inline list; href : url }

type block =
  | Paragraph of inline list
  | Preformatted of string
  | Monospace of Pretty.document
  | Itemise of block list list
  | Enumerate of block list list
(* FIXME: images, tables *)

type section =
  { title       : string
  ; content     : block list
  ; subsections : section list
  }

type document =
  { title    : string
  ; authors  : string list
  ; preamble : block list
  ; sections : section list
  }

let document ~title ?(authors=[]) ?(preamble=[]) ?(sections=[]) () =
  { title; authors; preamble; sections }

let section ~title ?(content=[]) ?(subsections=[]) () =
  { title; content; subsections }

(* Block level constructor functions. *)
let para inlines = Paragraph inlines

let preformatted text = Preformatted text

let monospace doc = Monospace doc

let itemise items = Itemise items

let enumerate items = Enumerate items

let text s = Text s

let textf fmt = Printf.ksprintf (fun str -> Text str) fmt

module ToPretty = struct

  let rec pretty_of_inline = function
    | Text str ->
       Pretty.break_words str
    | Strong inlines ->
       Pretty.(text "**"
               ^^ pretty_of_inlines inlines
               ^^ text "**")
    | Emphasis inlines ->
       Pretty.(text "*"
               ^^ pretty_of_inlines inlines
               ^^ text "*")
    | Code str ->
       Pretty.(text "`" ^^ break_words str ^^ text "`")
    | Link { content; _ } ->
       pretty_of_inlines content
  and pretty_of_inlines inlines =
    inlines |> List.to_seq |> Seq.map pretty_of_inline |> Pretty.concat

  let rec pretty_of_block = function
    | Paragraph inlines ->
       Pretty.(group (pretty_of_inlines inlines) ^^ break)
    | Monospace doc ->
       Pretty.(nest 4 (text "    " ^^ doc) ^^ break)
    | Preformatted str ->
       Pretty.(nest 4 (text "    "
                       ^^ (str |> Seq_ext.lines |> Seq.map text |> Seq_ext.intersperse break |> concat))
               ^^ break)
    | Itemise items ->
       List.to_seq items
       |> Seq.map (fun blocks ->
              Pretty.(text " - " ^^ align (pretty_of_blocks blocks) ^^ break))
       |> Pretty.concat
    | Enumerate items ->
       List.to_seq items
       |> Seq.zip (Seq.ints 1)
       |> Seq.map (fun (idx, blocks) ->
              Pretty.(textf " %d. " idx ^^ align (pretty_of_blocks blocks)
                      ^^ break))
       |> Pretty.concat
  and pretty_of_blocks blocks =
    List.to_seq blocks
    |> Seq.map pretty_of_block
    |> Seq_ext.intersperse Pretty.break
    |> Pretty.concat

  let rec pretty_of_section depth { title; content; subsections } =
    let open Pretty in
    textf "%s %s" (String.make depth '#') title ^^ break
    ^^ break
    ^^ pretty_of_blocks content
    ^^ break
    ^^ (subsections
        |> List.to_seq
        |> Seq.map (pretty_of_section (depth+1))
        |> Pretty.concat)

  let pretty_of_document { title; preamble; sections; _ } =
    let open Pretty in
    text "# " ^^ text title ^^ break
    ^^ break
    ^^ pretty_of_blocks preamble
    ^^ break
    ^^ (List.to_seq sections
        |> Seq.map (pretty_of_section 2)
        |> Pretty.concat)

end
