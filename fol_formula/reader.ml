let term_of_string string =
  let lb = Lexing.from_string string in
  match Parser.whole_term Lexer.token lb with
  | exception Parser.Error -> None
  | f -> Some f

module P = Parser_util.Driver.Make (Parser) (Lexer) (Parser_messages)

let of_string = P.parse Parser.Incremental.whole_formula
