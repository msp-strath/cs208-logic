type t = string

let pp fmt s = Format.pp_print_string fmt s
let of_string_unsafe s = s
let to_string s = s

let iter f s =
  let rec loop i =
    match String.get_utf_8_uchar s i with
    | exception Invalid_argument _ -> ()
    | decode when Uchar.utf_decode_is_valid decode ->
        f (Uchar.utf_decode_uchar decode);
        loop (i + Uchar.utf_decode_length decode)
    | _ -> invalid_arg "itf8: invalid utf8"
  in
  loop 0

let byte_length s = String.length s

exception False
exception True

let for_all pred s =
  try
    iter (fun c -> if not (pred c) then raise False) s;
    true
  with False -> false

let exists pred s =
  try
    iter (fun c -> if pred c then raise True) s;
    false
  with True -> true
