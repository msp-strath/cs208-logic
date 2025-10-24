open Fol_formula

type assumption =
  | A_Termvar
  | A_Formula of formula
[@@deriving sexp]

type goal =
  | Checking of formula
  | Synthesis of formula * formula
[@@deriving sexp]

type rule =
  (* introduction rules *)
  | Introduce of string
  | Truth
  | Split
  | Left
  | Right
  | Exists of term
  | NotIntro of string
  | Refl
  | Induction of string
  (* Focusing *)
  | Use of string
  (* On Focused goals *)
  | Implies_elim
  | Instantiate of term
  | Conj_elim1
  | Conj_elim2
  | Cases of string * string
  | ExElim of string * string
  | Absurd
  | NotElim
  | Subst of string * formula
  | Rewrite of [ `ltr | `rtl ]
  | Close

  | Auto
[@@deriving sexp]

module Rule : sig
  type t = rule

  val name : t -> string
end

include
  Proof_tree.CALCULUS
    with type assumption := assumption
     and type update = unit
     and type goal := goal
     and type rule := rule
     and type error = string
