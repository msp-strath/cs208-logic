open Sexplib0.Sexp_conv

type term = Term.t =
  | Var of string
  | Fun of string * term list
[@@deriving sexp]

type formula = Formula.t =
  | True
  | False
  | Atom of string * term list
  | Imp of formula * formula
  | And of formula * formula
  | Or of formula * formula
  | Not of formula
  | Forall of string * formula
  | Exists of string * formula
[@@deriving sexp]

module NameSet = NameSet

module Term = struct
  include Term

  let of_string = Reader.term_of_string
end

module Formula = struct
  include Formula

  let of_string = Reader.formula_of_string
end
