open Ast
open Result_syntax
open Evaluator

let combine_opt xs ys =
  match List.combine xs ys with
  | zs -> Some zs
  | exception _ -> None

type kind =
  | Literal
  | Clause
  | Clauses
  | Domain of name

let errorf location fmt =
  Printf.ksprintf (fun msg -> Error (location, msg)) fmt

let is_domain_type location = function
  | Domain d -> Ok d
  | _ ->
     errorf location "Expecting a value of domain type, not a logical formula."

let check_domain global_env domain =
  if NameMap.mem domain.detail global_env.domains then
    Ok ()
  else
    errorf domain.location
      "Named domain '%s' has not (yet) been defined."
      domain.detail

let check_term global_env ctxt kind term =
  let rec check_application ctxt location arg_domains terms =
    let num_expected = List.length arg_domains in
    let num_given = List.length terms in
    if num_expected <> num_given then
      errorf location
        "Incorrect number of arguments. Expecting %d, but %d provided"
        num_expected
        num_given
    else
      let checkees =
        List.map2 (fun (_, domain) term -> (Domain domain, term)) arg_domains terms
      in
      traverse_ (check ~ctxt) checkees

  and kind_of ~ctxt term =
    match term.detail with
    | Apply (name, terms) ->
       (match NameMap.find name.detail ctxt with
        | domain ->
           Ok (Domain domain)
        | exception Not_found ->
           (match NameMap.find name.detail global_env.defns with
            | exception Not_found ->
               errorf name.location
                 "'%s' not defined"
                 name.detail
            | Defined { args; _ } ->
               let* () = check_application ctxt term.location args terms in
               Ok Clauses
            | Atom { args } ->
               let* () = check_application ctxt term.location args terms in
               Ok Literal))
    | IntConstant _i ->
       failwith "int constants"
    | Constructor cnm ->
       (match NameMap.find cnm global_env.constructor_domains with
        | exception Not_found ->
           errorf term.location
             "Constructor '%s' not defined."
             cnm
        | domain_name, _ ->
           Ok (Domain domain_name))
    | Eq (term1, term2) | Ne (term1, term2) ->
       (let* kind1 = kind_of ~ctxt term1 in
        let* kind2 = kind_of ~ctxt term2 in
        let* dom1 = is_domain_type term1.location kind1 in
        let* dom2 = is_domain_type term2.location kind2 in
        if dom1 = dom2 then
          Ok Literal
        else
          errorf term.location
            "Cannot compare values of incompatible domain types '%s' and '%s'"
            dom1
            dom2)
    | Neg term ->
       let* () = check ~ctxt (Literal, term) in
       Ok Literal
    | Implies (t1, t2) ->
       let* () = check ~ctxt (Literal, t1) in
       let* () = check ~ctxt (Clauses, t2) in
       Ok Clauses
    | Or terms ->
       let* () = traverse_ (fun tm -> check ~ctxt (Clause, tm)) terms in
       Ok Clause
    | And terms ->
       let* () = traverse_ (fun tm -> check ~ctxt (Clauses, tm)) terms in
       Ok Clauses
    | BigOr (var_name, domain, term) ->
       let* () = check_domain global_env domain in
       let ctxt = NameMap.add var_name domain.detail ctxt in
       let* () = check ~ctxt (Clause, term) in
       Ok Clause
    | BigAnd (var_name, domain, term) ->
       let* () = check_domain global_env domain in
       let ctxt = NameMap.add var_name domain.detail ctxt in
       let* () = check ~ctxt (Clauses, term) in
       Ok Clauses
  and check ~ctxt (required_kind, term) =
    let* computed_kind = kind_of ~ctxt term in
    match required_kind with
    | Clauses ->
       (match computed_kind with
        | Literal | Clause | Clauses -> Ok ()
        | Domain dom ->
           errorf term.location
             "Required logical clause(s), but this code represents a \
              value of domain type '%s'." dom)
    | Clause ->
       (match computed_kind with
        | Literal | Clause -> Ok ()
        | Clauses ->
           errorf term.location
             "Required a single clause, but this code represents \
              multiple clauses."
        | Domain dom ->
           errorf term.location
             "Required a logical clause, but this code represents a \
              value of domain type '%s'." dom)
    | Literal ->
       (match computed_kind with
        | Literal -> Ok ()
        | Clauses ->
           errorf term.location
             "Required a literal, but this code represents \
              multiple clauses."
        | Clause ->
           errorf term.location
             "Required a literal, but this code represents \
              a clause."
        | Domain dom ->
           errorf term.location
             "Required a logical literal, but this code represents a \
              value of domain type '%s'." dom)
    | Domain required_dom ->
       (match computed_kind with
        | Literal | Clause | Clauses ->
           errorf term.location
             "Required a value of domain type '%s', but this code \
              represents a logical constraint." required_dom
        | Domain dom ->
           if required_dom = dom then
             Ok ()
           else
             errorf term.location
               "Required a value of domain type '%s', but this code \
                represents a value of domain type '%s'."
               required_dom
               dom)
  in
  check ~ctxt (kind, term)

