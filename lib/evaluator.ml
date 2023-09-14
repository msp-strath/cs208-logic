open Ast
open Json
open Environment

type 'a assignment =
  | True
  | False
  | Symb of 'a

module type ASSIGNMENT = sig
  type atom

  val eval_atom : name -> constructor_name list -> atom assignment
end

module Eval (Assignment : ASSIGNMENT) = struct

  open Assignment

  type literal = bool * atom

  type value =
    | VCons of constructor_name
    | VInt  of int
    | VString of string
    | VTrue
    | VFalse
    | VLiteral of literal
    | VClause  of literal list
    | VClauses of literal list list
    | VJson of json
    | VJsons of json list
    | VAssignments of (string * json) list
    | VEmptySequence

  exception Evaluation_error of string

  let to_constructor v =
    match v.detail with
    | VCons cnm -> cnm
    | _ -> raise (Evaluation_error "expecting a constructor value") (* FIXME: use location *)

  let to_literal v =
    match v.detail with
    | VTrue -> `True
    | VFalse -> `False
    | VLiteral (b, atom) -> `Literal (b, atom)
    | _ -> raise (Evaluation_error "expecting a literal")

  let of_literal = function
    | `True -> VTrue
    | `False -> VFalse
    | `Literal (b, atom) -> VLiteral (b, atom)

  let negate = function
    | `True -> `False
    | `False -> `True
    | `Literal (b, atom) -> `Literal (not b, atom)

  let disj v1 v2 =
    match v1, v2 with
    | `True, _ | _, `True -> `True
    | `False, x | x, `False -> x
    | `Clause lits1, `Clause lits2 -> `Clause (lits1 @ lits2)

  let to_clause v =
    match v.detail with
    | VTrue -> `True
    | VFalse -> `False
    | VLiteral l -> `Clause [l]
    | VClause ls -> `Clause ls
    | _ -> raise (Evaluation_error "not a clause")

  let of_clause = function
    | `True -> VTrue
    | `False -> VFalse
    | `Clause lits -> VClause lits

  let to_clauses v =
    match v.detail with
    | VTrue -> `True
    | VFalse -> `False
    | VLiteral l -> `Clauses [[l]]
    | VClause ls -> `Clauses [ls]
    | VClauses lss -> `Clauses lss
    | _ -> raise (Evaluation_error "not clauses")

  let of_clauses = function
    | `True -> VTrue
    | `False -> VFalse
    | `Clauses lss -> VClauses lss

  type literal_value = [ `True | `False | `Literal of literal ]
  type clauses_value = [ `True | `False | `Clauses of literal list list ]

  let conj v1 v2 =
    match v1, v2 with
    | `False, _ | _, `False -> `False
    | `True, v  | v, `True  -> v
    | `Clauses cs1, `Clauses cs2 -> `Clauses (cs1 @ cs2)

  let implies (v1 : literal_value) (v2 : clauses_value) : clauses_value =
    match v1, v2 with
    | _,      `True  -> `True
    | `False, _      -> `True
    | `True,  `False -> `False
    | `Literal (b, a), `False -> `Clauses [[not b, a]]
    | `True,  `Clauses cs -> `Clauses cs
    | `Literal (b, a), `Clauses cs ->
       `Clauses (List.map (List.cons (not b, a)) cs)

  let to_json v =
    match v.detail with
    | VTrue -> JBool true
    | VFalse -> JBool false
    | VLiteral _ | VClause _ | VClauses _ -> raise (Evaluation_error "undetermined result")
    | VJson j -> j
    | VString s -> JString s
    | VCons cnm -> JString cnm
    | VInt i -> JInt i
    | VJsons _ | VAssignments _ | VEmptySequence ->
       raise (Evaluation_error "Sequence where single value expected")

  let to_assignments v =
    match v.detail with
    | VAssignments a -> a
    | VEmptySequence -> []
    | _ ->
       raise (Evaluation_error "Expecting a sequence of assignments")

  let to_jsons v =
    match v.detail with
    | VJsons jsons -> jsons
    | VEmptySequence -> []
    | _ -> [to_json v]

  let to_sequence v =
    match v.detail with
    | VJsons jsons -> `Jsons jsons
    | VAssignments a -> `Assignments a
    | VEmptySequence -> `Empty
    | _ -> `Jsons [to_json v]

  let concat s1 s2 =
    match s1, s2 with
    | `Empty, s | s, `Empty -> s
    | `Jsons j1, `Jsons j2 -> `Jsons (j1 @ j2)
    | `Assignments a1, `Assignments a2 -> `Assignments (a1 @ a2)
    | _ ->
       raise (Evaluation_error "Type mismatch in concatenation")

  let to_symbol v =
    match v.detail with
    | VCons cnm -> cnm
    | VString s -> s
    | _ ->
       raise (Evaluation_error "Expecting a symbol")

  (* FIXME: not just constructors... numbers (and strings?) too *)
  type local_env = constructor_name NameMap.t

  let empty_local_env = NameMap.empty

  let get_domain domain env =
    match NameMap.find domain.detail env.domains with
    | exception Not_found ->
       raise (Evaluation_error "domain not defined") (* FIXME: more detail *)
    | info ->
       info

  let eval : environment -> local_env -> term -> value with_location =
    fun env local_env term ->
    let rec eval local_env term =
      match term.detail with
      | Apply (name, terms) ->
         (match NameMap.find name.detail local_env with
          | exception Not_found ->
             (match NameMap.find name.detail env.defns with
              | exception Not_found ->
                 raise (Evaluation_error "Definition not found") (* FIXME: say what *)
              | Atom _ ->
                 let values =
                   List.map (fun term -> to_constructor (eval local_env term)) terms
                 in
                 let detail = match eval_atom name.detail values with
                   | True -> VTrue
                   | False -> VFalse
                   | Symb a -> VLiteral (true, a)
                 in
                 { detail; location = term.location }
              | Defined { args; body; _ } ->
                 let values = List.map (eval local_env) terms in
                 if List.length values <> List.length args then
                   raise (Evaluation_error "argument length mismatch")
                 else
                   let local_env =
                     List.fold_right2
                       (fun (nm, _) value -> NameMap.add nm (to_constructor value))
                       args
                       values
                       NameMap.empty
                   in
                   let result = eval local_env body in
                   { result with location = term.location })
          | cnm ->
             (match terms with
              | [] ->
                 { detail = VCons cnm; location = term.location }
              | _ ->
                 raise (Evaluation_error "Local variable given arguments")))
      | IntConstant i ->
         { detail = VInt i; location = term.location }
      | Constructor cnm ->
         { detail = VCons cnm; location = term.location }
      | Eq (term1, term2) ->
         let v1 = eval local_env term1 in
         let v2 = eval local_env term2 in
         if to_constructor v1 = to_constructor v2 then
           { detail = VTrue; location = term.location }
         else
           { detail = VFalse; location = term.location }
      | Ne (term1, term2) ->
         let v1 = eval local_env term1 in
         let v2 = eval local_env term2 in
         if to_constructor v1 <> to_constructor v2 then
           { detail = VTrue; location = term.location }
         else
           { detail = VFalse; location = term.location }
      | Neg term ->
         let v = eval local_env term in
         let v = of_literal (negate (to_literal v)) in
         { detail = v; location = term.location }
      | Or terms ->
         let v =
           List.fold_right (fun term -> disj (to_clause (eval local_env term))) terms `False
         in
         { detail = of_clause v; location = term.location }
      | And terms ->
         let v =
           List.fold_right (fun term -> conj (to_clauses (eval local_env term))) terms `True
         in
         { detail = of_clauses v; location = term.location }
      | Implies (t1, t2) ->
         let v1 = to_literal (eval local_env t1) in
         let v2 = to_clauses (eval local_env t2) in
         let v = of_clauses (implies v1 v2) in
         { detail = v; location = term.location }
      | BigOr (name, domain, term) ->
         let { constructors } = get_domain domain env in
         let v = List.fold_right
                   (fun cnm ->
                     let local_env = NameMap.add name cnm local_env in
                     disj (to_clause (eval local_env term)))
                   constructors
                   `False
         in
         { detail = of_clause v; location = term.location }
      | BigAnd (name, domain, term) ->
         let { constructors } = get_domain domain env in
         let v = List.fold_right
                   (fun cnm ->
                     let local_env = NameMap.add name cnm local_env in
                     conj (to_clauses (eval local_env term)))
                   constructors
                   `True
         in
         { detail = of_clauses v; location = term.location }

      | JSONObject assignments_term ->
         let fields = to_assignments (eval local_env assignments_term) in
         { detail = VJson (JObject fields); location = term.location }
      | JSONArray values_term ->
         let values = to_jsons (eval local_env values_term) in
         { detail = VJson (JArray values); location = term.location }
      | For (name, domain, term) ->
         let { constructors } = get_domain domain env in
         let seq = List.fold_right
                     (fun cnm ->
                       let local_env = NameMap.add name cnm local_env in
                       concat (to_sequence (eval local_env term)))
                     constructors
                     `Empty
         in
         { detail = (match seq with `Empty -> VEmptySequence
                                  | `Jsons js -> VJsons js
                                  | `Assignments a -> VAssignments a)
         ; location = term.location
         }
      | If (check, term) ->
         (match (eval local_env check).detail with
          | VTrue -> eval local_env term
          | VFalse -> { detail = VEmptySequence; location = term.location }
          | _ -> raise (Evaluation_error "indeterminate truth value"))
      | Sequence terms ->
         let seq = List.fold_right
                     (fun term ->
                       concat (to_sequence (eval local_env term)))
                     terms
                     `Empty
         in
         { detail = (match seq with `Empty -> VEmptySequence
                                  | `Jsons js -> VJsons js
                                  | `Assignments a -> VAssignments a)
         ; location = term.location
         }
      | Assign (field_name_term, value_term) ->
         let field_name = to_symbol (eval local_env field_name_term) in
         let value      = to_json (eval local_env value_term) in
         { detail = VAssignments [field_name, value]; location = term.location }
      | StrConstant s ->
         { detail = VString s; location = term.location }
    in
    eval local_env term
end



(* FIXME: output to a string, so it can be output to a browser window *)
let execute_command = function
  | Dump_Clauses (env, term) ->
     let module E = Eval (struct type atom = string
                                 let eval_atom nm = function
                                   | [] -> Symb nm
                                   | args -> Symb (nm^"("^(String.concat "," args)^")")
                          end) in
     let clauses = E.to_clauses (E.eval env E.empty_local_env term) in
     (match clauses with
      | `True ->
         Printf.printf "Always true\n"
      | `False ->
         Printf.printf "Always false\n"
      | `Clauses clauses ->
         List.iter
           (fun clause ->
             print_endline (String.concat " | " (List.map (function (true, a) -> a | (false, a) -> "-" ^ a) clause)))
           clauses)
  | IfSat (env, term, json_term) ->
     (Format.printf "Checking @[%a@]@\n" Ast.pp_term term;
      let solver = Solver.create () in
      let atom_table = Hashtbl.create 1024 in
      let mk_atom_str nm args = nm^"("^String.concat "," args^")" in
      let module E = Eval (struct
                         type atom = Solver.v
                         let eval_atom nm args =
                           let str = mk_atom_str nm args in
                           match Hashtbl.find atom_table str with
                           | exception Not_found ->
                              let a = Solver.gen solver in Hashtbl.add atom_table str a; Symb a
                           | a -> Symb a
                       end)
      in
      match E.to_clauses (E.eval env E.empty_local_env term) with
      | `True ->
         Format.printf "Always true@\n"
      | `False ->
         Format.printf "Always false@\n"
      | `Clauses clauses ->
         List.iter (Solver.add_clause solver) clauses;
         match Solver.solve solver with
         | `UNSAT -> Format.printf "UNSAT@\n"
         | `SAT vals ->
            let module A = struct
                type atom
                let eval_atom nm args =
                  let str = mk_atom_str nm args in
                  match Hashtbl.find atom_table str with
                  | exception Not_found -> True (* FIXME: warn arbitrary *)
                  | a -> if vals a then True else False              end
            in
            let module E2 = Eval (A) in
            let json = E2.to_json (E2.eval env E2.empty_local_env json_term) in
            Format.printf "%a\n"
              Json.Printing.pp json)
