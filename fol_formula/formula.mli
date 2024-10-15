type t =
  | True
  | False
  | Atom of string * Term.t list
  | Imp of t * t
  | And of t * t
  | Or of t * t
  | Not of t
  | Forall of string * t
  | Exists of string * t
[@@deriving sexp]

val ands : t list -> t
val ors : t list -> t

(** {2 Tests} *)

val is_conjunction : t -> bool
val is_disjunction : t -> bool
val is_implication : t -> bool
val is_negation : t -> bool
val is_truth : t -> bool
val is_lem : t -> bool

(** {2 Printing} *)

val to_string : t -> string

val to_latex : t -> string

val to_doc : t -> Generalities.Pretty.document

(** {2 Queries} *)

val fv : t -> NameSet.t -> NameSet.t

val closed : t -> bool

val alpha_equal : t -> t -> bool

(** {2 Substitution, generalisation, and rewriting} *)

val subst : string -> Term.t -> t -> t

val generalise : Term.t -> t -> string * t

val rewrite : Term.t -> Term.t -> t -> t
