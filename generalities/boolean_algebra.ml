module type S = sig

  type t

  val one : t

  val zero : t

  val conj : t list -> t

  val disj : t list -> t

  val neg : t -> t

end

module Bool : S with type t = bool = struct
  type t = bool
  let one = true
  let zero = false
  let conj = List.fold_left (&&) true
  let disj = List.fold_left (||) false
  let neg = not
end

module PartialEval (BA : sig
  type t
  val conj : t list -> t
  val disj : t list -> t
  val neg : t -> t
end) =
struct
  type t =
    | True
    | False
    | Indet of BA.t

  let one = True

  let zero = False

  let v x = Indet x

  let conj =
    let rec build ys = function
      | [] -> Indet (BA.conj ys)
      | True::xs -> build ys xs
      | False::_ -> False
      | Indet v::xs -> build (v::ys) xs
    in
    build []

  let disj =
    let rec build ys = function
      | [] -> Indet (BA.disj ys)
      | True::_ -> True
      | False::xs -> build ys xs
      | Indet v::xs -> build (v::ys) xs
    in
    build []

  let neg = function
    | True -> False
    | False -> True
    | Indet v -> Indet (BA.neg v)
end
