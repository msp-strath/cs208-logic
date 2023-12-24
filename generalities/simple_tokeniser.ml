let is_whitespace_char = function
  | ' ' | '\t' | '\n' -> true
  | _ -> false

let is_bareword_char = function
  | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '-' | '<' | '>' -> true
  | _ -> false

type error =
  [ `Unrecognised_char of int * char
  | `Unfinished_quoted_token of int
  | `Unfinished_escape of int
  | `Invalid_escape of int * char
  ]

let string_of_error : error -> string =
  function
  | `Unrecognised_char (idx, c) ->
     Printf.sprintf "unrecoginised character %C at position %d" c idx
  | `Unfinished_quoted_token start_idx ->
     Printf.sprintf "unfinished quoted section starting at position %d" start_idx
  | `Unfinished_escape idx ->
     Printf.sprintf "unfinished '\\' escape at position %d" idx
  | `Invalid_escape (idx, c) ->
     Printf.sprintf "unrecognised escape character %C at position %d" c idx

let tokenise string =
  let len = String.length string in
  let buf  = Buffer.create len in
  let rec get_words rev_args i =
    if i = len then
      Ok (List.rev rev_args)
    else if is_whitespace_char string.[i] then
      get_words rev_args (i+1)
    else if is_bareword_char string.[i] then
      get_bareword rev_args i (i+1)
    else if string.[i] = '"' then
      get_quoteword rev_args i (i+1)
    else
      Error (`Unrecognised_char (i, string.[i]))
  and get_bareword rev_args start i =
    if i = len then
      let word = String.sub string start (i - start) in
      Ok (List.rev (word :: rev_args))
    else if is_whitespace_char string.[i] then
      let word = String.sub string start (i - start) in
      get_words (word :: rev_args) (i+1)
    else if string.[i] ='"' then
      let word = String.sub string start (i - start) in
      get_quoteword (word :: rev_args) i (i+1)
    else if is_bareword_char string.[i] then
      get_bareword rev_args start (i+1)
    else
      Error (`Unrecognised_char (i, string.[i]))
  and get_quoteword rev_args start i =
    match string.[i] with
    | exception _ ->
       Error (`Unfinished_quoted_token start)
    | '"' ->
       let word = Buffer.contents buf in
       Buffer.clear buf;
       get_words (word :: rev_args) (i+1)
    | '\\' ->
       (match string.[i+1] with
        | exception _ ->
           Error (`Unfinished_escape i)
        | '"' ->
           Buffer.add_char buf '"';
           get_quoteword rev_args start (i+1)
        | c ->
           Error (`Invalid_escape (i, c)))
    | c ->
       Buffer.add_char buf c;
       get_quoteword rev_args start (i+1)
  in
  get_words [] 0

(********** Tests **********)

let%test "tokenise_empty" =
  tokenise " " = Ok []

let%test "tokenise_1" =
  tokenise "a" = Ok ["a"]

let%test "tokenise_2" =
  tokenise "a b" = Ok ["a"; "b"]

let%test "tokenise_3" =
  tokenise "a b \"c d\"" = Ok ["a"; "b"; "c d"]

let%test "tokenise_err_1" =
  tokenise "\x00" = Error (`Unrecognised_char (0, '\x00'))

let%test "tokenize_err_2" =
  tokenise "\"a b c" = Error (`Unfinished_quoted_token 0)
