type t =
  {
    pred_arity : int PredicateMap.t;
  }

let arity predicate_name vocab =
  if predicate_name = "=" then Some 2
  else if predicate_name = "!=" then Some 2
    (* else if predicate_name = "lt" then
       Some 2  (* FIXME: temporary *) *)
  else
    match PredicateMap.find predicate_name vocab.pred_arity with
    | exception Not_found -> None
    | i -> Some i

(* FIXME: prefix error messages with 'In vocab %s'.

   FIXME: location information. *)
let rec of_arities pred_arity = function
  | (nm, arity) :: arities ->
     if arity < 0 then
       Error
         (Printf.sprintf
            "Arity of %s is not a positive number." nm)
     else if PredicateMap.mem nm pred_arity then
       Error
         (Printf.sprintf
            "Duplicate definition of predicate '%s'." nm)
     else
       of_arities (PredicateMap.add nm arity pred_arity) arities
  | [] ->
     Ok { pred_arity }

let of_arities = of_arities PredicateMap.empty
