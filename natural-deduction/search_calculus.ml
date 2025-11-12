open Generalities
open Fol_formula

module Calculus = struct

  type atom = string * term list

  type goal =
    { names : NameSet.t
    ; goals : (bool * formula) list
    ; atoms : (bool * atom) list
    }

  type assumption = Impossible.t

  type update = unit

  let empty_update = ()

  let update_goal () g = g
  let update_assumption () a = a
  let combine_update () () = ()

  type rule =
    | Step
  [@@deriving sexp]
  (* Instantiate *)

  type error = string

  let apply _assumps Step state =
    match state.goals with
    | [] ->
       (* FIXME: check the atoms for contradictions *)
       Error "end"

    | ((false, True) | (true, False))::goals ->
       Ok ([ [], { state with goals } ], ())

    | ((false, False) | (true, True))::_goals ->
       Ok ([], ())

    | ((true as pol), And (p, q) | (false as pol), Or (p, q))::goals ->
       Ok ([ [], { state with goals = (pol, p)::goals }
           ; [], { state with goals = (pol, q)::goals } ],
           ())

    | ((true as pol), Or (p, q) | (false as pol), And (p, q))::goals ->
       Ok ([ [], { state with goals = (pol, p)::(pol, q)::goals } ],
           ())

    | ((true as pol), Forall (x, p) | (false as pol), Exists (x, p))::goals ->
       let fresh_x = NameSet.fresh_for state.names x in
       let p = Formula.subst x (Var fresh_x) p in
       let names = NameSet.add fresh_x state.names in
       Ok ([ [], { state with names; goals = (pol, p)::goals } ],
           ())

    | (true, Imp (p, q))::goals ->
       Ok ([ [], { state with goals = (false,p)::(true,q)::goals } ],
           ())

    | (false, Imp (p, q))::goals ->
       Ok ([ [], { state with goals = (true,p)::goals }
           ; [], { state with goals = (false,q)::goals } ],
           ())

    | (pol, Not p)::goals ->
       Ok ([ [], { state with goals = (not pol, p)::goals } ],
           ())

    | (pol, Atom (rel, terms))::goals ->
       if List.mem (not pol, (rel, terms)) state.atoms then
         Ok ([], ())
       else
         Ok ([ [], { state with goals; atoms = (pol, (rel, terms))::state.atoms }], ())

    | (true, Exists (_x, _p) | false, Forall (_x, _p))::goals ->
       Ok ([ [], { state with goals } ], ())

end

module UI = struct

  module Calculus = Calculus

  open Calculus

  let string_of_goal { names = _; goals; atoms } =
    let goals =
      String.concat ", "
        (List.map
           (fun (pol, fmla) -> (if pol then "+" else "-") ^ Formula.to_string fmla)
           goals)
    in
    let atoms =
      String.concat ", "
        (List.map
           (fun (pol, (rel, tms)) -> (if pol then "+" else "-") ^ Formula.to_string (Atom (rel, tms)))
           atoms)
    in
    goals ^ " => [" ^ atoms ^ "]"

  let string_of_assumption _nm = Impossible.elim

  let string_of_error s = s

  let label_of_rule = function
    | Step -> ""

  let parse_rule string =
    let string = String.trim string in
    match string with
    | "step" -> Ok Step
    | _ -> Error "command no understood"

end

let component str =
  match Formula.of_string str with
  | Ok fmla ->
     let names = Formula.fv fmla NameSet.empty in
     let goal = Calculus.{ names; goals = [true, fmla]; atoms = [] } in
     let module C = Proof_tree_UI2.Make (UI) (struct let assumptions = [] let goal = goal end) in
     (module C : Ulmus.PERSISTENT)
  | Error (`Parse (_,detail,_)) ->
     let message = "Configuration failure: " ^ detail in
     Widgets.Error_display.component message