let check_not_declared global_env name =
  match NameMap.mem name.detail global_env.defns with
  | true -> errorf name.location "The name '%s' has already been used" name.detail (* FIXME: where? *)
  | false -> Ok ()

let check_duplicates names =
  let rec loop set = function
    | [] -> None
    | name :: names ->
       (match NameMap.find name.detail set with
        | exception Not_found ->
           loop (NameMap.add name.detail name.location set) names
        | location ->
           Some (name.detail, name.location, location))
  in
  loop NameMap.empty names

let check_arg_specs global_env arg_specs =
  let* names =
    traverse
      (fun (name, domain_name) ->
        let* () = check_domain global_env domain_name in
        Ok name)
      arg_specs
  in
  match check_duplicates names with
  | Some (duplicate, location1, location2) ->
     errorf location1 "Parameter name '%s' already used at %a"
       duplicate
       Location.to_string location2
  | None ->
     Ok ()

let check_domain_not_declared global_env domain =
  match NameMap.mem domain.detail global_env.domains with
  | true ->
     errorf domain.location "Domain '%s' already defined." domain.detail (* FIXME: where? *)
  | false -> Ok ()

let check_declaration global_env = function
  | Definition (name, arg_specs, body) ->
     let* () = check_not_declared global_env name in
     let* () = check_arg_specs global_env arg_specs in
     let ctxt = List.fold_right
                  (fun (name, domain) -> NameMap.add name.detail domain.detail)
                  arg_specs
                  NameMap.empty
     in
     let* () = check_term global_env ctxt Clauses body in
     let defn =
       Defined { args = List.map (fun (n,d) -> n.detail, d.detail) arg_specs; body }
     in
     Ok { global_env with defns = NameMap.add name.detail defn global_env.defns }

  | Atom_decl (name, arg_specs) ->
     let* () = check_not_declared global_env name in
     let* () = check_arg_specs global_env arg_specs in
     let defn = Atom { args = List.map (fun (n,d) -> n.detail, d.detail) arg_specs } in
     Ok { global_env with defns = NameMap.add name.detail defn global_env.defns }

  | Domain_decl (name, constructors) ->
     let* () = check_domain_not_declared global_env name in
     let* constructor_domains =
       fold_left_err
         (fun constructor_domains constructor ->
           match NameMap.find constructor.detail constructor_domains with
           | exception Not_found ->
              Ok (NameMap.add constructor.detail (name.detail, constructor.location) constructor_domains)
           | existing_domain, previous_location ->
              errorf constructor.location
                "Constructor '%s' previously defined in domain '%s' at %a"
                constructor.detail
                existing_domain
                Location.to_string previous_location)
         global_env.constructor_domains
         constructors
     in
     let domains = NameMap.add name.detail { constructors = List.map (fun c -> c.detail) constructors } global_env.domains in
     Ok { global_env with constructor_domains; domains }

let check_declarations decls =
  fold_left_err
    check_declaration
    initial_global_env
    decls
