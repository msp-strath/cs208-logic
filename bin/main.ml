open Traintor

let execute filename =
  let decls =
    In_channel.with_open_text filename
      (fun ch ->
        let lexbuf = Lexing.from_channel ch in
        Parser.structure Lexer.token lexbuf)
  in
  match Type_checker.check_declarations decls with
  | Error (location, msg) ->
     let msg = Printf.sprintf "Problem at %a: %s"
                 Ast.Location.to_string location
                 msg
     in
     prerr_endline msg;
     exit 1
  | Ok commands ->
     List.iter Evaluator.execute_command commands;
     exit 0

let pretty_print filename =
  let decls =
    In_channel.with_open_text filename
      (fun ch ->
        let lexbuf = Lexing.from_channel ch in
        Parser.structure Lexer.token lexbuf)
  in
  Format.printf
    "@[<v0>%a@]"
    (Format.pp_print_list Ast.pp_declaration) decls

let () =
  match Sys.argv with
  | [| _; "execute"; filename |] ->
     execute filename
  | [| _; "prettyprint"; filename |] ->
     pretty_print filename
  | _ ->
     Printf.eprintf "Usage: %s (execute|prettyprint) FILE\n"
       Sys.argv.(0)
