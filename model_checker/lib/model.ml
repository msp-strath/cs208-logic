module Entity = struct
  type t = string

  let equal = String.equal
  let compare = String.compare
  let pp fmt s = Format.fprintf fmt "‘%s’" s
  let to_string s = Printf.sprintf "‘%s’" s
end

type entity = Entity.t

module Tuple = struct
  type t = Entity.t list

  let rec compare xs ys =
    match (xs, ys) with
    | [], [] -> 0
    | [], _ :: _ -> -1
    | _ :: _, [] -> 1
    | x :: xs, y :: ys -> (
        match Entity.compare x y with 0 -> compare xs ys | c -> c)

  let pp = Fmt.(hbox (parens (list ~sep:(any ", ") Entity.pp)))
  let to_string e = "(" ^ String.concat "," (List.map Entity.to_string e) ^ ")"
end

module TupleSet = Set.Make (Tuple)

type t = { universe : Entity.t list; relations : TupleSet.t PredicateMap.t }

let contains r tuple interp =
  match PredicateMap.find r interp.relations with
  | set -> TupleSet.mem tuple set
  | exception Not_found -> invalid_arg "invalid predicate symbol"

let pp fmt { universe; relations } =
  let pp_tuple fmt = function
    | [ x ] -> Fmt.string fmt x
    | xs -> Fmt.(parens (list ~sep:(any ", ") string)) fmt xs
  in
  let pp_rel_defn fmt (nm, tuples) =
    Format.fprintf fmt "%s = %a" nm
      Fmt.(braces (hovbox (iter ~sep:(any ",@ ") TupleSet.iter pp_tuple)))
      tuples
  in
  Format.fprintf fmt "@[<v2>model {@,universe = %a,@,%a@]@,}@,"
    Fmt.(braces (hbox (list ~sep:(any ",@ ") string)))
    universe
    Fmt.(iter_bindings ~sep:(any ",@,") PredicateMap.iter pp_rel_defn)
    relations
