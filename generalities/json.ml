type t =
  | JString of string
  | JBool of bool
  | JInt of int
  | JArray of t list
  | JNull
  | JObject of (string * t) list

module P = struct

  open Pretty

  let comma = text ","
  let parens doc = text "(" ^^ doc ^^ text ")"
  let square_bracket doc = text "[" ^^ doc ^^ text "]"
  let curly_bracket doc = text "{" ^^ doc ^^ text "}"
  let quote x = text "\"" ^^ x ^^ text "\""

  let maybe_flat = group

  let json_escape s =
    let s = Utf8_string.of_string_unsafe s in
    (* FIXME: JString ought to be utf8_string already? *)
    let b = Buffer.create (Utf8_string.byte_length s + 4) in
    let escape_char c =
      if c = Uchar.of_char '"' then Buffer.add_string b "\\\""
      else if c = Uchar.of_char '\\' then Buffer.add_string b "\\\\"
      else if c = Uchar.of_char '\n' then Buffer.add_string b "\\n"
      else if c = Uchar.of_char '\x0c' then Buffer.add_string b "\\f"
      else if c = Uchar.of_char '\t' then Buffer.add_string b "\\t"
      else if c = Uchar.of_char '\r' then Buffer.add_string b "\\r"
      else if c = Uchar.of_char '\b' then Buffer.add_string b "\\b"
      else Buffer.add_utf_8_uchar b c
    in
    Utf8_string.iter escape_char s;
    Buffer.contents b

  let json_string s =
    quote (text (json_escape s))

  let comma_separate pp xs =
    let body =
      List.to_seq xs
      |> Seq.map pp
      |> Seq_ext.intersperse (comma ^^ break)
      |> concat
    in
    maybe_flat (nest 2 (break ^^ body) ^^ break)

  let rec to_document = function
    | JNull ->
       text "null"
    | JString s ->
       json_string s
    | JBool true ->
       text "true"
    | JBool false ->
       text "false"
    | JInt i ->
       textf "%d" i
    | JArray jsons ->
       square_bracket (comma_separate to_document jsons)
    | JObject fields ->
       curly_bracket
         (comma_separate (fun (nm, json) ->
              json_string nm ^^ text ": " ^^ to_document json)
            fields)
end

let rec to_string = function
  | JString str -> Printf.sprintf "%S" str
  | JBool b -> Printf.sprintf "%b" b
  | JInt i -> string_of_int i
  | JArray jsons ->
     "[" ^ String.concat ", " (List.map to_string jsons) ^ "]"
  | JNull -> "null"
  | JObject obj ->
     let field_to_string (nm, json) =
       Printf.sprintf "%S: %s" nm (to_string json)
     in
     "{" ^ String.concat ", " (List.map field_to_string obj) ^ "}"
