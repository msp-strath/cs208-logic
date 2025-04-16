open Generalities
open Result_ext.Syntax

open Ast

open Fol_formula

module GoalStack =
  Natural_deduction.Goal_stack.Make (Natural_deduction.Focused)

let interpret_command Annotated.{ detail = { head; args }; annotation = location } =
  Result.map_error
    (fun e -> location, `Command_interp_error e)
    (Command.parse_command
       Natural_deduction.Focused_command.commands
       (head::args))

let json_of_assumption =
  let open Natural_deduction.Focused in
  let open Json in
  function
  | (name, A_Formula fmla) ->
     JObject
       [ "name", JString name
       ; "type", JString "formula"
       ; "formula", JString (Formula.to_string fmla) ]
  | (name, A_Termvar) ->
     JObject
       [ "name", JString name
       ; "type", JString "entity" ]

let json_of_goal =
  let open Natural_deduction.Focused in
  let open Json in
  function
  | Checking goal ->
     JObject
       [ "goal", JString (Formula.to_string goal) ]
  | Synthesis (focus, goal) ->
     JObject
       [ "focus", JString (Formula.to_string focus)
       ; "goal", JString (Formula.to_string goal)
       ]

let json_of_hole name assumptions goal =
  let open Json in
  let open Natural_deduction.Focused in
  JObject
    [ "name", JString name
    ; "assumptions", JArray (List.map json_of_assumption assumptions)
    ; "goal", json_of_goal goal
    ]

let rec execute_proof stack proof =
  match proof.Annotated.detail with
  | Hole name ->
     let* { GoalStack.assumptions; goal }, stack =
       Result.map_error (fun e -> proof.Annotated.annotation, e) (GoalStack.pop stack)
     in
     let json = json_of_hole name assumptions goal in
     Pretty.print (Json.to_document json);
     Ok stack
  | Rule (command, sub_proofs) ->
     let* rule  = interpret_command command in
     let* stack =
       Result.map_error (fun e -> command.Annotated.annotation, e)
         (GoalStack.apply rule stack)
     in
     Result_ext.fold_left_err execute_proof stack sub_proofs

let interpret_item environment = function
  | Axiom (ident, formula) ->
     let* formula =
       Result.map_error (fun e -> formula.Annotated.annotation, `Formula_error e)
         (Formula.of_string formula.detail)
     in
     Ok ((ident.detail, Natural_deduction.Focused.A_Formula formula)
         :: environment)
  | Theorem (ident, formula, proof, end_of_proof) ->
     let* formula =
       Result.map_error (fun e -> formula.Annotated.annotation, `Formula_error e)
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
         Error (end_of_proof.Annotated.annotation, `Proof_incomplete))

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
