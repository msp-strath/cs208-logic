open Fol_formula
module IdentMap = Map.Make (String)

type env = {
  vocabs : Vocabulary.t IdentMap.t;
  models : (string * Model.t) IdentMap.t;
  axioms : (Vocabulary.t * formula IdentMap.t) IdentMap.t;
}

type res = Message of string | Outcome of string * formula * Checker.outcome

let exec_item env =
  let open Structure in
  function
  | Vocab { name; arities } ->
      if IdentMap.mem name env.vocabs then
        Error (Printf.sprintf "Vocabulary %s already defined." name)
      else
        let rec check_arities pred_arity = function
          | (nm, arity) :: arities ->
              if arity < 0 then
                Error
                  (Printf.sprintf
                     "In vocab %s, arity of %s is not a positive number." name
                     nm)
              else if PredicateMap.mem nm pred_arity then
                Error
                  (Printf.sprintf
                     "In vocab %s, duplicate definition of predicate '%s'." name
                     nm)
              else check_arities (PredicateMap.add nm arity pred_arity) arities
          | [] ->
              Ok
                ( {
                    env with
                    vocabs =
                      IdentMap.add name { Vocabulary.pred_arity } env.vocabs;
                  },
                  Message (Printf.sprintf "Vocabulary '%s' defined" name) )
        in
        check_arities PredicateMap.empty arities
  | Model { name; vocab_name; defns } -> (
      if IdentMap.mem name env.models then
        Error (Printf.sprintf "Model '%s' already defined." name)
      else
        match IdentMap.find_opt vocab_name env.vocabs with
        | None ->
            Error
              (Printf.sprintf
                 "In declaration of model '%s', the vocabulary '%s' has not \
                  been defined."
                 name vocab_name)
        | Some vocab ->
            let rec check_defns universe relations = function
              | [] -> (
                  match universe with
                  | None ->
                      Error
                        (Printf.sprintf
                           "In interpretation %s, no universe defined." name)
                  | Some universe ->
                      (* FIXME: check that all the entities mentioned in
                         the relations are in the universe *)
                      if
                        PredicateMap.for_all
                          (fun nm _ -> PredicateMap.mem nm relations)
                          vocab.pred_arity
                      then
                        let model = Model.{ universe; relations } in
                        Ok
                          ( {
                              env with
                              models =
                                IdentMap.add name (vocab_name, model) env.models;
                            },
                            Message
                              (Printf.sprintf "Model '%s' has been declared."
                                 name) )
                      else
                        Error
                          (Printf.sprintf
                             "Missing predicate definitions in model '%s'" name)
                  )
              | ("universe", elements) :: defns -> (
                  match universe with
                  | Some _ ->
                      Error
                        (Printf.sprintf
                           "In model %s, more than one 'universe' definition."
                           name)
                  | None -> (
                      let rec check_singletons accum = function
                        | [] -> Ok (List.rev accum)
                        | [ x ] :: xs -> check_singletons (x :: accum) xs
                        | _ :: _ ->
                            Error
                              (Printf.sprintf
                                 "In model '%s', universe should only contain \
                                  single elements (not pairs, etc.)."
                                 name)
                      in
                      match check_singletons [] elements with
                      | Error msg -> Error msg
                      | Ok elements ->
                          check_defns (Some elements) relations defns))
              | (nm, elements) :: defns -> (
                  if PredicateMap.mem nm relations then
                    Error
                      (Printf.sprintf
                         "In interpretation %s, multiple interpretations of \
                          predicate %s"
                         name nm)
                  else
                    match Vocabulary.arity nm vocab with
                    | None ->
                        Error
                          (Printf.sprintf
                             "In interpretation %s, predicate %s not defined \
                              in the vocabulary."
                             name nm)
                    | Some arity -> (
                        let rec check_elements tupleset = function
                          | [] -> Ok tupleset
                          | tuple :: tuples ->
                              if List.length tuple <> arity then
                                Error
                                  (Printf.sprintf
                                     "In interpretation %s, all members of the \
                                      interpretation of %s should have arity \
                                      %d."
                                     name nm arity)
                              else
                                check_elements
                                  (Model.TupleSet.add tuple tupleset)
                                  tuples
                        in
                        match check_elements Model.TupleSet.empty elements with
                        | Error msg -> Error msg
                        | Ok tuples ->
                            check_defns universe
                              (PredicateMap.add nm tuples relations)
                              defns))
            in
            check_defns None PredicateMap.empty defns)
  | Axioms { name; vocab; formulas } -> (
      if IdentMap.mem name env.axioms then
        Error (Printf.sprintf "Multiple axiom sets named %s" name)
      else
        match IdentMap.find_opt vocab env.vocabs with
        | None ->
            Error
              (Printf.sprintf "In axiom set %s, vocabulary %s not defined." name
                 vocab)
        | Some vocab ->
            let rec check_formulas checked = function
              | (nm, formula) :: formulas -> (
                  if IdentMap.mem nm checked then
                    Error
                      (Printf.sprintf
                         "In axiom set %s, multiple formulas named '%s'." name
                         nm)
                  else
                    match Wff.valid_closed_formula vocab formula with
                    | Error msg ->
                        Error
                          (Printf.sprintf "In axiom set %s, axiom '%s': %s" name
                             nm msg)
                    | Ok () ->
                        check_formulas
                          (IdentMap.add nm formula checked)
                          formulas)
              | [] ->
                  Ok
                    ( {
                        env with
                        axioms = IdentMap.add name (vocab, checked) env.axioms;
                      },
                      Message (Printf.sprintf "Axiom set '%s' defined." name) )
            in
            check_formulas IdentMap.empty formulas)
  | Check { model_name; formula } -> (
      match IdentMap.find_opt model_name env.models with
      | None -> Error (Printf.sprintf "Model '%s' not defined." model_name)
      | Some (vocab_name, model) -> (
          match IdentMap.find_opt vocab_name env.vocabs with
          | None ->
              Error
                (Printf.sprintf
                   "INTERNAL ERROR: Vocabulary '%s' of model '%s' not found"
                   vocab_name model_name)
          | Some vocab -> (
              match Wff.valid_closed_formula vocab formula with
              | Ok () ->
                  let outcome = Checker.check_closed model formula in
                  Ok (env, Outcome (model_name, formula, outcome))
              | Error msg ->
                  Error
                    (Printf.sprintf
                       "Formula \"%s\" not well formed in the vocabulary '%s': \
                        %s"
                       (Formula.to_string formula)
                       vocab_name msg))))
  | Synth { axioms; cardinality } -> (
      match IdentMap.find_opt axioms env.axioms with
      | None -> Error (Printf.sprintf "Axiom set %s not defined" axioms)
      | Some (vocab, axioms) -> (
          let axioms = IdentMap.fold (fun _ -> List.cons) axioms [] in
          match Generator.generate cardinality vocab axioms with
          | Ok model ->
              let msg = Fmt.str "@[<v0>%a@]" Model.pp model in
              Ok (env, Message msg)
          | Error msg ->
              let msg = Fmt.str "Synthesis failed: %s@," msg in
              Ok (env, Message msg)))

let exec =
  let rec exec_all env outputs = function
    | [] -> Ok (List.rev outputs)
    | item :: items -> (
        match exec_item env item with
        | Error msg -> Error (List.rev outputs, msg)
        | Ok (env, output) -> exec_all env (output :: outputs) items)
  in
  let env =
    {
      vocabs = IdentMap.empty;
      models = IdentMap.empty;
      axioms = IdentMap.empty;
    }
  in
  exec_all env []
