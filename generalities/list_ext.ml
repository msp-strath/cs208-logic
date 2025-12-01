(* Heterogeneous list comparison *)
let rec hequal elem_eq xs ys =
  match xs, ys with
  | [], [] ->
     true
  | x::xs, y::ys ->
     elem_eq x y && hequal elem_eq xs ys
  | _ ->
     false
