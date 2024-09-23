let intersperse y xs =
  let rec head xs () = match xs () with
    | Seq.Nil ->
       Seq.Nil
    | Seq.Cons (x, xs) ->
       Seq.Cons (x, rest xs)
  and rest xs () = match xs () with
    | Seq.Nil ->
       Seq.Nil
    | Seq.Cons (x, xs) ->
       Seq.Cons (y, fun () -> Seq.Cons (x, rest xs))
  in head xs
