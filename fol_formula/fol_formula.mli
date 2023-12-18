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

module NameSet : sig
  include Set.S with type elt = string and type t = NameSet.t

  val fresh_for : t -> string -> string
end

module Term : sig
  include module type of Term

  val of_string : string -> (t, [> `Parse of Parser_util.Driver.error]) result
end

module Formula : sig
  include module type of Formula

  val of_string : string -> (t, [>`Parse of Parser_util.Driver.error ]) result
end
