open Model_checker
open Fol_formula

let pp_output fmt = function
  | Exec_structure.Message msg -> Format.fprintf fmt "INFO: %s@\n" msg
  | Exec_structure.Outcome (model_name, formula, outcome) ->
      Format.fprintf fmt "@[<v2>Checking %s |= \"%s\":@,%a@]@\n" model_name
        (Formula.to_string formula)
        Checker.pp_outcome outcome

let () =
  let lexbuf = Lexing.from_channel stdin in
  match Reader.parse lexbuf with
  | Ok structure ->
     (* Format.printf "%a" Structure.pp structure *)
     (match Exec_structure.exec structure with
      | exception e ->
         Printexc.print_backtrace stdout;
         raise e
      | Error (outputs, msg) ->
         Format.printf "@[<v>%a@]@\n" Fmt.(list pp_output) outputs;
         Format.eprintf "ERROR: %s\n" msg
      | Ok outputs ->
         Format.printf "%a@\n" Fmt.(list pp_output) outputs)
  | Error msg -> Format.eprintf "Parse error: %t@\n" msg
