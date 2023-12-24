type error =
  [ `Unrecognised_char of int * char
  | `Unfinished_quoted_token of int
  | `Unfinished_escape of int
  | `Invalid_escape of int * char
  ]

(** Turn an {!error} value into a human readable string
    representation. *)
val string_of_error : error -> string

(** [tokenise s] splits the string [s] into tokens. *)
val tokenise : string -> (string list, [> error ]) result
