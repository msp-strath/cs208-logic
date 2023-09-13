open Traintor

let () =
  let filename = Sys.argv.(1) in
  let decls =
    In_channel.with_open_text filename
      (fun ch ->
        let lexbuf = Lexing.from_channel ch in
        Parser.structure Lexer.token lexbuf)
  in
  match Type_checker.check_declarations decls with
  | Error (location, msg) ->
     let msg = Printf.sprintf "Problem at %a: %s"
                 Ast.Location.to_string location
                 msg
     in
     prerr_endline msg;
     exit 1
  | Ok environment ->
     let result = Evaluator.eval_main environment in
     match result with
     | `True ->
        Printf.printf "Always true"
     | `False ->
        Printf.printf "Always false"
     | `Clauses clauses ->
        List.iter
          (fun clause ->
            print_endline (String.concat " | " (List.map (function (true, a) -> a | (false, a) -> "-" ^ a) clause)))
          clauses
