open! Generalities

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

(*
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

exception Missing_atom of string
exception Changed_Atom of string * (string * string) list * (string * string) list
exception Atom_became_defn of string

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
  let* merged, defns2 =
    try
    Result.ok @@ NameMap.fold
      (fun name defn (merged, env2) ->
        match defn with
        | Atom { args } ->
           (match NameMap.find_opt name env2 with
            | None ->
               raise (Missing_atom name)
            | Some (Atom { args = args2 }) ->
               if List.map snd args = List.map snd args2 then
                 (NameMap.add name (Atom { args }) merged, NameMap.remove name env2)
               else
                 raise (Changed_Atom (name, args, args2))
            | Some (Defined _ | Table _) ->
               raise (Atom_became_defn name))
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
    with
    | Atom_became_defn name -> Error (`Atom_become_defn name)
    | Missing_atom name -> Error (`Missing_atom name)
    | Changed_Atom (name, expected, given) ->
       Error (`Changed_atom (name, expected, given))
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
 *)

let implies env phi psi json =
  match check_contains env phi psi with
  | `CONTAINED ->
     `Contained
  | `EXTRA assgn ->
     let module E2 = Evaluator.Eval (val assgn) in
     let json = E2.to_json (E2.eval env E2.empty_local_env json) in
     `Extra json
