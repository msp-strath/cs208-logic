let intersperse y xs =
  let rec head xs () = match xs () with
    | Seq.Nil ->
       Seq.Nil
    | Seq.Cons (x, xs) ->
       Seq.Cons (x, rest xs)
  and rest xs () = match xs () with
    | Seq.Nil ->
       Seq.Nil
    | Seq.Cons (x, xs) ->
       Seq.Cons (y, fun () -> Seq.Cons (x, rest xs))
  in head xs

let is_whitespace = function
  | ' ' | '\t' | '\n' -> true
  | _ -> false

let is_newline = function
  | '\n' -> true
  | _ -> false

type 'tok automaton =
  A : { initial : char -> 's
      ; step    : 's -> char -> 's * 'tok option
      ; eof     : 's -> 'tok
      } -> 'tok automaton

let lines_automaton =
  let initial = function
    | '\n' -> `Newline
    | _    -> `Line
  and step st c = match st, c with
    | `Line, '\n'    -> `Newline, Some `Line
    | `Line, _       -> `Line, None
    | `Newline, '\n' -> `Newline, Some `Break
    | `Newline, _    -> `Line, Some `Break
  and eof = function
    | `Line -> `Line
    | `Newline -> `Break
  in
  A { initial; step; eof }

let words_automaton =
  let initial = function
    | ' ' | '\t' | '\n' -> `Spaces
    | _ -> `Word
  and step st c = match st, c with
    | `Spaces, (' ' | '\t' | '\n') -> `Spaces, None
    | `Spaces, _                   -> `Word, Some `Space
    | `Word,   (' ' | '\t' | '\n') -> `Spaces, Some `Word
    | `Word,   _                   -> `Word, None
  and eof = function
    | `Spaces -> `Space
    | `Word -> `Word
  in
  A { initial; step; eof }

let tokenise (A { initial; step; eof }) str =
  let one_past_end = String.length str in
  let rec scan q i j () =
    if j = one_past_end then
      if i = j then
        Seq.Nil
      else
        let lexeme = String.sub str i (j - i) in
        let token  = eof q in
        Seq.Cons ((lexeme, token), Seq.empty)
    else
      match step q str.[j] with
      | q, None ->
         scan q i (j+1) ()
      | q, Some token ->
         let lexeme = String.sub str i (j - i) in
         Seq.Cons ((lexeme, token), scan q j (j+1))
  in
  if one_past_end = 0 then
    Seq.empty
  else
    scan (initial str.[0]) 0 1

let words str =
  str
  |> tokenise words_automaton
  |> Seq.filter_map (function (word, `Word) -> Some word | _ -> None)

let lines str =
  let rec process seq () =
    match seq () with
    | Seq.Nil -> Seq.Nil
    | Seq.Cons ((line, `Line), seq) ->
       Seq.Cons (line, expect_break seq)
    | Seq.Cons ((_, `Break), seq) ->
       Seq.Cons ("", process seq)
  and expect_break seq () =
    match seq () with
    | Seq.Nil -> Seq.Nil
    | Seq.Cons (_, seq) -> process seq ()
  in
  str
  |> tokenise lines_automaton
  |> process

let head seq =
  match seq () with
  | Seq.Cons (x, _) -> Some x
  | Seq.Nil -> None

module Iter = struct

  let gather_errors f seq =
    let rec loop errors seq =
      match seq () with
      | Seq.Nil ->
         List.rev errors
      | Seq.Cons (x, seq) ->
         (match f x with
          | Ok ()   -> loop errors seq
          | Error e -> loop ((x,e)::errors) seq)
    in
    loop [] seq

end

let rec iter_result f seq =
  match seq () with
  | Seq.Nil ->
     Ok ()
  | Seq.Cons (x, seq) ->
     (match f x with
      | Ok () -> iter_result f seq
      | Error _ as e -> e)
