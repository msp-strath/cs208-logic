{
  open Parser

  type token = Parser.token
}

let ident_char = ['a'-'z' 'A'-'Z' '0'-'9' '-' '_']

let white = [' ' '\t']+
let ident = ['a'-'z''A'-'Z'] ident_char*

rule token = parse
| white { token lexbuf }
| '\n'  { Lexing.new_line lexbuf; token lexbuf }
| "//" [^'\n']* { token lexbuf }

(* special symbols *)
| ':'       { COLON }
| ';'       { SEMICOLON }
| '.'       { DOT }
| '{'       { LBRACE }
| '}'       { RBRACE }
| '-'       { DASH }

(* keywords *)
| "axiom"   { AXIOM }
| "theorem" { THEOREM }
| "proof"   { PROOF }
| "end"     { END}

| '?' (ident as i) { QIDENT i }
| ident     { IDENTIFIER (Lexing.lexeme lexbuf) }
| '"'       { let b = Buffer.create 128 in stringliteral b lexbuf }

| eof       { EOF }

and stringliteral b = parse
| '"'       { QUOTED (Buffer.contents b) }
| '\\' '"'  { Buffer.add_char b '"';
              stringliteral b lexbuf }
| '\n'      { Buffer.add_char b '\n';
              Lexing.new_line lexbuf;
              stringliteral b lexbuf }
| [^'\\' '"' '\n']+
            { Buffer.add_string b (Lexing.lexeme lexbuf);
              stringliteral b lexbuf }
