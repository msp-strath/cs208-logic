type ('a, 'b) t = 'a * 'b

let make x y = x, y

let fst (x, _y) = x
let snd (_x, y) = y

let compare cmp1 cmp2 (x1, y1) (x2, y2) =
  match cmp1 x1 x2 with
  | 0 -> cmp2 y1 y2
  | c -> c
