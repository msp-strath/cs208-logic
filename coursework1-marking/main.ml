(* Plan:

   - Load in the .answers file and the specimen solutions

   - For each question, do a parse of the answer, and then compare the output to the specimen

   - To mark each question:

   1a: Check that results are equal, up to reordering
   1b: Check that results are equal, up to reordering
   1c: Check that results are equal, up to reordering
   1d: Check that results are equal, up to reordering

   2:
     (0) Check that 'package' has not been changed
     (a) Check equivalence of depends for all package pairs
     (b) Check equivalence of conflict
     (c) Check equivalence of dependencies and conflicts
     (d) Check equivalence of requirements
     (e) Check equivalence of whole thing

   3:
     Check overall equivalence vs v1 and v2

   4:

 *)

(* To check the equivalence of two structures:

 *)

let read_answers_file filename =
  In_channel.with_open_text filename
    (fun ch ->
      Seq.of_dispenser (fun () -> In_channel.input_line ch)
      |> Seq.map
           (fun line ->
             Scanf.sscanf line "%s@:%S" (fun fieldname data -> fieldname, data))
      |> List.of_seq)

let ( let* ) x f = match x with
  | Error _ as e -> e
  | Ok a -> f a

let parse_and_typecheck string =
  let open Slakemoth in
  let* decls = Reader.parse string in
  let* commands = Type_checker.check_declarations decls in
  Ok commands

let questions =
  [ "cw1-question1a", 1
  ; "cw1-question1b", 1
  ; "cw1-question1c", 3
  ; "cw1-question2", 4
  ; "cw1-question3", 3
  ; "cw1-question4a", 3
  ; "cw1-question4b", 2
  ; "cw1-question4c", 3 (* this one should be done by checking the generated json *)
  ]

let add_negated_clauses solver clauses =
  let open Slakemoth in
  let x =
    Solver.add_disj solver
      (List.map
         (fun clause ->
           let clause' =
             List.map (function (true, v) -> Solver.add_not solver v
                              | (false, v) -> v)
               clause
           in
           Solver.add_conj solver clause')
         clauses)
  in
  Solver.add_assert solver x

(* let pair_equal eq_x eq_y (x1,y1) (x2,y2) = *)
(*   eq_x x1 x2 && eq_y y1 y2 *)

(* Plan:
   -
 *)

(*
let merge_environments env1 env2 =
  let open Slakemoth in
  let open Ast in
  let open Environment in
  let* () =
    if NameMap.equal DomainInfo.equal env1.domains env2.domains then
      Ok ()
    else
      Error `Domain_mismatch (* FIXME: where? what? *)
  in
  let* defns =
    NameMap.merge (fun name defn1 defn2 ->
        match defn1, defn2 with
        | Some (Atom args1), Some (Atom args2) ->
           if List.equal (pair_equal String.equal String.equal) args1 args2 then
             Some (Atom args1)
           else
             failwith "Atom mismatch"
        | Some (Defn
 *)


(*
let check_contains (env1, constraints1) (env2, constraints2) =
  let open Slakemoth in
  let solver = Solver.create () in
  let atom_table = Hashtbl.create 1024 in
  let module E = Evaluator.Eval (val (Evaluator.assignment_of_solver solver atom_table)) in
  let clauses1 = E.to_clauses (E.eval env1 E.empty_local_env constraints1) in
  let clauses2 = E.to_clauses (E.eval env2 E.empty_local_env constraints2) in
  List.iter (Solver.add_clause solver) clauses1;
  add_negated_clauses solver clauses2;
  match Solver.solve solver with
  | `UNSAT -> true
  | `SAT _vals ->
     (* Printf.printf "Atoms: {"; *)
     (* Hashtbl.to_seq atom_table *)
     (* |> Seq.iter (fun (nm, v) -> Printf.printf " %s(%b)" nm (vals v)); *)
     (* Printf.printf "}\n"; *)
     false (* FIXME: say what the separating valuation is *)
 *)

(* FIXME: for question4c, check that the answer produced matches the spec *)

let do_question specimen submission question_id =
  let* expected =
    List.assoc_opt question_id specimen
    |> Option.to_result ~none:`Specimen_missing
  in
  let* submitted =
    List.assoc_opt question_id submission
    |> Option.to_result ~none:`Submission_missing
  in
  let* () = if submitted = "" then Error `No_submission else Ok () in
  let* expected = parse_and_typecheck expected in
  let* submitted = parse_and_typecheck submitted in
  let open Slakemoth in
  match expected, submitted with
  | [ Environment.AllSat (expected_env, expected_constraints, expected_json) ],
    [ Environment.AllSat (sub_env, sub_constraints, sub_json) ] ->
     let expected = Evaluator.all_sat expected_env expected_constraints expected_json in
     let submitted = Evaluator.all_sat sub_env sub_constraints sub_json in
     if expected = submitted then Ok ()
     else Error `Solution_mismatch
     (* let expected = (expected_env, expected_constraints) in *)
     (* let submitted = (submitted_env, submitted_constraints) in *)
     (* (\* FIXME: Check that the environments agree on the domain *)
     (*    definitions, and then that the constraints are equal in the *)
     (*    sense that there is nothing that distinguishes them. *\) *)
     (* (match check_contains expected submitted, *)
     (*        check_contains submitted expected with *)
     (*  | true, true -> Ok () *)
     (*  | false, true -> Error `Not_enough_solutions *)
     (*  | true, false -> Error `Too_many_solutions *)
     (*  | false, false -> Error `Solution_mismatch) *)
  | _, [] ->
     Error `Missing_allsat
  | _ ->
     Error `Dont_match

let () =
  let specimen = Sys.argv.(1) in
  let filename = Sys.argv.(2) in
  let specimen = read_answers_file specimen in
  let submission = read_answers_file filename in
  List.iter (fun (question_id, _available_marks) ->
      match do_question specimen submission question_id with
      | Ok () -> Printf.printf "%s: OK\n" question_id
      | Error (`Parse err) ->
         Printf.printf "%s: PARSE ERROR %s\n" question_id (Parser_util.Driver.string_of_error err)
      | Error (`Type_error (_loc, msg)) -> Printf.printf "%s: TYPE ERROR %s\n" question_id msg
      | Error `Specimen_missing ->
         Printf.printf "%s: SPECIMEN MISSING\n" question_id
      | Error `Submission_missing ->
         Printf.printf "%s: SUBMISSION MISSING\n" question_id
      | Error `Dont_match ->
         Printf.printf "%s: DONT MATCH\n" question_id
      | Error `Missing_allsat ->
         Printf.printf "%s: MISSING ALLSAT\n" question_id
      | Error `No_submission ->
         Printf.printf "%s: No SUBMISSION\n" question_id
      | Error `Not_enough_solutions ->
         Printf.printf "%s: NOT ENOUGH SOLUTIONS\n" question_id
      | Error `Too_many_solutions ->
         Printf.printf "%s: TOO MANY SOLUTIONS\n" question_id
      | Error `Solution_mismatch ->
         Printf.printf "%s: SOLUTION_MISMATCH\n" question_id
    )
    questions
