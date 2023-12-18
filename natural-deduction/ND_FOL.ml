open Sexplib0.Sexp_conv

module System = struct
  type term = Fol_formula.term [@@deriving sexp]
  type formula = Fol_formula.formula [@@deriving sexp]
  type goal = formula

  module Formula = Fol_formula.Formula
  module Term = Fol_formula.Term

  type rule =
    | Assumption of int
    | Implies_intro
    | Implies_elim of formula
    | Conj_intro
    | Conj_elim1 of formula
    | Conj_elim2 of formula
    | Disj_intro1
    | Disj_intro2
    | Disj_elim of formula * formula
    | Forall_elim of int * term * formula
    | Forall_intro
    | Exists_intro of term
    | Exists_elim of int * formula
  [@@deriving sexp]

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
  let update_goal () f = f
  let update_assumption () a = a

  open Fol_formula

  let freshen_for_assumps_and_goal x assumps goal =
    let fv_of_assump = function
      | _, A_Formula f -> Formula.fv f
      | _, A_Variable x -> NameSet.add x
    in
    let vars =
      NameSet.empty |> Formula.fv goal |> List.fold_right fv_of_assump assumps
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

  let assumption idx = Assumption idx

  let apply assumps rule formula =
    match rule with
    | Assumption idx -> (
        match get_assumption idx assumps with
        | None -> Error (`Msg "no such assumption")
        | Some (_, assump) -> (
            match unify_with_assumption formula assump with
            | Ok () -> Ok []
            | Error e -> Error e))
    | Implies_intro -> (
        match formula with
        | Imp (f1, f2) -> Ok [ ([ ("x", A_Formula f1) ], f2) ]
        | _ -> Error (`Msg "implies_intro: formula is not an implication"))
    | Implies_elim f -> Ok [ ([], Imp (f, formula)); ([], f) ]
    | Conj_intro -> (
        match formula with
        | And (f1, f2) -> Ok [ ([], f1); ([], f2) ]
        | _ -> Error (`Msg "conj_intro: does not apply here"))
    | Conj_elim1 f -> Ok [ ([], And (formula, f)) ]
    | Conj_elim2 f -> Ok [ ([], And (f, formula)) ]
    | Disj_intro1 -> (
        match formula with
        | Or (f1, f2) -> Ok [ ([], f1) ]
        | _ -> Error (`Msg "disj_intro1: does not apply here"))
    | Disj_intro2 -> (
        match formula with
        | Or (f1, f2) -> Ok [ ([], f2) ]
        | _ -> Error (`Msg "disj_intro2: does not apply here"))
    | Disj_elim (f1, f2) ->
        Ok
          [
            ([], Or (f1, f2));
            ([ ("x", A_Formula f1) ], formula);
            ([ ("y", A_Formula f2) ], formula);
          ]
    | Forall_intro -> (
        match formula with
        | Forall (x, f) ->
            let x0 = freshen_for_assumps_and_goal x assumps f in
            let f = Formula.subst x (Var x0) f in
            Ok [ ([ ("x", A_Variable x0) ], f) ]
        | _ -> Error (`Msg "forall_intro: formula is not a forall"))
    | Forall_elim (assump_idx, tm, _) -> (
        match get_assumption assump_idx assumps with
        | Some (_, A_Formula (Forall (x, body))) ->
            let inst_f = Formula.subst x tm body in
            Ok [ ([ ("x", A_Formula inst_f) ], formula) ]
        | Some _ -> Error (`Msg "forall_elim: assumption is not a forall")
        | None -> Error (`Msg "forall_elim: no such assumption"))
    | Exists_intro t -> (
        match formula with
        | Exists (x, f) ->
            let f = Formula.subst x t f in
            Ok [ ([], f) ]
        | _ -> Error (`Msg "exists_intro: formula is not an existential"))
    | Exists_elim (assump_idx, _) -> (
        match get_assumption assump_idx assumps with
        | Some (_, A_Formula (Exists (x, body))) ->
            let x0 = freshen_for_assumps_and_goal x assumps formula in
            let f = Formula.subst x (Var x0) body in
            Ok [ ([ ("x", A_Variable x0); ("p", A_Formula f) ], formula) ]
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
    | Assumption _ -> "assumption"
    | Implies_intro -> "→-I"
    | Implies_elim _ -> "→-E"
    | Conj_intro -> "∧-I"
    | Conj_elim1 _ -> "∧-E1"
    | Conj_elim2 _ -> "∧-E2"
    | Disj_intro1 -> "∨-I1"
    | Disj_intro2 -> "∨-I2"
    | Disj_elim _ -> "∨-E"
    | Forall_intro -> "∀-I"
    | Forall_elim (i, t, _) -> "∀-E"
    | Exists_intro _ -> "∃-I"
    | Exists_elim _ -> "∃-E"

  let left_label_of_rule = function
    | Forall_elim (_, _, f) -> Some ("Using " ^ Formula.to_string f)
    | Exists_elim (_, f) -> Some ("Using " ^ Formula.to_string f)
    | _ -> None

  type partial =
    | Partial_Implies_elim of string
    | Partial_Conj_elim1 of string
    | Partial_Conj_elim2 of string
    | Partial_Disj_elim of string * string
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
  [@@deriving sexp]

  let name_of_partial = function
    | Partial_Implies_elim _ -> "→-E"
    | Partial_Conj_elim1 _ -> "∧-E1"
    | Partial_Conj_elim2 _ -> "∧-E2"
    | Partial_Disj_elim _ -> "∨-E"
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
    [
      {
        group_name = "Implication (→)";
        rules =
          [
            (if Formula.is_implication formula then Immediate Implies_intro
            else Disabled "→-I");
            Partial (Partial_Implies_elim "");
          ];
      };
      {
        group_name = "Conjunction (∧)";
        rules =
          [
            (if Formula.is_conjunction formula then Immediate Conj_intro
            else Disabled "∧-I");
            Partial (Partial_Conj_elim1 "");
            Partial (Partial_Conj_elim2 "");
          ];
      };
      {
        group_name = "Disjunction (∨)";
        rules =
          [
            (if Formula.is_disjunction formula then Immediate Disj_intro1
            else Disabled "∨-I1");
            (if Formula.is_disjunction formula then Immediate Disj_intro2
            else Disabled "∨-I2");
            Partial (Partial_Disj_elim ("", ""));
          ];
      };
      {
        group_name = "Quantifiers";
        rules =
          [
            (match formula with
            | Forall _ -> Immediate Forall_intro
            | _ -> Disabled "∀-I");
            (match formula with
            | Exists (x, f) ->
                Partial
                  (Partial_exists_intro { variable = x; body = f; term = "" })
            | _ -> Disabled "∃-I");
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
                ( "instantiate this ∀",
                  `Partial
                    (Partial_Forall_elim { idx; variable; body; term = "" }) );
              ]
          | Exists _ -> [ ("decompose this ∃", `Rule (Exists_elim (idx, f))) ]
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
    | Partial_Implies_elim str_formula ->
        {
          premises =
            [
              {
                premise_formula =
                  [
                    I
                      {
                        value = str_formula;
                        typ = Part_type.F;
                        update = (fun v -> Partial_Implies_elim v);
                      };
                    T "→";
                    F conclusion;
                  ];
                premise_assumption = None;
              };
              {
                premise_formula =
                  [
                    I
                      {
                        value = str_formula;
                        typ = Part_type.F;
                        update = (fun v -> Partial_Implies_elim v);
                      };
                  ];
                premise_assumption = None;
              };
            ];
          apply =
            (match Fol_formula.Formula.of_string str_formula with
            | Error _ -> None
            | Ok f -> Some (Implies_elim f));
        }
    | Partial_Conj_elim1 str_formula ->
        {
          premises =
            [
              {
                premise_formula =
                  [
                    F conclusion;
                    T "∧";
                    I
                      {
                        value = str_formula;
                        typ = Part_type.F;
                        update = (fun v -> Partial_Conj_elim1 v);
                      };
                  ];
                premise_assumption = None;
              };
            ];
          apply =
            (match Fol_formula.Formula.of_string str_formula with
            | Error _ -> None
            | Ok f -> Some (Conj_elim1 f));
        }
    | Partial_Conj_elim2 str_formula ->
        {
          premises =
            [
              {
                premise_formula =
                  [
                    I
                      {
                        value = str_formula;
                        typ = Part_type.F;
                        update = (fun v -> Partial_Conj_elim2 v);
                      };
                    T "∧";
                    F conclusion;
                  ];
                premise_assumption = None;
              };
            ];
          apply =
            (match Fol_formula.Formula.of_string str_formula with
            | Error _ -> None
            | Ok f -> Some (Conj_elim2 f));
        }
    | Partial_Disj_elim (str_f1, str_f2) ->
        {
          premises =
            [
              {
                premise_formula =
                  [
                    I
                      {
                        value = str_f1;
                        typ = Part_type.F;
                        update = (fun v -> Partial_Disj_elim (v, str_f2));
                      };
                    T "∨";
                    I
                      {
                        value = str_f2;
                        typ = Part_type.F;
                        update = (fun v -> Partial_Disj_elim (str_f1, v));
                      };
                  ];
                premise_assumption = None;
              };
              {
                premise_formula = [ F conclusion ];
                premise_assumption = Some str_f1;
              };
              {
                premise_formula = [ F conclusion ];
                premise_assumption = Some str_f2;
              };
            ];
          apply =
            (match
               ( Fol_formula.Formula.of_string str_f1,
                 Fol_formula.Formula.of_string str_f2 )
             with
            | Error _, _ | _, Error _ -> None
            | Ok f1, Ok f2 -> Some (Disj_elim (f1, f2)));
        }
    | Partial_Forall_elim ({ idx; variable; body; term } as x) ->
        let bits =
          match Fol_formula.Term.of_string term with
          | Ok t -> Some (t, Formula.subst variable t body)
          | Error _ -> None
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
            | Some (t, _) ->
                Some (Forall_elim (idx, t, Forall (variable, body)))
            | None -> None);
        }
    | Partial_exists_intro ({ variable; body; term } as x) ->
        let bits =
          match Fol_formula.Term.of_string term with
          | Ok t -> Some t
          | Error _ -> None
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
