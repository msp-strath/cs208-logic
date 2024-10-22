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

module SimpleDoc = struct
  type block = string

  type inline = string

  let txt s = s
  let p = String.concat ""
  let code_bl s = s

  let to_string = String.concat "\n\n"

end

let compare filename1 filename2 =
  let* file1 = Reader.parse (In_channel.with_open_bin filename1 In_channel.input_all) in
  let* file2 = Reader.parse (In_channel.with_open_bin filename2 In_channel.input_all) in
  let* commands1 = Type_checker.check_declarations file1 in
  let* commands2 = Type_checker.check_declarations file2 in
  match Compare.do_question commands1 commands2 with
  | Ok () ->
     Printf.printf "Equivalent!\n";
     exit 0
  | Error difference ->
     let doc = Compare.print_err (module SimpleDoc) difference in
     print_endline (SimpleDoc.to_string doc);
     exit 1

let mark marking_script submitted_script =
  let* marking_script = Reader.parse_marking_script (In_channel.with_open_bin marking_script In_channel.input_all) in
  let* submitted_script = Reader.parse (In_channel.with_open_bin submitted_script In_channel.input_all) in
  match Marker.check marking_script submitted_script with
  | Ok () ->
     print_endline "OK";
     exit 0
  | Error err ->
     print_endline (Marker.string_of_error err);
     exit 1

let () =
  handle_errors @@
  match Sys.argv with
  | [| _; "execute"; filename |] ->
     execute filename
  | [| _; "prettyprint"; filename |] ->
     pretty_print filename
  | [| _; "compare"; filename1; filename2 |] ->
     compare filename1 filename2
  | [| _; "mark"; filename1; filename2 |] ->
     mark filename1 filename2
  | _ ->
     Error (`Usage (Printf.sprintf "Usage: %s (execute|prettyprint) FILE\n"
                      Sys.argv.(0)))
