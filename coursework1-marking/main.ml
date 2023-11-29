(* FIXME: use generalities *)
let ( let* ) x f = match x with
  | Error _ as e -> e
  | Ok a -> f a

let on_false err = function
  | true -> Ok ()
  | false -> Error err


let read_answers_file filename =
  In_channel.with_open_text filename
    (fun ch ->
      Seq.of_dispenser (fun () -> In_channel.input_line ch)
      |> Seq.map
           (fun line ->
             Scanf.sscanf line "%s@:%S" (fun fieldname data -> fieldname, data))
      |> List.of_seq)

let parse_and_typecheck string =
  let open Slakemoth in
  let* decls = Reader.parse string in
  let* commands = Type_checker.check_declarations decls in
  Ok commands

let questions =
  [ "cw1-question1a",
    "Question 1(a)",
    1,
    `One "atom a\natom b\natom c\natom d\n\nallsat (a | b | c | d)\n  { \"a\": a, \"b\": b, \"c\": c, \"d\": d }\n"
  ; "cw1-question1b",
    "Question 1(b)",
    1,
    `One "atom a\natom b\natom c\natom d\n\nallsat ((a | b | c | d) &\n        (~a | ~b) &\n        (~a | ~c) &\n        (~a | ~d) &\n        (~b | ~c) &\n        (~b | ~d) &\n        (~c | ~d))\n  { \"a\": a, \"b\": b, \"c\": c, \"d\": d }\n"
  ; "cw1-question1c",
    "Question 1(c)",
    3,
    `One "atom a\natom b\natom c\n\nallsat ((a | b | c) &\n        (~a | b | c) &\n        (~b | a | c) &\n        (~c | a | b) &\n        (~a | ~b | ~c))\n  { \"a\": a, \"b\": b, \"c\": c }\n"
  ; "cw1-question2",
    "Question 2",
    4,
    `One "domain package {\n  ChatServer, MailServer1, MailServer2,\n  Database1, Database2, GitServer\n}\n\natom installed(p : package)\n\ndefine depends(p : package, dependency : package) {\n  // fill this in\n  ~installed(p) | installed(dependency)\n}\n\ndefine conflict(p1 : package, p2 : package) {\n  // fill this in\n  ~installed(p1) | ~installed(p2)\n}\n\ndefine depends_or(p : package,\n                  dependency1 : package,\n                  dependency2 : package) {\n  // fill this in\n  ~installed(p) | installed(dependency1) | installed(dependency2)\n}\n\ndefine dependencies_and_conflicts {\n  // fill this in\n  depends_or(ChatServer, MailServer1, MailServer2) &\n  depends_or(ChatServer, Database1, Database2) &\n  conflict(MailServer1, MailServer2) &\n  conflict(Database1, Database2) &\n  depends(GitServer, Database2)\n}\n\ndefine requirements {\n  // fill this in\n  installed(ChatServer) & installed(GitServer)\n}\n\nallsat(dependencies_and_conflicts & requirements)\n  { for(packageName : package)\n      packageName : installed(packageName)\n  }\n"
  ; "cw1-question3",
    "Question 3",
    3,
    `Alt ("domain machine { M1, M2, M3 }\ndomain task { T1, T2, T3, T4, T5 }\n\n// If assign(t,m) is true, then task 't'\n// is assigned to machine 'm'.\natom assign(t : task, m : machine)\n\ndefine all_tasks_some_machine {\n  forall(t : task) some(m : machine) assign(t,m)\n}\n\ndefine all_tasks_one_machine {\n  forall(t : task)\n    forall(m1: machine)\n      forall(m2 : machine)\n        m1 = m2 | ~assign(t,m1) | ~assign(t,m2)\n}\n\ndefine separate_machines(task1 : task, task2 : task) {\n  forall(m : machine) ~assign(task1, m) | ~assign(task2, m)\n}\n\ndefine conflicts {\n  // fill_this_in\n  separate_machines(T1,T2) &\n  separate_machines(T2,T3) &\n  separate_machines(T2,T5) &\n  separate_machines(T3,T4) &\n  separate_machines(T3,T5)\n}\n\ndefine special_cases {\n  // fill_this_in\n  ~assign(T1,M3) &\n  ~assign(T1,M1) &\n  ~assign(T2,M1) &\n  ~assign(T3,M3) &\n  (forall(m : machine) ~assign(T2,m) | assign(T4,m))\n}\n\ndefine main {\n  all_tasks_some_machine &\n  all_tasks_one_machine &\n  conflicts &\n  special_cases\n}\n\nallsat(main)\n  { for (t : task)\n      t:[for (m : machine)\n           if (assign(t, m)) m]\n  }\n",
          "domain machine { M1, M2, M3 }\ndomain task { T1, T2, T3, T4, T5 }\n\n// If assign(t,m) is true, then task 't'\n// is assigned to machine 'm'.\natom assign(t : task, m : machine)\n\ndefine all_tasks_some_machine {\n  forall(t : task) some(m : machine) assign(t,m)\n}\n\ndefine all_tasks_one_machine {\n  forall(t : task)\n    forall(m1: machine)\n      forall(m2 : machine)\n        m1 = m1 | ~assign(t,m1) | ~assign(t,m2)\n}\n\ndefine separate_machines(task1 : task, task2 : task) {\n  forall(m : machine) ~assign(task1, m) | ~assign(task2, m)\n}\n\ndefine conflicts {\n  // fill_this_in\n  separate_machines(T1,T2) &\n  separate_machines(T2,T3) &\n  separate_machines(T2,T5) &\n  separate_machines(T3,T4) &\n  separate_machines(T3,T5)\n}\n\ndefine special_cases {\n  // fill_this_in\n  ~assign(T1,M3) &\n  ~assign(T1,M1) &\n  ~assign(T2,M1) &\n  ~assign(T3,M3) &\n  (forall(m : machine) ~assign(T2,m) | assign(T4,m))\n}\n\ndefine main {\n  all_tasks_some_machine &\n  all_tasks_one_machine &\n  conflicts &\n  special_cases\n}\n\nallsat(main)\n  { for (t : task)\n      t:[for (m : machine)\n           if (assign(t, m)) m]\n  }\n")
  ; "cw1-question4a",
    "Question 4(a)",
    3,
    `One "domain node { Input1, Input2, Output }\n\natom active(n : node)\n\ndefine xor(x : node, y : node, z : node) {\n  // fill_this_in\n  (~active(x) |  active(y) |  active(z)) &\n  (~active(x) | ~active(y) | ~active(z)) &\n  ( active(x) |  active(y) | ~active(z)) &\n  ( active(x) | ~active(y) |  active(z))\n}\n\nallsat (xor(Output, Input1, Input2))\n { \"Input1\": active(Input1), \"Input2\": active(Input2), \"Output\": active(Output) }\n"
  ; "cw1-question4b",
    "Question 4(b)",
    2,
    `One "domain node { I1, I2, S, Cout }\n\natom active(n : node)\n\ndefine xor(x : node, y : node, z : node) {\n  // put your definition here\n  (~active(x) |  active(y) |  active(z)) &\n  (~active(x) | ~active(y) | ~active(z)) &\n  ( active(x) |  active(y) | ~active(z)) &\n  ( active(x) | ~active(y) |  active(z))\n}\n\n// Use this\ndefine and(x : node, y : node, z : node) {\n  (~active(x) | active(y)) &\n  (~active(x) | active(z)) &\n  ( active(x) | ~active(y) | ~active(z))\n}\n\ndefine half-adder(input1 : node, input2 : node, sum : node, carry : node) {\n  // fill_this_in\n  xor(sum, input1, input2) &\n  and(carry, input1, input2)\n}\n\nallsat (half-adder (I1, I2, S, Cout))\n  { for(n : node) n : active(n) }\n"
  ; "cw1-question4c",
    "Question 4(c)",
    3,
    `Show_result
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

let check_contains env constraint1 constraint2 =
  let open Slakemoth in
  let solver = Solver.create () in
  let atom_table = Hashtbl.create 1024 in
  let module E = Evaluator.Eval (val (Evaluator.assignment_of_solver solver atom_table)) in
  let clauses1 = E.to_clauses (E.eval env E.empty_local_env constraint1) in
  let clauses2 = E.to_clauses (E.eval env E.empty_local_env constraint2) in
  List.iter (Solver.add_clause solver) clauses1;
  add_negated_clauses solver clauses2;
  match Solver.solve solver with
  | `UNSAT -> `CONTAINED
  | `SAT vals ->
     let assignment = Evaluator.assignment_of_vals atom_table vals in
     `EXTRA assignment

let rec rename_term rho term =
  let open Slakemoth.Ast in
  match term.detail with
  | Apply (name, args) ->
     (let args = List.map (rename_term rho) args in
      match NameMap.find_opt name.detail rho with
      | None -> {term with detail = Apply (name, args) }
      | Some renamed -> {term with detail = Apply ({ name with detail = renamed }, args)})
  | IntConstant _ | StrConstant _ | Constructor _ | True | False ->
     term
  | Eq (term1, term2) ->
     let term1 = rename_term rho term1 in
     let term2 = rename_term rho term2 in
     { term with detail = Eq (term1, term2) }
  | Ne (term1, term2) ->
     let term1 = rename_term rho term1 in
     let term2 = rename_term rho term2 in
     { term with detail = Ne (term1, term2) }
  | Neg term1 ->
     let term1 = rename_term rho term1 in
     { term with detail = Neg term1 }
  | Or terms ->
     let terms = List.map (rename_term rho) terms in
     { term with detail = Or terms }
  | And terms ->
     let terms = List.map (rename_term rho) terms in
     { term with detail = And terms }
  | Implies (term1, term2) ->
     let term1 = rename_term rho term1 in
     let term2 = rename_term rho term2 in
     { term with detail = Implies (term1, term2) }
  | BigOr (nm, domain, term1) ->
     let rho = NameMap.remove nm rho in
     let term1 = rename_term rho term1 in
     { term with detail = BigOr (nm, domain, term1) }
  | BigAnd (nm, domain, term1) ->
     let rho = NameMap.remove nm rho in
     let term1 = rename_term rho term1 in
     { term with detail = BigAnd (nm, domain, term1) }
  | JSONObject _ | JSONArray _ | For _ | If _ | Sequence _ | Assign _ ->
     failwith "RENAME JSON"


let merge_environments env1 env2 =
  (* 1. Check that all the domains are the same *)
  (* 2. Check that all the atoms are the same *)
  (* 3. Rename all the definitions *)
  let open Slakemoth.Environment in
  let open Slakemoth.Ast in
  let* () = on_false `Domain_mismatch
              (NameMap.equal DomainInfo.equal env1.domains env2.domains) in
  let rename1 =
    NameMap.to_seq env1.defns
    |> Seq.filter (function _, Defined _ -> true | _ -> false)
    |> Seq.map (fun (nm, _) -> nm, nm ^ "#1")
    |> NameMap.of_seq
  in
  let rename2 =
    NameMap.to_seq env2.defns
    |> Seq.filter (function _, Defined _ -> true | _ -> false)
    |> Seq.map (fun (nm, _) -> nm, nm ^ "#2")
    |> NameMap.of_seq
  in
  let merged, defns2 =
    NameMap.fold
      (fun name defn (merged, env2) ->
        match defn with
        | Atom { args } ->
           (match NameMap.find_opt name env2 with
            | None -> failwith "Missing atom in env2"
            | Some (Atom { args = args2 }) ->
               if args = args2 then
                 (NameMap.add name (Atom { args}) merged, NameMap.remove name env2)
               else
                 failwith "Changed atom declaration"
            | Some (Defined _) ->
               failwith "atom has become definition")
        | Defined { args; body } ->
           let name = name ^ "#1" in
           let rename1 = List.fold_right (fun (nm, _) -> NameMap.remove nm) args rename1 in
           let body = rename_term rename1 body in
           let defn = Defined { args; body } in
           (NameMap.add name defn merged, env2))
      env1.defns
      (NameMap.empty, env2.defns)
  in
  let defns =
    NameMap.fold
      (fun name defn merged ->
        match defn with
        | Atom _ -> failwith "Extra atom definition"
        | Defined { args; body } ->
           let name = name ^ "#2" in
           let rename2 = List.fold_right (fun (nm, _) -> NameMap.remove nm) args rename2 in
           let body = rename_term rename2 body in
           let defn = Defined { args; body } in
           NameMap.add name defn merged)
      defns2
      merged
  in
  Ok ({ env1 with defns }, rename1, rename2)






(* FIXME: for question4c, check that the answer produced matches the spec *)

let q4c_filter =
  let open Slakemoth.Json in
  function
  | JObject fields ->
     JObject (List.filter
                (fun (nm, _) -> nm = "Input1" || nm = "Input2" || nm = "Input3")
                fields)
  | json -> json

let evaluate submission =
  let open Slakemoth in
  let* submitted = parse_and_typecheck submission in
  match submitted with
  | [Environment.AllSat (env, constraint_term, json)] ->
     Ok (Evaluator.all_sat env constraint_term json)
  | _ ->
     Error `Unexpected_commands

let do_question specimen submission =
  let* expected = parse_and_typecheck specimen in
  let* submitted = parse_and_typecheck submission in
  let open Slakemoth in
  match expected, submitted with
  | [ Environment.AllSat (expected_env, expected_constraint, expected_json) ],
    [ Environment.AllSat (sub_env, sub_constraint, sub_json) ] ->
     let* (env, rename1, rename2) = merge_environments expected_env sub_env in
     let expected = rename_term rename1 expected_constraint in
     let submitted = rename_term rename2 sub_constraint in
     (match check_contains env expected submitted,
            check_contains env submitted expected with
      | `CONTAINED, `CONTAINED -> Ok ()
      | `EXTRA assgn, `CONTAINED ->
         let module E2 = Evaluator.Eval (val assgn) in
         let json = E2.to_json (E2.eval env E2.empty_local_env expected_json) in
         Error (`Not_enough_solutions json)
      | `CONTAINED, `EXTRA assgn ->
         let module E2 = Evaluator.Eval (val assgn) in
         let json = E2.to_json (E2.eval env E2.empty_local_env sub_json) in
         Error (`Too_many_solutions json)
      | `EXTRA expected, `EXTRA submitted ->
         let expected_json =
           let module E = Evaluator.Eval (val expected) in
           E.to_json (E.eval env E.empty_local_env expected_json)
         and submitted_json =
           let module E = Evaluator.Eval (val submitted) in
           E.to_json (E.eval env E.empty_local_env sub_json)
         in
         Error (`Solution_mismatch (expected_json, submitted_json)))
  | _, _ ->
     Error `Unexpected_commands

let list_to_string p l =
  String.concat " " (List.map p l)

let print_err =
  let open Omd.Ctor in
  function
  | `Parse err ->
     [p [txt (Printf.sprintf "I was unable to parse your submission: %s"
                (Parser_util.Driver.string_of_error err))]
     ]
  | `Type_error (_loc, msg) ->
     [p [txt (Printf.sprintf "There was an error trying to interpret \
                              your submission: %s" msg)]
     ]
  | `Unexpected_commands ->
     [p [txt (Printf.sprintf "Your submission had unexpected commands in it.")]]
  | `Domain_mismatch ->
     [p [txt "There was a mismatch in the domain definitions, so I was \
              unable to mark this submission automatically."]]
  | `Not_enough_solutions expected_json ->
     [p [txt "Your code does not produce enough solutions. The \
              following solution is not generated by your constraints:"]
     ; code_bl (Slakemoth.Json.Printing.to_string expected_json)
     ]
  | `Too_many_solutions unwanted_json ->
     [p [txt "Your code produces too many solutions. The following \
              solution is generated by your constraints, but is not \
              required by the solution:"]
     ; code_bl (Slakemoth.Json.Printing.to_string unwanted_json)
     ]
  | `Solution_mismatch (expected, submitted) ->
     [ p [txt "Your code produces solutions that are not required, and \
               misses solutions that are required. The following is an \
               example of a solution that your code should produce but \
               does not:"]
     ; code_bl (Slakemoth.Json.Printing.to_string expected)
     ; p [txt "This is an example of a solution that you code produces \
               but should not:"]
     ; code_bl (Slakemoth.Json.Printing.to_string submitted)
     ]

let seq_head seq = match seq () with
  | Seq.Cons (x, _) -> x
  | Seq.Nil -> failwith "empty sequence"

let get_file_of_dir dirname =
  Sys.readdir dirname
  |> Array.to_seq
  |> Seq.filter (fun entry -> not (String.starts_with ~prefix:"." entry))
  |> seq_head

let mark_question submission (question_id, question_title, marks, solution) =
  match List.assoc_opt question_id submission with
  | None | Some "" ->
     let open Omd.Ctor in
     [ h 3 [txt question_title]
     ; p [txt "No solution submitted!"]
     ]
  | Some submitted ->
     let given_marks, message =
       match solution with
       | `One solution ->
          (match do_question solution submitted with
           | Ok () -> Some marks, Ok ()
           | Error err -> Some 0, Error (print_err err))
       | `Alt (solution1, solution2) ->
          (match do_question solution1 submitted with
           | Ok () -> Some marks, Ok ()
           | Error _err ->
              match do_question solution2 submitted with
              | Ok () -> Some marks, Ok ()
              | Error err -> Some 0, Error (print_err err))
       | `Show_result ->
          match evaluate submitted with
          | Ok jsons ->
             let open Omd.Ctor in
             None, Error
                     [ p [txt "The solutions generated by this code are:"]
                     ; code_bl (String.concat "\n"
                                  (List.map Slakemoth.Json.Printing.to_string jsons))
                     ]
          | Error err ->
             Some 0, Error (print_err err)
     in
     let open Omd.Ctor in
     ([ h 3 [txt question_title;
             txt (Printf.sprintf " (%s/%d)"
                    (match given_marks with None -> "?" | Some n -> string_of_int n)
                    marks)]
      ; p [txt "Your solution"]
      ; code_bl submitted
      ]@
        (match message with
         | Ok () -> [p [txt "This solution is correct!"]]
         | Error doc -> doc))

module To_markdown = struct
  open Omd

  let rec inline b = function
    | Concat (_, inlines) ->
       List.iter (inline b) inlines
    | Text (_, str) ->
       Buffer.add_string b str
    | Emph (_, content) ->
       Buffer.add_string b "*";
       inline b content;
       Buffer.add_string b "*"
    | Strong (_, content) ->
       Buffer.add_string b "**";
       inline b content;
       Buffer.add_string b "**"
    | Code _ | Hard_break _ | Soft_break _ | Link _ | Image _ | Html _ ->
       failwith "UNIMPLEMETED"

  let block b = function
    | Paragraph (_, contents) ->
       inline b contents;
       Buffer.add_string b "\n\n"
    | Heading (_, n, contents) ->
       Buffer.add_string b (String.make n '#');
       Buffer.add_string b " ";
       inline b contents;
       Buffer.add_string b "\n\n"
    | Code_block (_, _, code) ->
       Printf.bprintf b "```\n%s\n```\n\n" code
    | _ ->
       failwith "UNIMPLEMENTED"

  let string_of_doc blocks =
    let b = Buffer.create 8192 in
    List.iter (block b) blocks;
    Buffer.contents b
end

let () =
  let dir = Sys.argv.(1) in
  let dirname = Filename.concat dir "submissions" in
  Sys.mkdir Filename.(concat dir "feedback") 0o700;
  Sys.readdir dirname
  |> Array.to_seq
  |> Seq.filter (fun entry -> not (String.starts_with ~prefix:"." entry))
  |> Seq.iter (fun entry ->
         let sub_dir = Filename.concat dirname entry in
         let filename = get_file_of_dir sub_dir in
         let filename = Filename.concat sub_dir filename in
         try
           let submission = read_answers_file filename in
           let doc = List.concat_map (mark_question submission) questions in
           Sys.mkdir Filename.(concat (concat dir "feedback") entry) 0o700;
           Out_channel.with_open_bin
             Filename.(concat (concat (concat dir "feedback") entry) "feedback.md")
             (fun ch -> Out_channel.output_string ch (To_markdown.string_of_doc doc))
         with exn ->
           Printf.printf "FAILED: %s; %s\n" entry (Printexc.to_string exn))
