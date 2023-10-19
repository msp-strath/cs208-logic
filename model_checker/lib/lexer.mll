{
open Parser
}

let white   = [' ' '\t']+
let ident   = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '-']*
let digit   = ['0'-'9']

rule structure_token = parse
  | white        { structure_token lexbuf }
  | '/''/' [^'\n']* '\n' { Lexing.new_line lexbuf; structure_token lexbuf }
  | '/''/' [^'\n']* eof { EOF }
  | '\n'         { Lexing.new_line lexbuf; structure_token lexbuf }
  | "\""         { QUOTE }
  | "vocab"      { VOCAB }
  | "for"        { FOR }
  | "model"      { MODEL }
  | "check"      { CHECK }
  | "axioms"     { AXIOMATISATION }
  | "synth"      { SYNTH }
  | "size"       { SIZE }
  | "{"          { LBRACE }
  | "}"          { RBRACE }
  | "|="         { MODELS }
  | "="          { EQUALS }
  | "("          { LPAREN }
  | ")"          { RPAREN }
  | ":"          { COLON }
  | "/"          { SLASH }
  | ","          { COMMA }
  | ident        { IDENT (Lexing.lexeme lexbuf) }
  | ('-'|'+'|"")digit+
    { try (INTLIT (int_of_string (Lexing.lexeme lexbuf)))
      with Failure _ -> UNKNOWN }
  | eof          { EOF }
  | _            { UNKNOWN }

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
