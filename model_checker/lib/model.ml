open Format_util

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

  let pp fmt =
    Format.fprintf fmt "(%a)"
      (Format.pp_print_list ~pp_sep:pp_comma_spc Entity.pp)

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
    | [ x ] -> Format.pp_print_string fmt x
    | xs ->
       Format.fprintf fmt "(%a)"
         (Format.pp_print_list ~pp_sep:pp_comma_spc Format.pp_print_string)
         xs
  in
  let pp_rel_defn fmt (nm, tuples) =
    Format.fprintf fmt "%s = {@[<hov>%a@]}" nm
      (Format.pp_print_seq ~pp_sep:pp_comma_brk pp_tuple)
      (TupleSet.to_seq tuples)
  in
  Format.fprintf fmt "@[<v2>model {@,universe = {@[<h>%a@]},@,%a@]@,}@,"
    (Format.pp_print_list ~pp_sep:pp_comma_brk Format.pp_print_string)
    universe
    (Format.pp_print_seq ~pp_sep:pp_comma_cut pp_rel_defn)
    (PredicateMap.to_seq relations)
