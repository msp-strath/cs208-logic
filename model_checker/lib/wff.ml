open Fol_formula
module Env = Set.Make (String)

let valid_term env = function
  | Var v ->
      if Env.mem v env then Ok ()
      else Error (Printf.sprintf "Variable '%s' not bound." v)
  | Fun (f, _) ->
      Error
        (Printf.sprintf
           "Function symbol %s found: functions are not supported in the model \
            checker"
           f)

let rec valid_formula vocab env = function
  | True | False -> Ok ()
  | Atom (r, tms) -> (
      match Vocabulary.arity r vocab with
      | None ->
          Error
            (Printf.sprintf "Predicate “%s” not in the current vocabulary" r)
      | Some arity ->
          let num_args = List.length tms in
          if arity = num_args then
            let rec check_all = function
              | [] -> Ok ()
              | tm :: tms -> (
                  match valid_term env tm with
                  | Ok () -> check_all tms
                  | Error _ as e -> e)
            in
            check_all tms
          else
            Error
              (Printf.sprintf
                 "Predicate “%s” has arity %d, but has been used with %d \
                  arguments."
                 r arity num_args))
  | Imp (f1, f2) | And (f1, f2) | Or (f1, f2) -> (
      match valid_formula vocab env f1 with
      | Ok () -> valid_formula vocab env f2
      | Error _ as e -> e)
  | Not f -> valid_formula vocab env f
  | Forall (x, f) | Exists (x, f) -> valid_formula vocab (Env.add x env) f

let valid_closed_formula vocab f = valid_formula vocab Env.empty f
