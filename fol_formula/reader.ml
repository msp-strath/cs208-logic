module P = Parser_util.Driver.Make (Parser) (Lexer) (Parser_messages)

let term_of_string =
  P.parse Parser.Incremental.whole_term

let formula_of_string =
  P.parse Parser.Incremental.whole_formula
