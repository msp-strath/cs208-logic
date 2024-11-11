module P = Parser_util.Driver.Make (Parser) (Lexer) (Parser_messages)

let parse =
  P.parse Parser.Incremental.structure

let parse_term =
  P.parse Parser.Incremental.whole_term
