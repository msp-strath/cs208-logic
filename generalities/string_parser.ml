type 'a t =
  string -> ('a, string) result

let valid_name str =
  let is_alpha = function 'A' .. 'Z' | 'a' .. 'z' | '_' -> true | _ -> false
  and is_alphanum = function
    | 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '-' | '_' -> true
    | _ -> false
  in
  String.length str > 0
  && is_alpha str.[0]
  && String.for_all is_alphanum str

let name =
  Result_ext.of_predicate ~on_error:"not an alphanumeric identifier" valid_name
