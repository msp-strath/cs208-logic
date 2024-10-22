open Generalities
open Result_ext.Syntax

let add_negated_clauses solver clauses =
  let x =
    Solver.add_disj solver
      (List.map
         (fun clause ->
           let clause' =
             List.map
               (function (true, v)  -> Solver.add_not solver v
                       | (false, v) -> v)
               clause
           in
           Solver.add_conj solver clause')
         clauses)
  in
  Solver.add_assert solver x

let check_contains env constraint1 constraint2 =
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
  let open Ast in
  match term.detail with
  | Apply (name, args) ->
     (let args = List.map (rename_term rho) args in
      match NameMap.find_opt name.detail rho with
      | None -> {term with detail = Apply (name, args) }
      | Some renamed -> {term with detail = Apply ({ name with detail = renamed }, args)})
  | StrConstant _ | Constructor _ | True | False ->
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
  | Next _ | The _ ->
     failwith "RENAME NEW STUFF"

let merge_environments (env1 : Environment.environment) (env2 : Environment.environment) =
  (* 1. Check that all the domains are the same *)
  (* 2. Check that all the atoms are the same *)
  (* 3. Rename all the definitions *)
  let open Environment in
  let open Ast in
  let* () =
    Result_ext.check_true ~on_error:`Domain_mismatch
      (NameMap.equal DomainInfo.equal env1.domains env2.domains)
  in
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
            | Some (Defined _ | Table _) ->
               failwith "atom has become definition")
        | Table _ ->
           failwith "TABLES"
        | Defined { args; body; kind } ->
           let name = name ^ "#1" in
           let rename1 = List.fold_right (fun (nm, _) -> NameMap.remove nm) args rename1 in
           let body = rename_term rename1 body in
           let defn = Defined { args; body; kind } in
           (NameMap.add name defn merged, env2))
      env1.defns
      (NameMap.empty, env2.defns)
  in
  let defns =
    NameMap.fold
      (fun name defn merged ->
        match defn with
        | Atom _ -> failwith "Extra atom definition"
        | Table _ -> failwith "TABLE"
        | Defined { args; body; kind } ->
           let name = name ^ "#2" in
           let rename2 = List.fold_right (fun (nm, _) -> NameMap.remove nm) args rename2 in
           let body = rename_term rename2 body in
           let defn = Defined { args; body; kind } in
           NameMap.add name defn merged)
      defns2
      merged
  in
  Ok ({ env1 with defns }, rename1, rename2)


let do_question expected submitted =
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

module type DOCUMENT = sig
  type block
  type inline

  val txt : string -> inline
  val p : inline list -> block
  val code_bl : string -> block

end

let print_err (type block) (module D : DOCUMENT with type block = block) : _ -> block list =
  let open D in
  function
  (* | `Parse err -> *)
  (*    [p [txt (Printf.sprintf "I was unable to parse your submission: %s" *)
  (*               (Parser_util.Driver.string_of_error err))] *)
  (*    ] *)
  (* | `Type_error (_loc, msg) -> *)
  (*    [p [txt (Printf.sprintf "There was an error trying to interpret \ *)
  (*                             your submission: %s" msg)] *)
  (*    ] *)
  | `Unexpected_commands ->
     [p [txt (Printf.sprintf "Your submission had unexpected commands in it.")]]
  | `Domain_mismatch ->
     [p [txt "There was a mismatch in the domain definitions, so I was \
              unable to mark this submission automatically."]]
  | `Not_enough_solutions expected_json ->
     [p [txt "Your code does not produce enough solutions. The \
              following solution is not generated by your constraints:"]
     ; code_bl (Generalities.Json.to_string expected_json)
     ]
  | `Too_many_solutions unwanted_json ->
     [p [txt "Your code produces too many solutions. The following \
              solution is generated by your constraints, but is not \
              required by the solution:"]
     ; code_bl (Generalities.Json.to_string unwanted_json)
     ]
  | `Solution_mismatch (expected, submitted) ->
     [ p [txt "Your code produces solutions that are not required, and \
               misses solutions that are required. The following is an \
               example of a solution that your code should produce but \
               does not:"]
     ; code_bl (Generalities.Json.to_string expected)
     ; p [txt "This is an example of a solution that you code produces \
               but should not:"]
     ; code_bl (Generalities.Json.to_string submitted)
     ]
