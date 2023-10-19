let token state lexbuf =
  let open Parser in
  match state with
  | `Structure -> (
      match Lexer.structure_token lexbuf with
      | QUOTE -> (`Formula, QUOTE (* or supress it?*))
      | token -> (`Structure, token))
  | `Formula -> (
      match Lexer.formula_token lexbuf with
      | QUOTE -> (`Structure, QUOTE)
      | token -> (`Formula, token))

(* FIXME: error messages?? *)
let parse entrypoint lexbuf =
  let module MI = Parser.MenhirInterpreter in
  let rec loop lex_state cp =
    match cp with
    | MI.Accepted a -> Ok a
    | MI.InputNeeded _env ->
        let lex_state, tok = token lex_state lexbuf in
        let spos = Lexing.lexeme_start_p lexbuf in
        let epos = Lexing.lexeme_end_p lexbuf in
        loop lex_state (MI.offer cp (tok, spos, epos))
    | MI.Shifting _ | MI.AboutToReduce _ -> loop lex_state (MI.resume cp)
    | MI.HandlingError _ ->
        let pos = Parser_util.Location.of_lexbuf lexbuf in
        let lexeme = Lexing.lexeme lexbuf in
        Error
          (fun fmt ->
            Format.fprintf fmt "Error at %a on input '%s'"
              Parser_util.Location.pp pos lexeme)
    | MI.Rejected -> assert false
  in
  let init_pos = lexbuf.Lexing.lex_curr_p in
  loop `Structure (entrypoint init_pos)

let parse = parse Parser.Incremental.structure
