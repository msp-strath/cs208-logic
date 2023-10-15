let ok = Result.ok

let ( let* ) x f = match x with
  | Ok a -> f a
  | Error _ as e -> e

let ( and* ) : type a b e. (a, e) result -> (b, e) result -> (a * b, e) result =
  fun x y ->
  match x, y with
  | Ok a, Ok b -> Ok (a, b)
  | Error _ as e, _ -> e
  | _, (Error _ as e) -> e

let errorf fmt =
  Printf.ksprintf (fun msg -> Error msg) fmt

let annotate_error annotation = function
  | Ok _ as x -> x
  | Error e -> Error (Annotated.add annotation e)

let traverse : type a b e. (a -> (b, e) result) -> a list -> (b list, e) result =
  fun f xs ->
  let rec loop acc = function
    | [] -> Ok (List.rev acc)
    | x :: xs ->
       (match f x with
        | Ok y -> loop (y :: acc) xs
        | Error _ as e -> e)
  in
  loop [] xs

let fold_left_err : type state a e. (state -> a -> (state, e) result) -> state -> a list -> (state, e) result =
  fun f init xs ->
  let rec loop s = function
    | [] -> Ok s
    | x :: xs -> let* s = f s x in loop s xs
  in
  loop init xs

let traverse_ : type a e. (a -> (unit, e) result) -> a list -> (unit, e) result =
  fun f xs ->
  let rec loop = function
    | [] -> Ok ()
    | x :: xs -> let* () = f x in loop xs
  in
  loop xs

let traverse_array : type a b e. (a -> (b, e) result) -> a array -> (b array, e) result =
  fun f array ->
  let open struct exception Fail_traverse of e end in
  try
    Ok (Array.init
          (Array.length array)
          (fun i -> match f array.(i) with
                    | Ok x -> x
                    | Error e -> raise (Fail_traverse e)))
  with Fail_traverse e -> Error e

let of_option : type a e. on_None:e -> a option -> (a, e) result =
  fun ~on_None a_opt ->
  match a_opt with
  | None -> Error on_None
  | Some a -> Ok a
