(** Compare two lists of different types. If the lists have different
    lengths then return [false]. Otherwise, is equivalent to
    [List.for_all2]. *)
val hequal : ('a -> 'b -> bool) -> 'a list -> 'b list -> bool
