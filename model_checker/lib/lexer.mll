{
open Parser
open Fol_formula
}

let white   = [' ' '\t']+
let ident   = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '-']*
let digit   = ['0'-'9']

rule structure_token = parse
  | white        { structure_token lexbuf }
  | '/''/' [^'\n']* '\n' { Lexing.new_line lexbuf; structure_token lexbuf }
  | '/''/' [^'\n']* eof { Ok EOF }
  | '\n'         { Lexing.new_line lexbuf; structure_token lexbuf }
  | "\"" ([^ '\"']* as quoted) "\""
                 { Result.bind (Formula.of_string quoted) (fun f -> Ok (QUOTED f)) }
  | "vocab"      { Ok VOCAB }
  | "for"        { Ok FOR }
  | "model"      { Ok MODEL }
  | "check"      { Ok CHECK }
  | "axioms"     { Ok AXIOMATISATION }
  | "synth"      { Ok SYNTH }
  | "size"       { Ok SIZE }
  | "{"          { Ok LBRACE }
  | "}"          { Ok RBRACE }
  | "|="         { Ok MODELS }
  | "="          { Ok EQUALS }
  | "("          { Ok LPAREN }
  | ")"          { Ok RPAREN }
  | ":"          { Ok COLON }
  | "/"          { Ok SLASH }
  | ","          { Ok COMMA }
  | ident        { Ok (IDENT (Lexing.lexeme lexbuf)) }
  | ('-'|'+'|"")digit+
    { try (Ok (INTLIT (int_of_string (Lexing.lexeme lexbuf))))
      with Failure _ -> Ok UNKNOWN }
  | eof          { Ok EOF }
  | _            { Ok UNKNOWN }

(*
and formula_token = parse
| white   { formula_token lexbuf }
| '\n'         { Lexing.new_line lexbuf; formula_token lexbuf }
| "\""    { QUOTE }
| "->" | "→"   { ARROW }
| "/\\" | "∧" | "&&" { AND }
| "\\/" | "∨" | "||" { OR }
| "!" | "~" | "¬" { NOT }
| "("     { LPAREN }
| ")"     { RPAREN }
| ","     { COMMA }
| "."     { DOT }
| "True" | "⊤"  | "T" { TRUE }
| "False" | "⊥" | "F" { FALSE }
| "ALL" | "All" | "all" | "∀" | "forall"   { FORALL }
| "EX" | "Ex" | "ex" | "∃" | "exists"      { EXISTS }
| "="     { EQ }
| "!="    { NE }
| ('-'|'+'|"")digit+
    { try (INTLIT (int_of_string (Lexing.lexeme lexbuf)))
      with Failure _ -> UNKNOWN }
| ident   { IDENT (Lexing.lexeme lexbuf) }
| eof     { EOF }
| _       { UNKNOWN }
 *)
