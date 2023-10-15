module Calculus = Focused

open Fol_formula

let string_of_goal = function
  | Focused.Checking goal ->
     "⊢ " ^ Formula.to_string goal
  | Focused.Synthesis (focus, goal) ->
     Printf.sprintf "[%s] ⊢ %s"
       (Formula.to_string focus)
       (Formula.to_string goal)

let string_of_assumption nm = function
  | Focused.A_Termvar -> nm
  | Focused.A_Formula f -> nm ^ " : " ^ Formula.to_string f

let string_of_error msg =
  msg

let label_of_rule rule =
  Focused.Rule.name rule

let parse_rule =
  Focused_command.of_string
