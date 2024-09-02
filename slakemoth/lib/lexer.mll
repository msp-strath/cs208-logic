{
  open Parser

  type token = Parser.token
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
| "define"     { DEFINE }
| "atom"       { ATOM }
| "domain"     { DOMAIN }
| "dump"       { KW_DUMP }
| "ifsat"      { KW_IFSAT }
| "allsat"     { KW_ALLSAT }
| "print"      { KW_PRINT }
| "true"       { TRUE }
| "false"      { FALSE }
| "next"       { NEXT }
| "the"        { THE }
| ','          { COMMA }
| ':'          { COLON }
| '{'          { LBRACE }
| '}'          { RBRACE }
| '('          { LPAREN }
| ')'          { RPAREN }
| '['          { LBRACK }
| ']'          { RBRACK }
| "for"        { KW_FOR }
| "if"         { KW_IF }
| '"'          { let b = Buffer.create 128 in string_literal b lexbuf }
| ident        { IDENT (Lexing.lexeme lexbuf) }
| constructorname { CONSTRUCTOR_NAME (Lexing.lexeme lexbuf) }
| eof          { EOF }
| _            { UNKNOWN }

and string_literal b = parse
| '"'          { STRING_LITERAL (Buffer.contents b) }
| '\\' '"'     { Buffer.add_char b '"'; string_literal b lexbuf }
| eof          { EOF } (* FIXME: some other error *)
| [^'\\' '"']+ { Buffer.add_string b (Lexing.lexeme lexbuf); string_literal b lexbuf }
