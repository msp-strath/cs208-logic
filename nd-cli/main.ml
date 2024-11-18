open Generalities
open Result_ext.Syntax

open Ast

open Fol_formula

module GoalStack =
  Natural_deduction.Goal_stack.Make (Natural_deduction.Focused)

let interpret_command { detail = { head; args }; location } =
  Result.map_error
    (fun e -> location, `Command_interp_error e)
    (Command.parse_command
       Natural_deduction.Focused_command.commands
       (head::args))

let rec execute_proof stack proof =
  match proof.detail with
  | Hole name ->
     let* { GoalStack.assumptions; goal }, stack =
       Result.map_error (fun e -> proof.location, e) (GoalStack.pop stack)
     in
     let json =
       let open Json in
       let open Natural_deduction.Focused in
       JObject
         [ "name", JString name
         ; "assumptions",
           JArray (List.map
                     (function
                      | (name, A_Formula fmla) ->
                         JObject
                           [ "name", JString name
                           ; "type", JString "formula"
                           ; "formula", JString (Formula.to_string fmla) ]
                      | (name, A_Termvar) ->
                         JObject
                           [ "name", JString name
                           ; "type", JString "entity" ])
                     assumptions)
         ; "goal",
           (match goal with
            | Checking goal ->
               JObject
                 [ "goal", JString (Formula.to_string goal) ]
            | Synthesis (focus, goal) ->
               JObject
                 [ "focus", JString (Formula.to_string focus)
                 ; "goal", JString (Formula.to_string goal)
           ])
         ]
     in
     Pretty.print (Json.to_document json);
     Ok stack
  | Rule (command, sub_proofs) ->
     let* rule  = interpret_command command in
     let* stack =
       Result.map_error (fun e -> command.location, e)
         (GoalStack.apply rule stack)
     in
     Result_ext.fold_left_err execute_proof stack sub_proofs

let interpret_item environment = function
  | { detail = Axiom (ident, formula); location = _ } ->
     let* formula =
       Result.map_error (fun e -> formula.location, `Formula_error e)
         (Formula.of_string formula.detail)
     in
     Ok ((ident.detail, Natural_deduction.Focused.A_Formula formula)
         :: environment)
  | { detail = Theorem (ident, formula, proof); location } ->
     let* formula =
       Result.map_error (fun e -> formula.location, `Formula_error e)
         (Formula.of_string formula.detail)
     in
     let goal_stack =
       [ GoalStack.
         { assumptions = environment
         ; goal        = Natural_deduction.Focused.Checking formula
         }
       ]
     in
     let* remaining_goals = execute_proof goal_stack proof in
     (match remaining_goals with
      | [] ->
         Ok ((ident.detail, Natural_deduction.Focused.A_Formula formula)
             :: environment)
      | _ ->
         Error (location, `Proof_incomplete))

let () =
  let filename = Sys.argv.(1) in
  let parsed_items =
    In_channel.with_open_text filename
      (fun ch ->
        let lexbuf = Lexing.from_channel ch in
        Parser.items Lexer.token lexbuf)
  in
  Result_ext.fold_left_err
    interpret_item
    []
    parsed_items
  |> function
    | Error (loc, _err) ->
       Printf.eprintf "ERROR at %s\n" (Parser_util.Location.to_string loc); exit 1
    | Ok _ ->
       Printf.printf "OK\n"; exit 0
