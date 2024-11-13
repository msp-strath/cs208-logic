open Slakemoth
open Generalities
open Result_ext.Syntax

let handle_errors = function
  | Ok () ->
     exit 0
  | Error (`Parse err) ->
     Printf.eprintf "ERROR: %s\n" (Parser_util.Driver.string_of_error err);
     exit 1
  | Error (`Type_error (location, msg)) ->
     let msg = Printf.sprintf "Problem at %s: %s"
                 (Ast.Location.to_string location)
                 msg
     in
     prerr_endline msg;
     exit 1
  | Error (`Usage msg) ->
     prerr_endline msg;
     exit 1

let execute filename =
  let contents  = In_channel.with_open_bin filename In_channel.input_all in
  let* decls    = Reader.parse contents in
  let* commands = Type_checker.check_declarations decls in
  commands
  |> List.to_seq
  |> Seq.concat_map Evaluator.execute_command
  |> Seq.iter (fun json -> Pretty.print (Json.to_document json);
                           print_newline ());
  Result.ok ()

let pretty_print filename =
  let contents = In_channel.with_open_bin filename In_channel.input_all in
  let* decls   = Reader.parse contents in
  Format.printf
    "@[<v0>%a@]"
    (Format.pp_print_list Slakemoth_pp.Ast.pp_declaration) decls;
  Result.ok ()

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
