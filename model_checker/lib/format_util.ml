let pp_comma_spc fmt () =
  Format.pp_print_string fmt ", "

let pp_comma_brk fmt () =
  Format.pp_print_string fmt ",@ "

let pp_comma_cut fmt () =
  Format.pp_print_string fmt ",@,"

let str format =
  let buf = Buffer.create 1024 in
  let fmt = Format.formatter_of_buffer buf in
  Format.kfprintf
    (fun fmt ->
      Format.pp_print_flush fmt ();
      Buffer.contents buf)
    fmt
    format
