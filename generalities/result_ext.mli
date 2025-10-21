(** Extensions to the {!Stdlib.Result} module. *)

(** {2 Failure} *)

val errorf : ('a, unit, string, ('b, string) result) format4 -> 'a

val annotate_error : 'annot -> ('a, 'e) result -> ('a, ('e, 'annot) Annotated.t) result

val of_predicate : on_error:'e -> ('a -> bool) -> 'a -> ('a, 'e) result

val check_false : on_error:'e -> bool -> (unit, 'e) result

val check_true : on_error:'e -> bool -> (unit, 'e) result

val of_option : on_error:'e -> 'a option -> ('a, 'e) result

(** {2 Syntax} *)

module Syntax : sig

  val ( let* ) : ('a, 'e) result -> ('a -> ('b, 'e) result) -> ('b, 'e) result

  val ( and* ) : ('a, 'e) result -> ('b, 'e) result -> ('a * 'b, 'e) result

  val ( let+ ) : ('a, 'e) result -> ('a -> 'b) -> ('b, 'e) result

  val ( and+ ) : ('a, 'e) result -> ('b, 'e) result -> ('a * 'b, 'e) result

end

(** {2 List and Array Functions} *)

val traverse : ('a -> ('b, 'e) result) -> 'a list -> ('b list, 'e) result

val fold_left_err : ('state -> 'a -> ('state, 'e) result) -> 'state -> 'a list -> ('state, 'e) result

val traverse_ : ('a -> (unit, 'e) result) -> 'a list -> (unit, 'e) result

val traverse_array : ('a -> ('b, 'e) result) -> 'a array -> ('b array, 'e) result
