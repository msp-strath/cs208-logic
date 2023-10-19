type t = { pred_arity : int PredicateMap.t }

let arity predicate_name vocab =
  if predicate_name = "=" then Some 2
  else if predicate_name = "!=" then Some 2
    (* else if predicate_name = "lt" then
       Some 2  (* FIXME: temporary *) *)
  else
    match PredicateMap.find predicate_name vocab.pred_arity with
    | exception Not_found -> None
    | i -> Some i
