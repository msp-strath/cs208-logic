open Sexplib0.Sexp_conv
open Fol_formula

module System : sig
  type goal = formula [@@derving sexp]
  type formula = goal

  type rule =
    | Implies_intro
    | Implies_elim of formula
    | Conj_intro
    | Conj_elim1 of formula
    | Conj_elim2 of formula
    | Disj_intro1
    | Disj_intro2
    | Disj_elim of formula * formula
    | True_intro
    | False_elim
    | Not_intro
    | Not_elim of formula
    | RAA
    | DNE
    | LEM
  [@@deriving sexp]

  include
    Proof_tree.CALCULUS
      with type goal := goal
       and type assumption = formula
       and type rule := rule
       and type error = [ `Msg of string ]
end = struct
  type formula = Fol_formula.formula [@@deriving sexp]
  type goal = formula
  type update = unit

  let unify_with_assumption f1 f2 =
    if f1 = f2 then Ok () else Error (`Msg "assumption does not match")

  type assumption = formula

  let empty_update = ()
  let update_assumption () f = f
  let update_goal () f = f

  type rule =
    | Implies_intro
    | Implies_elim of formula
    | Conj_intro
    | Conj_elim1 of formula
    | Conj_elim2 of formula
    | Disj_intro1
    | Disj_intro2
    | Disj_elim of formula * formula
    | True_intro
    | False_elim
    | Not_intro
    | Not_elim of formula
    | RAA
    | DNE
    | LEM
  [@@deriving sexp]

  type error = [ `Msg of string ]

  let apply rule formula =
    match rule with
    | Implies_intro -> (
        match formula with
        | Imp (f1, f2) -> Ok [ ([ ("x", f1) ], f2) ]
        | _ -> Error (`Msg "implies_intro: formula is not an implication"))
    | Implies_elim f -> Ok [ ([], Imp (f, formula)); ([], f) ]
    | Conj_intro -> (
        match formula with
        | And (f1, f2) -> Ok [ ([], f1); ([], f2) ]
        | _ -> Error (`Msg "conj_intro: formula is not a conjunction"))
    | Conj_elim1 f -> Ok [ ([], And (formula, f)) ]
    | Conj_elim2 f -> Ok [ ([], And (f, formula)) ]
    | Disj_intro1 -> (
        match formula with
        | Or (f1, f2) -> Ok [ ([], f1) ]
        | _ -> Error (`Msg "disj_intro1: formula is not a disjunction"))
    | Disj_intro2 -> (
        match formula with
        | Or (f1, f2) -> Ok [ ([], f2) ]
        | _ -> Error (`Msg "disj_intro2: formula is not a disjunction"))
    | Disj_elim (f1, f2) ->
        Ok
          [
            ([], Or (f1, f2)); ([ ("x", f1) ], formula); ([ ("y", f2) ], formula);
          ]
    | True_intro -> (
        match formula with
        | True -> Ok []
        | _ -> Error (`Msg "true_intro: formula is not 'True'"))
    | False_elim -> Ok [ ([], False) ]
    | Not_intro -> (
        match formula with
        | Not f -> Ok [ ([ ("x", f) ], False) ]
        | _ -> Error (`Msg "not_intro: formula is not a negation"))
    | Not_elim f -> Ok [ ([], Not f); ([], f) ]
    | RAA -> Ok [ ([ ("x", Not formula) ], False) ]
    | DNE -> Ok [ ([], Not (Not formula)) ]
    | LEM -> (
        match formula with
        | Or (f, Not f') when f = f' ->
            (* FIXME: a proper equality *)
            Ok []
        | _ -> Error (`Msg "lem: formula is not an instance of LEM"))

  let apply assumps rule goal =
    match apply rule goal with
    | Ok subgoals -> Ok (subgoals, ())
    | Error err -> Error err
end

module Partials : sig
  include Proof_tree_UI.PARTIALS with module Calculus = System
  (* module Partial : Data.ABLE with type t = partial*)
