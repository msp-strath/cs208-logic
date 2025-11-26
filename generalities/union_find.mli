type 'a point

val make_class : 'a -> 'a point

val find : 'a point -> 'a

val union : ('a -> 'a -> 'a) -> 'a point -> 'a point -> unit

val update : ('a -> 'a) -> 'a point -> unit

val equal : 'a point -> 'a point -> bool
