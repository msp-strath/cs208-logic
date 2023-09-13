open Ast

(******************************************************************************)
(* FIXME: the following ought to be in an Environment module *)

module NameMap = Map.Make (String)

type domain_info =
  { constructors : string list }

type defn =
  | Defined of
      { args : (name * name) list
      ; body : term
      }
  | Atom of
      { args : (name * name) list }

type global_env =
  { domains : domain_info NameMap.t
  ; constructor_domains : (name * Location.t) NameMap.t
  ; defns   : defn NameMap.t
  }

let initial_global_env =
  { domains = NameMap.empty
  ; constructor_domains = NameMap.empty
  ; defns = NameMap.empty
  }

(******************************************************************************)
type local_env = constructor_name NameMap.t

let empty_local_env = NameMap.empty

type literal = bool * string

type value =
  | VCons of constructor_name
  | VInt  of int
  | VTrue
  | VFalse
  | VLiteral of literal
  | VClause  of literal list
  | VClauses of literal list list

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

let get_domain domain global_env =
  match NameMap.find domain.detail global_env.domains with
  | exception Not_found ->
     raise (Evaluation_error "domain not defined") (* FIXME: more detail *)
  | info ->
     info

(* TODO:
   - allocate a variable for each atom/args pair, and remember them
 *)
let make_atom : name -> constructor_name list -> string =
  fun name args ->
  name ^ "(" ^ String.concat "," args ^ ")"

let eval : global_env -> local_env -> term -> value with_location =
  fun global_env local_env term ->
  let rec eval local_env term =
    match term.detail with
    | Apply (name, terms) ->
       (match NameMap.find name.detail local_env with
        | exception Not_found ->
           (match NameMap.find name.detail global_env.defns with
            | exception Not_found ->
               raise (Evaluation_error "Definition not found") (* FIXME: say what *)
            | Atom _ ->
               let values =
                 List.map (fun term -> to_constructor (eval local_env term)) terms
               in
               { detail = VLiteral (true, make_atom name.detail values)
               ; location = term.location }
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
       let { constructors } = get_domain domain global_env in
       let v = List.fold_right
                 (fun cnm ->
                   let local_env = NameMap.add name cnm local_env in
                   disj (to_clause (eval local_env term)))
                 constructors
                 `False
       in
       { detail = of_clause v; location = term.location }
    | BigAnd (name, domain, term) ->
       let { constructors } = get_domain domain global_env in
       let v = List.fold_right
                 (fun cnm ->
                   let local_env = NameMap.add name cnm local_env in
                   conj (to_clauses (eval local_env term)))
                 constructors
                 `True
       in
       { detail = of_clauses v; location = term.location }
  in
  eval local_env term

let eval_main env =
  let invoke_main_term =
    { detail = Apply ({ detail = "main"; location = Location.internal }, [])
    ; location = Location.internal }
  in
  to_clauses (eval env empty_local_env invoke_main_term)