end = struct
  module Calculus = System
  open Calculus

  let name_of_rule = function
    | Implies_intro -> "→-I"
    | Implies_elim _ -> "→-E"
    | Conj_intro -> "∧-I"
    | Conj_elim1 _ -> "∧-E1"
    | Conj_elim2 _ -> "∧-E2"
    | Disj_intro1 -> "∨-I1"
    | Disj_intro2 -> "∨-I2"
    | Disj_elim _ -> "∨-E"
    | True_intro -> "⊤-I"
    | False_elim -> "⊥-E"
    | Not_intro -> "¬-I"
    | Not_elim _ -> "¬-E"
    | RAA -> "PBC"
    | LEM -> "LEM"
    | DNE -> "¬¬-E"

  let left_label_of_rule rule = None

  type partial =
    | Partial_Implies_elim of string
    | Partial_Conj_elim1 of string
    | Partial_Conj_elim2 of string
    | Partial_Disj_elim of string * string
    | Partial_Not_elim of string
  [@@deriving sexp]

  let name_of_partial = function
    | Partial_Implies_elim _ -> "→-E"
    | Partial_Conj_elim1 _ -> "∧-E1"
    | Partial_Conj_elim2 _ -> "∧-E2"
    | Partial_Disj_elim _ -> "∨-E"
    | Partial_Not_elim _ -> "¬-E"

  (* Rule selection *)
  type rule_selector =
    | Immediate of rule
    | Disabled of string
    | Partial of partial

  type selector_group = { group_name : string; rules : rule_selector list }

  let rule_selection assumptions formula =
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
        group_name = "Negation (¬)";
        rules =
          [
            (if Formula.is_negation formula then Immediate Not_intro
            else Disabled "¬-I");
            Partial (Partial_Not_elim "");
          ];
      };
      {
        group_name = "True (⊤)";
        rules =
          [
            (if Formula.is_truth formula then Immediate True_intro
            else Disabled "⊤-I");
          ];
      };
      { group_name = "False (⊥)"; rules = [ Immediate False_elim ] };
      {
        group_name = "Classical logic";
        rules =
          [
            Immediate RAA;
            Immediate DNE;
            (if Formula.is_lem formula then Immediate LEM else Disabled "LEM");
          ];
      };
    ]

  let elim_assumption ~conclusion ~assumption ~idx = []

  module Part_type = struct
    type t = unit

    let placeholder () = "<formula>"
    let class_ () = "formulainput"
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
                        typ = ();
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
                        typ = ();
                        update = (fun v -> Partial_Implies_elim v);
                      };
                  ];
                premise_assumption = None;
              };
            ];
          apply =
            (match Formula.of_string str_formula with
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
                        typ = ();
                        update = (fun v -> Partial_Conj_elim1 v);
                      };
                  ];
                premise_assumption = None;
              };
            ];
          apply =
            (match Formula.of_string str_formula with
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
                        typ = ();
                        update = (fun v -> Partial_Conj_elim2 v);
                      };
                    T "∧";
                    F conclusion;
                  ];
                premise_assumption = None;
              };
            ];
          apply =
            (match Formula.of_string str_formula with
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
                        typ = ();
                        update = (fun v -> Partial_Disj_elim (v, str_f2));
                      };
                    T "∨";
                    I
                      {
                        value = str_f2;
                        typ = ();
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
            (match (Formula.of_string str_f1, Formula.of_string str_f2) with
            | Error _, _ | _, Error _ -> None
            | Ok f1, Ok f2 -> Some (Disj_elim (f1, f2)));
        }
    | Partial_Not_elim str_f ->
        {
          premises =
            [
              {
                premise_formula =
                  [
                    T "¬";
                    I
                      {
                        value = str_f;
                        typ = ();
                        update = (fun v -> Partial_Not_elim v);
                      };
                  ];
                premise_assumption = None;
              };
              {
                premise_formula =
                  [
                    I
                      {
                        value = str_f;
                        typ = ();
                        update = (fun v -> Partial_Not_elim v);
                      };
                  ];
                premise_assumption = None;
              };
            ];
          apply =
            (match Formula.of_string str_f with
            | Error _ -> None
            | Ok f -> Some (Not_elim f));
        }
end
