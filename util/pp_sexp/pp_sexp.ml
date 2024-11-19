module Sexp = struct

  let is_unquoted_atom_char = function
    | 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '-' | '_' ->
       true
    | _ ->
       false
(*
  let fold_sexp atom list input =
    let scan_unquoted_atom start =
    let rec scan i =
      if i = String.length input then
        i, String.sub input start (i - start)
      else
        if is_unquoted_atom_char input.[i] then
          scan (i+1)
        else
          i, String.sub input start (i - start)
    in
    scan start
  in
  let scan_quoted_atom start =
    let b = Buffer.create 128 in
    let rec scan i =
      if i = String.length input then
        failwith "unexpected end of input during quoted atom"
      else
        match input.[i] with
        | '"' ->
           i+1, Buffer.contents b
        | '\\' ->
           (if i + 1 = String.length input then
              failwith "unexpected end of input during quoted atom"
            else
              match input.[i+1] with
              | 'n' -> Buffer.add_char b '\n'; scan (i+2)
              | 't' -> Buffer.add_char b '\t'; scan (i+2)
              | '\\' -> Buffer.add_char b '\\'; scan (i+2)
              | '"' -> Buffer.add_char b '"'; scan (i+2)
              | _ -> failwith "invalid escape character")
        | c ->
           Buffer.add_char b c; scan (i+1)
    in
    scan start
  in
  let rec scan i acc =
    if i = String.length input then
      i, List.rev acc
    else
      match input.[i] with
      | ' ' | '\n' | '\t' ->
         scan (i+1) acc
      | ')' ->
         i, List.rev acc
      | '(' ->
          (let i, items = scan (i+1) [] in
           if i = String.length input then
             failwith "unexpected end of input"
           else if input.[i] = ')' then
             scan (i+1) (list items :: acc)
           else
             failwith "expecting ')'")
      | c when is_unquoted_atom_char c ->
         let i, str = scan_unquoted_atom i in
         scan i (atom str :: acc)
      | '"' ->
         let i, str = scan_quoted_atom (i+1) in
         scan i (atom str :: acc)
      | _ ->
         failwith "unexpected character"
  in
  let i, result = scan 0 [] in
  if i = String.length input then
    result
  else
    failwith "Unexpected junk at end of input"
 *)
end

open Generalities

type sexp =
  | Atom of string
  | List of sexp list

(* FIXME: spans *)
let of_lexbuf lexbuf =
  let rec scan acc =
    match Sexp_reader.token lexbuf with
    | Sexp_reader.EOF ->
       List.rev acc, `eof
    | RParen ->
       List.rev acc, `rparen
    | LParen ->
       (let list, terminator = scan [] in
        match terminator with
        | `eof -> failwith "Unfinished '('"
        | `rparen -> scan (List list :: acc))
    | BareAtom atom | QuotedAtom atom ->
       scan (Atom atom :: acc)
  in
  let sexps, terminator = scan [] in
  match terminator with
  | `eof -> sexps
  | `rparen -> failwith "Non-matching ')'"

let is_bare_atom =
  String.for_all Sexp.is_unquoted_atom_char

let quote str =
  let b = Buffer.create 128 in
  Buffer.add_string b "\"";
  str |> String.iter (function
             | '"' -> Buffer.add_string b "\\\""
             | '\\' -> Buffer.add_string b "\\\\"
             | '\n' -> Buffer.add_string b "\\n"
             | '\t' -> Buffer.add_string b "\\t"
             | c    -> Buffer.add_char b c);
  Buffer.add_string b "\"";
  Buffer.contents b

let atom str =
  if is_bare_atom str then
    Pretty.text str
  else
    Pretty.text (quote str)

and list = function
  | [] -> Pretty.text "()"
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
  |> of_lexbuf
  |> List.map pretty
  |> List.iter (fun doc -> Pretty.print doc; print_newline ())
