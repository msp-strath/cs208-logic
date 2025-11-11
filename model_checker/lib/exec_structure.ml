open Generalities
open Fol_formula

module IdentMap = Map.Make (String)

type env = {
    vocabs : Vocabulary.t IdentMap.t;
    models : (string * Model.t) IdentMap.t;
    axioms : (Vocabulary.t * formula IdentMap.t) IdentMap.t;
  }

let empty_env =
  {
    vocabs = IdentMap.empty;
    models = IdentMap.empty;
    axioms = IdentMap.empty;
  }

let add_vocabulary name vocab env =
  { env with vocabs = IdentMap.add name vocab env.vocabs }

let add_model name (vocab, model) env =
  { env with models = IdentMap.add name (vocab, model) env.models }

let add_axiomset name (vocab, formulas) env =
  { env with axioms = IdentMap.add name (vocab, formulas) env.axioms }

let get_vocabulary vocab_name env =
  match IdentMap.find_opt vocab_name env.vocabs with
  | None ->
     Result_ext.errorf
       "The vocabulary '%s' has not been defined."
       vocab_name
  | Some vocab ->
     Ok vocab

(******************************************************************************)
(* "Execution" of structures *)

type res =
  | Message of string
  | Outcome of string * formula * Checker.outcome

open Result_ext.Syntax

let vocabulary env name arities =
  Result.map_error
    (Printf.sprintf "Checking vocab '%s': %s" name)
    begin
      let* () =
        Result_ext.check_false (IdentMap.mem name env.vocabs)
          ~on_error:"Vocabulary with this name already defined."
      and* vocab = Vocabulary.of_arities arities
      in
      Result.ok
        (add_vocabulary name vocab env,
         Message (Printf.sprintf "Vocabulary '%s' defined" name))
    end

let list_is_singleton = function
  | [x] -> Some x
  | _ -> None

let check_model_definition env name vocab_name defns =
  Result.map_error
    (Printf.sprintf "Checking model '%s': %s" name)
    begin
      let open Model in
      let* () =
        Result_ext.check_false
          ~on_error:"Model with this name already defined."
          (IdentMap.mem name env.models)
      in
      let* vocab = get_vocabulary vocab_name env in
      let universes, predicate_interps =
        List.partition_map
          (function ("universe", elements) -> Either.Left elements
                  | predicate_interp       -> Either.Right predicate_interp)
          defns
      in
      let* universe =
        (match universes with
         | [] -> Result.error "No universe defined."
         | [x] -> Ok x
         | _   -> Result.error "Multiple universes defined.")
      in
      (* 1. Universe consists of only singletons *)
      let* universe =
        Result_ext.traverse
          (Fun.compose
             (Result_ext.of_option
                ~on_error:"Universe should only contain single elements \
                           (not pairs, etc.).")
             list_is_singleton)
          universe
      in
      (* 2. Every predicate declared is in the vocabulary and has the
         right arity. *)
      let* relations =
        Result_ext.fold_left_err
          (fun relations (predicate_name, tuples) ->
            let* arity =
              Result_ext.of_option
                ~on_error:(Printf.sprintf "Predicate '%s' not in vocabulary"
                             predicate_name)
                (Vocabulary.arity predicate_name vocab)
            in
            let* tuples =
              Result_ext.fold_left_err
                (fun tuples values ->
                  let* () =
                    Result_ext.check_true
                      ~on_error:(Printf.sprintf
                                   "All members of the \
                                    interpretation of \
                                    predicate '%s' should \
                                    have arity %d."
                                   predicate_name
                                   arity)
                      (List.length values = arity)
                  in
                  let* () =
                    Result_ext.traverse_
                      (fun entity_name ->
                        if List.mem entity_name universe then
                          Ok ()
                        else
                          Result_ext.errorf
                            "Entity '%s' is not in this model's universe"
                            entity_name)
                      values
                  in
                  Result.ok (TupleSet.add values tuples))
                TupleSet.empty
                tuples
            in
            Result.ok (PredicateMap.add predicate_name tuples relations))
          PredicateMap.empty
          predicate_interps
      in
      (* 3. Every predicate in the vocabulary has a definition. *)
      let* () =
        Result_ext.check_true
          (* FIXME: say what is missing *)
          ~on_error:"Missing predicate definitions"
          (PredicateMap.for_all
             (fun nm _ -> PredicateMap.mem nm relations)
             vocab.pred_arity)
      in
      let model = Model.{ universe; relations } in
      let env = add_model name (vocab_name, model) env in
      Result.ok
        (env,
         Message (Printf.sprintf "Model '%s' has been declared." name))
    end

let check_axiomset env name vocab formulas =
  Result.map_error (Printf.sprintf "In axiom set %s: %s" name)
    begin
      let* () =
        Result_ext.check_false
          ~on_error:"Multiple axiom sets with this name"
          (IdentMap.mem name env.axioms)
      in
      let* vocab = get_vocabulary vocab env in
      let check_formula checked (nm, formula) =
        if IdentMap.mem nm checked then
          Result_ext.errorf "Multiple formulas named '%s'." nm
        else
          let* () =
            Result.map_error (Printf.sprintf "Axiom '%s': %s" nm)
              (Wff.valid_closed_formula vocab formula)
          in
          Result.ok (IdentMap.add nm formula checked)
      in
      let* checked =
        Result_ext.fold_left_err check_formula IdentMap.empty formulas
      in
      let env = add_axiomset name (vocab, checked) env in
      Result.ok (env, Message (Printf.sprintf "Axiom set '%s' defined." name))
    end

let exec_item env =
  let open Structure in
  function
  | Vocab { name; arities } ->
     vocabulary env name arities
  | Model { name; vocab_name; defns } ->
     check_model_definition env name vocab_name defns
  | Axioms { name; vocab; formulas } ->
     check_axiomset env name vocab formulas
  | Check { model_name; formula } ->
     (match IdentMap.find_opt model_name env.models with
      | None ->
         Error (Printf.sprintf "Model '%s' not defined." model_name)
      | Some (vocab_name, model) ->
         (match IdentMap.find_opt vocab_name env.vocabs with
          | None ->
             Error
               (Printf.sprintf
                  "INTERNAL ERROR: Vocabulary '%s' of model '%s' not found"
                  vocab_name model_name)
          | Some vocab ->
             (match Wff.valid_closed_formula vocab formula with
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

  | Synth { axioms; cardinality } ->
     (match IdentMap.find_opt axioms env.axioms with
      | None ->
         Error (Printf.sprintf "Axiom set %s not defined" axioms)
      | Some (vocab, axioms) ->
         (let axioms = IdentMap.fold (fun _ -> List.cons) axioms [] in
          match Generator.generate cardinality vocab axioms with
          | Ok model ->
             let msg = Pretty.to_string ~width:80 (Model.pp model) in
             Ok (env, Message msg)
          | Error msg ->
             let msg = Format_util.str "Synthesis failed: %s@," msg in
             Ok (env, Message msg)))

let rec exec_all env outputs = function
  | [] ->
     Ok (List.rev outputs)
  | item :: items ->
     (match exec_item env item with
      | Error msg ->
         Error (List.rev outputs, msg)
      | Ok (env, output) ->
         exec_all env (output :: outputs) items)

let exec =
  exec_all empty_env []
