{
open Parser

type token = Parser.token
}

let white   = [' ' '\t' '\n']+
let ident   = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '-']*
let digit   = ['0'-'9']

rule token = parse
| white   { token lexbuf }
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
