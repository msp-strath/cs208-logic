type json =
  | JString of string
  | JBool of bool
  | JInt of int
  | JArray of json list
  | JNull
  | JObject of (string * json) list
[@@deriving compare]

module Printing = struct
  let pp_comma = Fmt.(styled `Bold comma)

  (* FIXME: move to a Utf8_string module *)
  let json_escape fmt s =
    let s = Utf8_string.of_string_unsafe s in
    (* FIXME *)
    let b = Buffer.create (Utf8_string.byte_length s + 4) in
    let escape_char c =
      if c = Uchar.of_char '"' then Buffer.add_char b '"'
      else if c = Uchar.of_char '\\' then Buffer.add_char b '\\'
      else if c = Uchar.of_char '\n' then Buffer.add_string b "\\n"
      else if c = Uchar.of_char '\x0c' then Buffer.add_string b "\\f"
      else if c = Uchar.of_char '\t' then Buffer.add_string b "\\t"
      else if c = Uchar.of_char '\r' then Buffer.add_string b "\\r"
      else if c = Uchar.of_char '\b' then Buffer.add_string b "\\b"
      else Buffer.add_utf_8_uchar b c
    in
    Utf8_string.iter escape_char s;
    Fmt.buffer fmt b

  let pp_string = Fmt.(styled (`Fg `Blue) @@ styled `Bold @@ quote json_escape)
  let pp_delim = Fmt.(styled `Bold string)

  let rec pp fmt = function
    | JString s -> pp_string fmt s
    | JBool true -> Format.pp_print_string fmt "true"
    | JBool false -> Format.pp_print_string fmt "false"
    | JInt i -> Format.pp_print_int fmt i
    (*  | Float f -> Format.pp_print_float fmt f (* FIXME: proper format *) *)
    | JNull -> Format.pp_print_string fmt "null"
    | JArray [] -> Fmt.(styled `Bold (any "[]")) fmt ()
    | JArray elems ->
       Format.fprintf fmt "%a@,@[<v2>  %a@]@,%a"
         pp_delim "["
         (Format.pp_print_list ~pp_sep:pp_comma pp) elems
         pp_delim "]"
    | JObject [] -> Fmt.(styled `Bold (any "{}")) fmt ()
    | JObject fields ->
        Format.fprintf fmt "%a@,@[<v2>  %a@]@,%a" pp_delim "{"
          (Format.pp_print_list ~pp_sep:pp_comma pp_field)
          fields pp_delim "}"

  and pp_field fmt (nm, json) = Format.fprintf fmt "%a: %a" pp_string nm pp json
end
