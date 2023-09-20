open Traintor

module P = Parser_util.Driver.Make (Parser) (Lexer) (Parser_messages)

open Result_syntax

let handle_errors = function
  | Ok () ->
     exit 0
  | Error (`Parse err) ->
     Format.eprintf "ERROR: %s\n" (Parser_util.Driver.string_of_error err);
     exit 1
  | Error (`Type_error (location, msg)) ->
     let msg = Printf.sprintf "Problem at %a: %s"
                 Ast.Location.to_string location
                 msg
     in
     prerr_endline msg;
     exit 1
  | Error (`Usage msg) ->
     prerr_endline msg;
     exit 1

let execute filename =
  let contents = In_channel.with_open_bin filename In_channel.input_all in
  let* decls = P.parse Parser.Incremental.structure contents in
  let* commands = Type_checker.check_declarations decls in
  List.iter Evaluator.execute_command commands;
  Ok ()

(*
  let decls =
    In_channel.with_open_text filename
      (fun ch ->
        let lexbuf = Lexing.from_channel ch in
        Parser.structure Lexer.token lexbuf)
  in
  match Type_checker.check_declarations decls with
  | Error (location, msg) ->

  | Ok commands ->
     List.iter Evaluator.execute_command commands;
     exit 0
 *)

let pretty_print filename =
  let contents = In_channel.with_open_bin filename In_channel.input_all in
  let* decls = P.parse Parser.Incremental.structure contents in
  Format.printf
    "@[<v0>%a@]"
    (Format.pp_print_list Ast.pp_declaration) decls;
  Ok ()
(*
  let decls =
    In_channel.with_open_text filename
      (fun ch ->
        let lexbuf = Lexing.from_channel ch in
        Parser.structure Lexer.token lexbuf)
  in
 *)

let () =
  handle_errors @@
  match Sys.argv with
  | [| _; "execute"; filename |] ->
     execute filename
  | [| _; "prettyprint"; filename |] ->
     pretty_print filename
  | _ ->
     Error (`Usage (Printf.sprintf "Usage: %s (execute|prettyprint) FILE\n"
                      Sys.argv.(0)))
