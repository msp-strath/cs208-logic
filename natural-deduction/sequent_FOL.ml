module System = struct
  type term = Fol_formula.term
  type formula = Fol_formula.formula

  module Formula = Fol_formula.Formula
  module Term = Fol_formula.Term

  type rule =
    | Implies_intro
    | Implies_elim of int
    | Conj_intro
    | Conj_elim of int
    | Disj_intro1
    | Disj_intro2
    | Disj_elim of int
    | Forall_elim of int * term
    | Forall_intro
    | Exists_intro of term
    | Exists_elim of int

  type assumption = A_Formula of formula | A_Variable of string

  module Assumption = struct
    type t = assumption

    let to_string = function
      | A_Formula f -> Formula.to_string f
      | A_Variable x -> x
  end

  type error = [ `Msg of string ]
  type update = unit

  let empty_update = ()
  let update_formula () f = f
  let update_assumption () a = a

  open Fol_formula

  let freshen_for_assumps x assumps =
    let vars =
      List.fold_right
        (function A_Formula _ -> fun s -> s | A_Variable x -> NameSet.add x)
        assumps NameSet.empty
    in
    NameSet.fresh_for vars x

  let unify_with_assumption f = function
    | A_Formula f' ->
        if Formula.alpha_equal f f' then Ok ()
        else Error (`Msg "assumption does not unify")
    | A_Variable _ -> Error (`Msg "not a formula")

  let rec get_assumption idx = function
    | [] -> None
    | assump :: _ when idx = 0 -> Some assump
    | _ :: assumps -> get_assumption (idx - 1) assumps

  let apply assumps rule formula =
    match rule with
    | Implies_intro -> (
        match formula with
        | Imp (f1, f2) -> Ok [ ([ A_Formula f1 ], f2) ]
        | _ -> Error (`Msg "implies_intro: formula is not an implication"))
    | Implies_elim assump_idx -> (
        match get_assumption assump_idx assumps with
        | Some (A_Formula (Imp (f1, f2))) ->
            Ok [ ([], f1); ([ A_Formula f2 ], formula) ]
        | Some _ ->
            Error (`Msg "implies_elim: assumption is not an implication")
        | None -> Error (`Msg "implies_elim: no such assumption"))
    | Conj_intro -> (
        match formula with
        | And (f1, f2) -> Ok [ ([], f1); ([], f2) ]
        | _ -> Error (`Msg "conj_intro: does not apply here"))
    | Conj_elim assump_idx -> (
        match get_assumption assump_idx assumps with
        | Some (A_Formula (And (f1, f2))) ->
            Ok [ ([ A_Formula f1; A_Formula f2 ], formula) ]
        | Some _ -> Error (`Msg "conj_elim: assumption is not a conjunction")
        | None -> Error (`Msg "conj_elim: no such assumption"))
    | Disj_intro1 -> (
        match formula with
        | Or (f1, f2) -> Ok [ ([], f1) ]
        | _ -> Error (`Msg "disj_intro1: does not apply here"))
    | Disj_intro2 -> (
        match formula with
        | Or (f1, f2) -> Ok [ ([], f2) ]
        | _ -> Error (`Msg "disj_intro2: does not apply here"))
    | Disj_elim assump_idx -> (
        match get_assumption assump_idx assumps with
        | Some (A_Formula (Or (f1, f2))) ->
            Ok [ ([ A_Formula f1 ], formula); ([ A_Formula f2 ], formula) ]
        | Some _ -> Error (`Msg "disj_elim: assumption is not a disjunction")
        | None -> Error (`Msg "disj_elim: no such assumption"))
    | Forall_intro -> (
        match formula with
        | Forall (x, f) ->
            let x0 = freshen_for_assumps x assumps in
            let f = Formula.subst x (Var x0) f in
            Ok [ ([ A_Variable x0 ], f) ]
        | _ -> Error (`Msg "forall_intro: formula is not a forall"))
    | Forall_elim (assump_idx, tm) -> (
        match get_assumption assump_idx assumps with
        | Some (A_Formula (Forall (x, body))) ->
            let inst_f = Formula.subst x tm body in
            Ok [ ([ A_Formula inst_f ], formula) ]
        | Some _ -> Error (`Msg "forall_elim: assumption is not a forall")
        | None -> Error (`Msg "forall_elim: no such assumption"))
    | Exists_intro t -> (
        match formula with
        | Exists (x, f) ->
            let f = Formula.subst x t f in
            Ok [ ([], f) ]
        | _ -> Error (`Msg "exists_intro: formula is not an existential"))
    | Exists_elim assump_idx -> (
        match get_assumption assump_idx assumps with
        | Some (A_Formula (Exists (x, body))) ->
            let x0 = freshen_for_assumps x assumps in
            let f = Formula.subst x (Var x0) body in
            Ok [ ([ A_Variable x0; A_Formula f ], formula) ]
        | Some _ -> Error (`Msg "exists_elim: assumption is not an existential")
        | None -> Error (`Msg "exists_elim: no such assumption"))

  let apply assumps rule goal =
    match apply assumps rule goal with
    | Ok subgoals -> Ok (subgoals, ())
    | Error err -> Error err
end

module Partials = struct
  module Calculus = System
  open Calculus

  let name_of_rule = function
    | Implies_intro -> "→-I"
    | Implies_elim _ -> "→-E"
    | Conj_intro -> "∧-I"
    | Conj_elim i -> "∧-E"
    | Disj_intro1 -> "∨-I1"
    | Disj_intro2 -> "∨-I2"
    | Disj_elim _ -> "∨-E"
    | Forall_intro -> "∀-I"
    | Forall_elim (i, t) -> Printf.sprintf "∀-E(%d,%s)" i (Term.to_string t)
    | Exists_intro _ -> "∃-I"
    | Exists_elim _ -> "∃-E"

  (* FIXME: all the "elim" rules actually need left labels *)
  let left_label_of_rule rule = None

  type partial =
    | Partial_Forall_elim of {
        idx : int;
        variable : string;
        body : Formula.t;
        term : string;
      }
    | Partial_exists_intro of {
        variable : string;
        body : Formula.t;
        term : string;
      }

  let name_of_partial = function
    | Partial_Forall_elim _ -> "∀-E"
    | Partial_exists_intro _ -> "∃-I"

  (* Rule selection *)
  type rule_selector =
    | Immediate of rule
    | Disabled of string
    | Partial of partial

  type selector_group = { group_name : string; rules : rule_selector list }

  let rule_selection assumptions formula =
    let open Fol_formula in
    match formula with
    | True -> [] (* FIXME: do this *)
    | False -> []
    | Atom _ -> []
    | Imp _ ->
        [ { group_name = "Proof rules"; rules = [ Immediate Implies_intro ] } ]
    | And _ ->
        [ { group_name = "Proof rules"; rules = [ Immediate Conj_intro ] } ]
    | Or _ ->
        [
          {
            group_name = "Proof rules";
            rules = [ Immediate Disj_intro1; Immediate Disj_intro2 ];
          };
        ]
    | Not _ -> []
    | Forall _ ->
        [ { group_name = "Proof rules"; rules = [ Immediate Forall_intro ] } ]
    | Exists (x, f) ->
        [
          {
            group_name = "Proof rules";
            rules =
              [
                Partial
                  (Partial_exists_intro { variable = x; body = f; term = "" });
              ];
          };
        ]

  let elim_assumption ~conclusion ~assumption ~idx =
    match assumption with
    | A_Variable _ -> []
    | A_Formula f ->
        let direct =
          if Formula.alpha_equal f conclusion then
            [ ("use directly", `ByAssumption) ]
          else []
        and eliminable =
          match f with
          | Forall (variable, body) ->
              [
                ( "instantiate this assumption",
                  `Partial
                    (Partial_Forall_elim { idx; variable; body; term = "" }) );
              ]
          | Imp (f1, f2) ->
              [ ("use this implication", `Rule (Implies_elim idx)) ]
          | And (f1, f2) ->
              [ ("decompose this assumption", `Rule (Conj_elim idx)) ]
          | Or (f1, f2) ->
              [ ("decompose this assumption", `Rule (Disj_elim idx)) ]
          | Exists _ ->
              [ ("decompose this assumption", `Rule (Exists_elim idx)) ]
          | _ -> []
        in
        direct @ eliminable

  module Part_type = struct
    type t = V | F | T

    let placeholder = function V -> "<var>" | F -> "<formula>" | T -> "<term>"

    let class_ = function
      | V -> "variableinput"
      | F -> "formulainput"
      | T -> "terminput"
  end

  (* Presentation of partials *)
  type partial_formula_part =
    | T of string
    | I of { value : string; typ : Part_type.t; update : string -> partial }
    | F of formula

  type partial_premise = {
    premise_formula : partial_formula_part list;
    premise_assumption : string option;
  }

  type partial_presentation = {
    premises : partial_premise list;
    apply : rule option;
  }

  let present_partial conclusion = function
    | Partial_Forall_elim ({ idx; variable; body; term } as x) ->
        let bits =
          match Fol_formula.Term.of_string term with
          | Some t -> Some (t, Formula.subst variable t body)
          | None -> None
        in
        {
          premises =
            [
              {
                premise_formula =
                  [
                    T "(";
                    F (Forall (variable, body));
                    T (") with " ^ variable ^ ":=");
                    I
                      {
                        value = term;
                        typ = Part_type.T;
                        update =
                          (fun v -> Partial_Forall_elim { x with term = v });
                      };
                  ];
                premise_assumption = None;
              };
              {
                premise_formula = [ F conclusion ];
                premise_assumption =
                  (match bits with
                  | Some (_, inst) -> Some (Formula.to_string inst)
                  | None -> Some "???");
              };
            ];
          apply =
            (match bits with
            | Some (t, _) -> Some (Forall_elim (idx, t))
            | None -> None);
        }
    | Partial_exists_intro ({ variable; body; term } as x) ->
        let bits =
          match Fol_formula.Term.of_string term with
          | Some t -> Some t
          | None -> None
        in
        {
          premises =
            [
              {
                premise_formula =
                  [
                    F body;
                    T "[";
                    T variable;
                    T " := ";
                    I
                      {
                        value = term;
                        typ = Part_type.T;
                        update =
                          (fun term -> Partial_exists_intro { x with term });
                      };
                    T "]";
                  ];
                premise_assumption = None;
              };
            ];
          apply =
            (match bits with Some t -> Some (Exists_intro t) | None -> None);
        }
end
