open Generalities
open Sexp

let is_unquoted_atom_char = function
  | 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '-' | '_' ->
     true
  | _ ->
     false

let is_bare_atom =
  String.for_all is_unquoted_atom_char

let quote str =
  let b = Buffer.create 128 in
  Buffer.add_string b "\"";
  String.iter
    (function
     | '"'  -> Buffer.add_string b "\\\""
     | '\\' -> Buffer.add_string b "\\\\"
     | '\n' -> Buffer.add_string b "\\n"
     | '\t' -> Buffer.add_string b "\\t"
     | c    -> Buffer.add_char b c)
    str;
  Buffer.add_string b "\"";
  Buffer.contents b

let atom str =
  if is_bare_atom str then
    Pretty.text str
  else
    Pretty.text (quote str)

let list = function
  | [] ->
     Pretty.text "()"
  | [head] ->
     Pretty.(text  "(" ^^ head ^^ text ")")
  | head :: rest ->
     Pretty.(text "(" ^^ nest 1 (head ^^ group (break ^^ (rest |> List.to_seq |> Seq_ext.intersperse break |> concat) ^^ text ")")))

let rec pretty = function
  | Atom atm -> atom atm
  | List sexps -> list (List.map pretty sexps)


let () =
  stdin
  |> Lexing.from_channel
  |> Sexp_reader.of_lexbuf
  |> Seq.map pretty
  |> Seq.iter (fun doc -> Pretty.print doc; print_newline ())
