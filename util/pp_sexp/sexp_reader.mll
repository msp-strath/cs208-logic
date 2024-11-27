{
type token =
  | LParen
  | RParen
  | BareAtom of string
  | QuotedAtom of string
  | EOF
}

let bare_word_char = ['a'-'z' 'A'-'Z' '_' '-' '0'-'9']
let white = [' ' '\t']+

rule token = parse
| white           { token lexbuf }
| '\n'            { Lexing.new_line lexbuf; token lexbuf }
| ';' [^'\n']*    { token lexbuf }
| '('             { LParen }
| ')'             { RParen }
| bare_word_char+ { BareAtom (Lexing.lexeme lexbuf) }
| '"'             { let b = Buffer.create 128 in quoted_atom b lexbuf }
| eof             { EOF }

and quoted_atom b = parse
| '"'       { QuotedAtom (Buffer.contents b) }
| '\\' '"'  { Buffer.add_char b '\"'; quoted_atom b lexbuf }
| '\\' 'n'  { Buffer.add_char b '\n'; quoted_atom b lexbuf }
| '\\' 't'  { Buffer.add_char b '\t'; quoted_atom b lexbuf }
| '\\' 'r'  { Buffer.add_char b '\r'; quoted_atom b lexbuf }
| '\\' '\\' { Buffer.add_char b '\\'; quoted_atom b lexbuf }
| [^ '\\' '"' '\n']+ { Buffer.add_string b (Lexing.lexeme lexbuf);
                       quoted_atom b lexbuf }

{

open Sexp

(* FIXME: spans *)
let of_lexbuf lexbuf =
  let rec scan acc =
    match token lexbuf with
    | EOF ->
       failwith "Unexpected EOF" (* FIXME: say where the opening '(' was *)
    | RParen ->
       List.rev acc
    | LParen ->
       let list = scan [] in
       scan (List list :: acc)
    | BareAtom atom | QuotedAtom atom ->
       scan (Atom atom :: acc)
  in
  let rec to_seq () =
    match token lexbuf with
    | EOF ->
       Seq.Nil
    | RParen ->
       failwith "Unopened ')'" (* FIXME: say where *)
    | LParen ->
       let list = scan [] in
       Seq.Cons (List list, to_seq)
    | BareAtom atom | QuotedAtom atom ->
       Seq.Cons (Atom atom, to_seq)
  in
  to_seq

}
