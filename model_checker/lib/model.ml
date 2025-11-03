open Generalities

let parens doc = Pretty.(text "(" ^^ doc ^^ text ")")
let curly doc = Pretty.(text "{" ^^ doc ^^ text "}")
let comma = Pretty.text ", "

module Entity = struct
  type t = string

  let equal = String.equal
  let compare = String.compare
  let pp s = Pretty.textf "‘%s’" s
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

  let pp = function
    | [ x ] ->
       Entity.pp x
    | xs ->
       parens
         (xs |> List.to_seq |> Seq.map Entity.pp |> Seq_ext.intersperse comma |> Pretty.concat)

  let to_string e = "(" ^ String.concat "," (List.map Entity.to_string e) ^ ")"
end

let pp_as_set items_seq =
  let open Pretty in
  text "{"
  ^^ group
       (nest 2
          (break
           ^^ (items_seq
               |> Seq_ext.intersperse Pretty.(comma ^^ group break)
               |> Pretty.concat)))
  ^^ break ^^ text "}"

module TupleSet = Set.Make (Tuple)

let pp_tupleset tupleset =
  pp_as_set (tupleset |> TupleSet.to_seq |> Seq.map Tuple.pp)

type t =
  { universe : Entity.t list
  ; relations : TupleSet.t PredicateMap.t
  }

let contains r tuple interp =
  match PredicateMap.find r interp.relations with
  | set -> TupleSet.mem tuple set
  | exception Not_found -> invalid_arg "invalid predicate symbol"

let pp { universe; relations } =
  let open Pretty in
  let universe_doc =
    group (nest 2 (text "universe = " ^^ break ^^ pp_as_set (universe |> List.to_seq |> Seq.map Entity.pp)))
  in
  let pp_relation (nm, tuples) =
    group (nest 2 (text nm ^^ text " =" ^^ break ^^ pp_tupleset tuples))
  in
  group
    (text "model {"
     ^^ nest 2
          (break
           ^^ (relations
               |> PredicateMap.to_seq
               |> Seq.map pp_relation
               |> Seq.cons universe_doc
               |> Seq_ext.intersperse break
               |> concat))
     ^^ break ^^ text "}")

(*

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
  Format.fprintf fmt "@[<v2>model {@,universe = {@[<h>%a@]}@,%a@]@,}@,"
    (Format.pp_print_list ~pp_sep:pp_comma_brk Format.pp_print_string)
    universe
    (Format.pp_print_seq pp_rel_defn)
    (PredicateMap.to_seq relations)
 *)
