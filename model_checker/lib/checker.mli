open Fol_formula

type refutation =
  | IsFalse
  | Equal of term * Model.entity * term
  | NotEqual of term * Model.entity * term * Model.entity
  | NotInRelation of string * term list * Model.entity list
  | ConclFalse of verification * refutation
  | AndLeft of refutation * formula
  | AndRight of formula * refutation
  | OrFail of refutation * refutation
  | NotTrue of verification
  | ForallFail of string * Model.entity * refutation
  | ExistsFail of string * formula * (Model.entity * refutation) list

and verification =
  | IsTrue
  | Equal of term * Model.entity * term
  | NotEqual of term * Model.entity * term * Model.entity
  | InRelation of string * term list * Model.entity list
  | HypFalse of refutation * formula
  | ConclTrue of formula * verification
  | And of verification * verification
  | OrLeft of verification * formula
  | OrRight of formula * verification
  | NotFalse of refutation
  | ForallSuc of string * formula * (Model.entity * verification) list
  | ExistsSuc of string * Model.entity * verification

type outcome = Verified of verification | Refuted of refutation

val pp_refutation : Format.formatter -> refutation -> unit
val pp_verification : Format.formatter -> verification -> unit
val pp_outcome : Format.formatter -> outcome -> unit
val check_closed : Model.t -> formula -> outcome
