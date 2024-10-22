(* To mark a Slakemoth script:

   1. Check that the domain definitions are as required.
   2. Check that the atom definitions are as required.
   3. Assertions
      (a) (parameterless) definition in the submitted version matches a given definition.
      (b) an allsat or ifsat command in the submitted version matches a given definition.

   Assertions can be gathered into sums or maximums.
 *)

open Generalities
open Result_ext.Syntax
open Environment
open Ast

let check_domain (env : environment) (name, expected_constructors) =
  let open Environment in
  let open Ast in
  match NameMap.find_opt name env.domains with
  | None -> Error (`Domain_missing name)
  | Some { constructors } ->
     if List.equal String.equal expected_constructors constructors then
       Ok ()
     else
       Error (`Domain_different_constructors name)

let check_atom env (name, expected_domains) =
  let open Environment in
  let open Ast in
  match NameMap.find_opt name env.defns with
  | None -> Error (`Atom_missing name)
  | Some (Defined _ | Table _) ->
     Error (`Expecting_an_atom name)
  | Some (Atom { args }) ->
     if List.length args = List.length expected_domains &&
          List.for_all2 (fun domain (_, domain') -> String.equal domain domain')
            expected_domains
            args
     then
       Ok ()
     else
       Error (`Atom_different_parameter_domains name)

let check_atom_expected expected_atoms = function
  | (_, (Environment.Defined _ | Table _)) ->
     Ok ()
  | (name, Atom _) ->
     match List.assoc_opt name expected_atoms with
     | None ->
        Error (`Additional_atom name)
     | Some _ ->
        Ok ()

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


let check_definition env (name, expected, json) =
  let open Environment in
  let open Ast in
  match NameMap.find_opt name env.defns with
  | Some (Defined { args = [];
                    body = submitted;
                    kind = (Clauses | Clause | Literal | Constant) }) ->
     (match check_contains env expected submitted,
            check_contains env submitted expected with
      | `CONTAINED, `CONTAINED -> Ok ()
      | `EXTRA assgn, `CONTAINED ->
         let module E2 = Evaluator.Eval (val assgn) in
         let json = E2.to_json (E2.eval env E2.empty_local_env json) in
         Error (`Not_enough_solutions (name, json))
      | `CONTAINED, `EXTRA assgn ->
         let module E2 = Evaluator.Eval (val assgn) in
         let json = E2.to_json (E2.eval env E2.empty_local_env json) in
         Error (`Too_many_solutions (name, json))
      | `EXTRA expected, `EXTRA submitted ->
         let expected_json =
           let module E = Evaluator.Eval (val expected) in
           E.to_json (E.eval env E.empty_local_env json)
         and submitted_json =
           let module E = Evaluator.Eval (val submitted) in
           E.to_json (E.eval env E.empty_local_env json)
         in
         Error (`Solution_mismatch (name, expected_json, submitted_json)))
  | Some (Atom _ | Table _) | None ->
     Error (`Expecting_definition name)
  | Some (Defined _) ->
     Error (`Non_clause_definition name)

let string_of_error = function
  | `Additional_atom name ->
     Printf.sprintf "Additional defined atom '%s' in submitted script." name
  | `Atom_different_parameter_domains name ->
     Printf.sprintf
       "The atom '%s' is declared with different parameter domains in \
        the submitted script."
       name
  | `Atom_missing name ->
     Printf.sprintf "The atom '%s' is missing in the submitted script." name
  | `Domain_different_constructors name ->
     Printf.sprintf
       "The domain '%s' has different constructors in the submitted script."
       name
  | `Domain_missing name ->
     Printf.sprintf
       "The domain '%s' is missing in the submitted script."
       name
  | `Expecting_an_atom name ->
     Printf.sprintf
       "The definition '%s' is not an atom in the submitted script."
       name
  | `Expecting_definition name ->
     Printf.sprintf
       "Expecting a definition '%s' in the submitted script, but it \
        was either not present or was an atom or table."
       name
  | `Non_clause_definition name ->
     Printf.sprintf
       "Definition '%s' is present in the submitted script, but is not \
        of the correct type."
       name
  | `Not_enough_solutions (name, example_missing) ->
     Printf.sprintf
       "In the definition '%s', the submitted code does not produce \
        enough solutions. The following solution is not generated by \
        your constraints:\n\n%s"
       name
       (Json.to_string example_missing)
  | `Solution_mismatch (name, expected, submitted) ->
     Printf.sprintf
       "In the definition '%s', the submitted code produces solutions \
        that are not required, and misses solutions that are \
        required. The following is an example of a solution that your \
        code should produce but does not:\n\n%s\n\nThis is an example \
        of a solution that you code produces but should not:\n\n%s"
       name
       (Json.to_string expected)
       (Json.to_string submitted)
  | `Too_many_solutions (name, unwanted) ->
     Printf.sprintf
       "In the definition '%s', the submitted code produces too many \
        solutions. The following solution is generated by your \
        constraints, but is not required by the solution:\n\n%s"
       name
       (Json.to_string unwanted)
  | `Type_error (_loc, msg) ->
        Printf.sprintf "Type error: %s" msg

let check expected script =
  let* env, _commands =
    Type_checker.check_declarations_open Environment.initial_global_env script
  in
  (* 1. check that the domains and atoms are as we expect *)
  let* () = Result_ext.traverse_ (check_domain env) expected.domains in
  let* () = Result_ext.traverse_ (check_atom env) expected.atoms in
  let* () =
    Result_ext.traverse_ (check_atom_expected expected.atoms)
      (Ast.NameMap.bindings env.defns)
  in
  (* 2. check that each of the definitions specified is as we expect.

     FIXME: each definition should be checked independently. *)
  let* () =
    Result_ext.traverse_ (check_definition env) expected.definitions
  in
  Result.ok ()
