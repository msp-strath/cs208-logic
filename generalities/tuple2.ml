type ('a, 'b) t = 'a * 'b

let make x y = x, y

let fst (x, _y) = x
let snd (_x, y) = y
