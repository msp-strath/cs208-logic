type t

val pp : Format.formatter -> t -> unit
val of_string_unsafe : string -> t
val to_string : t -> string
val iter : (Uchar.t -> unit) -> t -> unit
val for_all : (Uchar.t -> bool) -> t -> bool
val exists : (Uchar.t -> bool) -> t -> bool
val byte_length : t -> int
