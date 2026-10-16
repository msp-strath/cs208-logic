open Model_checker

let print_output = function
  | Exec_structure.Message msg ->
    Printf.printf "INFO: %s\n" msg
  | Exec_structure.Table { headers; rows } ->
    print_endline (String.concat "," headers);
    rows |> List.iter (Fun.compose print_endline (String.concat ","));
    print_newline ()

  (* | Exec_structure.Outcome (model_name, formula, outcome) -> *)
  (*    Format.fprintf fmt "@[<v2>Checking %s |= \"%s\":@,%a@]@\n" model_name *)
  (*      (Formula.to_string formula) *)
  (*      Checker.pp_outcome outcome *)

let () =
  let lexbuf = Lexing.from_channel stdin in
  match Reader.parse lexbuf with
  | Ok structure ->
    (match Exec_structure.exec structure with
    | exception e ->
      Printexc.print_backtrace stdout;
      raise e
    | Error (outputs, msg) ->
      List.iter print_output outputs;
      Format.eprintf "ERROR: %s\n" msg
    | Ok outputs ->
      List.iter print_output outputs)
  | Error msg ->
    Format.eprintf "Parse error: %t@\n" msg
