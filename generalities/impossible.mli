(** The 'impossible' empty type. *)

type t = |

val elim : t -> 'a

val equal : t -> t -> bool

val compare : t -> t -> int

val to_string : t -> string
