(** Representation of terms *)

type t =
  | Var of string
  | Fun of string * t list
[@@deriving sexp]

val compare : t -> t -> int

(** {2 Printing} *)

val to_string : t -> string

val to_doc : t -> Generalities.Pretty.document

val to_doc_prec : int -> t -> Generalities.Pretty.document

val to_latex : t -> string

val pp : Format.formatter -> t -> unit

val pp_tms : Format.formatter -> t list -> unit

(** {2 Queries} *)

val fv : t -> NameSet.t -> NameSet.t

val equal : t -> t -> bool

val equal_open : (string * string) list -> t -> t -> bool

val subst : string -> t -> t -> t
