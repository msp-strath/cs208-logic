type ('a, 'b) spec

type 'a p = string -> ('a, string) result

val e : ('a, 'a) spec
val (@->) : (string * 'a p) -> ('b, 'c) spec -> ('a -> 'b, 'c) spec

type 'a command_spec

val cmd : ('a, 'b) spec -> 'a -> 'b command_spec

type error =
  [ `BadArg of string * string
  | `NoSuchCommand of string
  | `No_commmand
  | `TooFewArguments
  | `TooManyArguments
  | `TwoManyArguments
  | `Unfinished_quoted_arg of int
  | `Unrecognised_char of int * char ]

val parse_command : (string * 'c command_spec) list -> string -> ('c, [>error]) result
