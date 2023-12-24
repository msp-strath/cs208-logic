type 'a spec =
  | Unit : unit spec
  | Item : { label : string; parser : 'a String_parser.t } -> 'a spec
  | Prod : 'a spec * 'b spec -> ('a * 'b) spec

type 'a t =
  T : 'b spec * ('b -> 'a) -> 'a t

let map f (T (spec, g)) =
  T (spec, (fun b -> f (g b)))

let ( let+ ) x f = map f x

let prod (T (spec1, g1)) (T (spec2, g2)) =
  T (Prod (spec1, spec2), (fun (a,b) -> (g1 a, g2 b)))

let ( and+ ) = prod

let plain a =
  T (Unit, (fun () -> a))

let item label parser =
  T (Item { label; parser }, Fun.id)

let rec match_spec : type a. a spec -> string list -> (a * string list, _) result =
  fun spec args ->
  match spec with
  | Unit ->
     Ok ((), args)
  | Item { label; parser } ->
     (match args with
      | [] -> Error `TooFewArguments
      | arg::args ->
         (match parser arg with
          | Error msg -> Error (`BadArgument (label, msg))
          | Ok a -> Ok (a, args)))
  | Prod (spec1, spec2) ->
     (match match_spec spec1 args with
      | Ok (a, args) ->
         (match match_spec spec2 args with
          | Ok (b, args) ->
             Ok ((a,b), args)
          | Error _ as e -> e)
      | Error _ as e -> e)

let rec spec_to_strings : type a. a spec -> string list -> string list =
  fun spec accum ->
  match spec with
  | Unit ->
     accum
  | Item { label; _ } ->
     label::accum
  | Prod (spec1, spec2) ->
     spec_to_strings spec1 (spec_to_strings spec2 accum)

let match_command : type a. a t -> string list -> (a, _) result =
  fun (T (spec, f)) tokens ->
  match match_spec spec tokens with
  | Ok (b, [])   -> Ok (f b)
  | Ok (_, _::_) -> Error `TooManyArguments
  | Error e      -> Error e

type 'a commands = (string * 'a t) list

type error =
  [ Simple_tokeniser.error
  | `NoCommand
  | `NoSuchCommand of string
  | `TooManyArguments
  | `TooFewArguments
  | `BadArgument of string * string
  ]

let string_of_error : error -> string =
  function
  | #Simple_tokeniser.error as tokenisation_error ->
     Simple_tokeniser.string_of_error tokenisation_error
  | `NoCommand ->
     "No command provided"
  | `NoSuchCommand provided_command ->
     Printf.sprintf "no such command %S" provided_command
  | `TooManyArguments ->
     Printf.sprintf "too many arguments provided" (* FIXME: more info *)
  | `TooFewArguments ->
     Printf.sprintf "too few arguments provided" (* FIXME: more info *)
  | `BadArgument (label, msg) ->
     Printf.sprintf "expecting a %s, but %s" label msg (* FIXME: more info, like position *)

let parse_command : type a. a commands -> string list -> (a, [>error]) result =
  fun commands tokens ->
  match tokens with
  | [] ->
     Error `NoCommand
  | command::arguments ->
     (match List.assoc_opt command commands with
      | None ->
         Error (`NoSuchCommand command)
      | Some spec ->
         match_command spec arguments)

let of_string : type a. a commands -> string -> (a, string) result =
  fun commands input ->
  let open Result_ext in
  Result.map_error string_of_error
    (let* tokens = Simple_tokeniser.tokenise input in
     parse_command commands tokens)
