open Ctypes
open Foreign

let pikchr_fn =
  foreign
    "pikchr"
    (string @-> string_opt @-> uint @-> ptr int @-> ptr int @-> returning (ptr char))

let pikchr ~src ?class_ () =
  let width = allocate int 0 in
  let height = allocate int 0 in
  let buf = pikchr_fn src class_ Unsigned.UInt.zero width height in
  let width = !@ width in
  let height = !@ height in
  let length = foreign "strlen" (ptr char @-> returning size_t) buf in
  let text = string_from_ptr buf ~length:(Unsigned.Size_t.to_int length) in
  let () = foreign "free" (ptr char @-> returning void) buf in
  if width >= 0 then
    Ok (text, width, height)
  else
    Error text
