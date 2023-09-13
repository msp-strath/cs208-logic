{
  open Parser
}

let white = [' ' '\t']+
let ident = ['a'-'z'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '-']*
let constructorname = ['A'-'Z'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '-']*

rule token = parse
| white { token lexbuf }
| '\n'  { Lexing.new_line lexbuf; token lexbuf }
| "//" [^'\n']* { token lexbuf }
| "/\\" | "&" { OP_AND }
| "\\/" | "|" { OP_OR }
| "="         { OP_EQ }
| "!="        { OP_NE }
| "!" | "¬" | "~" { OP_NOT }
| "==>"        { OP_IMPLIES }
| "forall"     { FORALL }
| "some"       { SOME }
| "definition" { DEFINITION }
| "atom"       { ATOM }
| "domain"     { DOMAIN }
| ','          { COMMA }
| ':'          { COLON }
| '{'          { LBRACE }
| '}'          { RBRACE }
| '('          { LPAREN }
| ')'          { RPAREN }
| ident        { IDENT (Lexing.lexeme lexbuf) }
| constructorname { CONSTRUCTOR_NAME (Lexing.lexeme lexbuf) }
| eof          { EOF }
