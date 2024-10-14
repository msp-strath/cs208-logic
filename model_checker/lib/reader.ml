(* FIXME: error messages?? *)
let parse entrypoint lexbuf =
  let module MI = Parser.MenhirInterpreter in
  let rec loop cp =
    match cp with
    | MI.Accepted a -> Ok a
    | MI.InputNeeded _env ->
       (match Lexer.structure_token lexbuf with
        | Ok tok ->
           let spos = Lexing.lexeme_start_p lexbuf in
           let epos = Lexing.lexeme_end_p lexbuf in
           loop (MI.offer cp (tok, spos, epos))
        | Error (`Parse e) ->
           let pos = Parser_util.Location.of_lexbuf lexbuf in
           Error (fun fmt ->
               Format.fprintf fmt
                 "Error in formula at %a: %s"
                  Parser_util.Location.pp_without_filename pos
                  (Parser_util.Driver.string_of_error e)))
    | MI.Shifting _ | MI.AboutToReduce _ -> loop (MI.resume cp)
    | MI.HandlingError _ ->
        let pos = Parser_util.Location.of_lexbuf lexbuf in
        let lexeme = Lexing.lexeme lexbuf in
        Error
          (fun fmt ->
            Format.fprintf fmt "Error at %a on input '%s'"
              Parser_util.Location.pp_without_filename pos lexeme)
    | MI.Rejected -> assert false
  in
  let init_pos = lexbuf.Lexing.lex_curr_p in
  loop (entrypoint init_pos)

let parse = parse Parser.Incremental.structure
