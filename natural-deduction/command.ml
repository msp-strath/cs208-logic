type command =
  { root : string
  ; args : string list
  }

type 'a p = string -> ('a, string) result

type ('a, 'b) spec =
  | End  : ('a, 'a) spec
  | Step : { label : string; parser : 'a p; rest : ('b, 'c) spec } -> ('a -> 'b, 'c) spec

type error =
  [ `BadArg of string * string
  | `NoSuchCommand of string
  | `No_commmand
  | `TooFewArguments
  | `TooManyArguments
  | `TwoManyArguments
  | `Unfinished_quoted_arg of int
  | `Unrecognised_char of int * char ]

let rec match_spec : type a b. (a, b) spec -> string list -> a -> (b, [>error]) result =
  fun spec args func ->
  match spec, args with
  | End, [] ->
     Ok func
  | End, _::_ ->
     Error `TooManyArguments
  | Step { label; parser; rest }, arg::args ->
     (match parser arg with
      | Error msg -> Error (`BadArg (label, msg))
      | Ok a -> match_spec rest args (func a))
  | Step _, [] ->
     Error `TooFewArguments

type 'a command_spec =
  Spec : { argspec : ('f, 'a) spec; builder : 'f } -> 'a command_spec

let e = End
let (@->) (label, parser) rest =
  Step { label; parser; rest }

let cmd argspec builder =
  Spec { argspec; builder }

let match_command commands { root; args } =
  match List.assoc_opt root commands with
  | None ->
     Error (`NoSuchCommand root)
  | Some (Spec { argspec; builder }) ->
     match_spec argspec args builder

module Parsing = struct

  let is_whitespace_char = function
    | ' ' | '\t' | '\n' -> true
    | _ -> false

  let is_bareword_char = function
    | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '-' | '<' | '>' -> true
    | _ -> false

  let parse string =
    let len = String.length string in
    let rec get_root i =
      if i = len then
        (if i = 0 then
           Error `No_commmand
         else
           Ok { root = string; args = [] })
      else if is_whitespace_char string.[i] then
        let root = String.sub string 0 i in
        get_args root [] (i+1)
      else if is_bareword_char string.[i] then
        get_root (i+1)
      else if string.[i] = '"' then
        let root = String.sub string 0 i in
        get_quoteword root [] (i+1) (i+1)
      else
        Error (`Unrecognised_char (i, string.[i]))
    and get_args root rev_args i =
      if i = len then
        Ok { root; args = List.rev rev_args }
      else if is_whitespace_char string.[i] then
        get_args root rev_args (i+1)
      else if is_bareword_char string.[i] then
        get_bareword root rev_args i (i+1)
      else if string.[i] = '"' then
        get_quoteword root rev_args (i+1) (i+1)
      else
        Error (`Unrecognised_char (i, string.[i]))
    and get_bareword root rev_args start i =
      if i = len then
        let word = String.sub string start (i - start) in
        Ok { root; args = List.rev (word :: rev_args) }
      else if is_whitespace_char string.[i] then
        let word = String.sub string start (i - start) in
        get_args root (word :: rev_args) (i+1)
      else if string.[i] ='"' then
        let word = String.sub string start (i - start) in
        get_quoteword root (word :: rev_args) (i+1) (i+1)
      else if is_bareword_char string.[i] then
        get_bareword root rev_args start (i+1)
      else
        Error (`Unrecognised_char (i, string.[i]))
    and get_quoteword root rev_args start i =
      if i = len then
        Error (`Unfinished_quoted_arg start)
      else if string.[i] = '"' then
        let word = String.sub string start (i - start) in
        get_args root (word :: rev_args) (i+1)
      else
        get_quoteword root rev_args start (i+1)
    in
    get_root 0
end

let parse_command commands str =
  match Parsing.parse str with
  | Ok command ->
     match_command commands command
  | Error _ as e ->
     e
