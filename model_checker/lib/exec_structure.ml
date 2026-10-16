open Generalities
open Fol_formula
open Result_ext.Syntax

module IdentMap = Map.Make (String)
module IdentSet = Set.Make (String)
module Tuple    = struct
  type t = string list
  let compare = List.compare String.compare
end
module TupleSet = Set.Make (Tuple)

type location = unit

type predicate_info = {
  arity    : int;
  location : location;
}

type axiom_info =
  { formula : formula; location : location }

type theory = {
  predicates : predicate_info IdentMap.t;
  axioms     : axiom_info IdentMap.t;
}

(* Really a first-order structure *)
type model = {
  universe : IdentSet.t; (* individuals, as a set of names *)
  predicate_defns : (int * TupleSet.t option) IdentMap.t;
}

type env_item =
  | Theory of theory
  | Model of string * model

type env = env_item IdentMap.t

module VarSet = Set.Make (String)

let valid_term = function
  | Var v ->
    Ok (VarSet.singleton v)
  | Fun (f, _) ->
    Result_ext.errorf
      "Function symbol '%s' not declared: function symbols not supported."
      f

let rec valid_formula vocab = function
  | True | False -> Ok VarSet.empty
  | Atom (r, tms) ->
    let* arity =
      match r with
      | "=" | "!=" -> Ok 2
      | r ->
	match IdentMap.find_opt r vocab with
	| None ->
	  Result_ext.errorf "Predicate symbol '%s' not declared" r
	| Some { arity; location = _ } -> Ok arity
    in
    if arity = List.length tms then
      Result_ext.fold_left_err
	(fun vars tm ->
	  let+ tm_vars = valid_term tm in
	  VarSet.union vars tm_vars)
	VarSet.empty
	tms
    else
      Result_ext.errorf
	"Incorrect number of arguments to predicate '%s'" r
  | Imp (f1, f2) | And (f1, f2) | Or (f1, f2) ->
    let+ vars1 = valid_formula vocab f1
    and+ vars2 = valid_formula vocab f2
    in VarSet.union vars1 vars2
  | Not f ->
    valid_formula vocab f
  | Forall (x, f) | Exists (x, f) ->
    let+ vars = valid_formula vocab f in
    VarSet.remove x vars

let valid_closed_formula vocab f =
  let* vars = valid_formula vocab f in
  if VarSet.is_empty vars then Ok ()
  else
    Result_ext.errorf
      "Variables %s are free in formula"
      (String.concat ", " (VarSet.elements vars))




let build_theory items =
  let* predicates, axioms =
    Result_ext.fold_left_err
      (fun (predicates, axioms) item ->
	match item with
	| Structure.SymbolDeclaration (ident, arity) ->
	  (match IdentMap.find_opt ident predicates with
	  | None ->
	    let predicates =
	      IdentMap.add ident { arity = arity; location = () }
		predicates
	    in
	    Ok (predicates, axioms)
	  | Some { location = _; arity = _ } ->
	    (* FIXME: location info *)
	    Result_ext.errorf "Predicate symbol '%s' already declared." ident)
	| Structure.Axiom (ident, formula) ->
	  (match IdentMap.find_opt ident axioms with
	  | None ->
	    let location = () in
	    let axioms = IdentMap.add ident { formula; location } axioms in
	    Ok (predicates, axioms)
	  | Some { formula = _; location = _ } ->
	    Result_ext.errorf "Axiom '%s' already declared." ident))
      (IdentMap.empty, IdentMap.empty)
      items
  in
  let* () =
    axioms
    |> IdentMap.to_seq
    |> Result_ext.check_seq
      (fun (_ident, { formula; location = _ }) ->
	(* FIXME: augment the error message with location and identifier
           information *)
	valid_closed_formula predicates formula)
  in
  Ok { predicates; axioms }

let list_is_singleton = function
  | [x] -> Some x
  | _ -> None

let check_tuple universe arity individuals =
  assert (arity >= 0);
  let rec check n rev_checked todo =
    match n, todo with
    | 0, []   -> Ok (List.rev rev_checked)
    | 0, _::_ -> Result_ext.errorf "Too many elements in tuple; expecting %d" arity
    | _, []   -> Result_ext.errorf "Too few elements in tuple; expecting %d" arity
    | n, x::todo ->
      (* FIXME: locations *)
      if IdentSet.mem x universe then
	check (n-1) (x::rev_checked) todo
      else
	Result_ext.errorf "Symbol '%s' not in the universe of this model" x
  in
  check arity [] individuals

(* Build a model as a collection of entities and predicate definitions *)
let build_model predicates defns =
  let open Result_ext.Syntax in
  let universes, predicate_defns =
    List.partition_map
      (function
	| ("universe", elements) -> Either.Left elements
	| predicate_defn         -> Either.Right predicate_defn)
      defns
  in
  let* universe =
    match universes with
    | [] -> Error "No universe defined"
    | _::_::_ -> Error "Multiple universes defined"
    | None::[] -> Error "Universe cannot be left unspecified"
    | Some items::[] ->
      Result_ext.fold_left_err
	(fun elems elem ->
	  match list_is_singleton elem with
	  | Some x -> Ok (IdentSet.add x elems)
	  | None ->
	    Error
	      "Universe should only contain single elements (not pairs, etc.)")
	IdentSet.empty
	items
  in
  let find_predicate_decl ident =
    match IdentMap.find_opt ident predicates with
    | None -> Result_ext.errorf "Predicate '%s' not declared in this theory" ident
    | Some predicate_info -> Ok predicate_info
  in
  let* predicate_defns =
    Result_ext.fold_left_err
      (fun predicate_defns (ident, items) ->
	let* { arity; location = _ } = find_predicate_decl ident in
	let* () =
	  match IdentMap.find_opt ident predicate_defns with
	  | Some _ -> Result_ext.errorf "Multiple definitions of predicate '%s'" ident
	  | None -> Ok ()
	in
	match items with
	| None ->
	  Ok (IdentMap.add ident (arity, None) predicate_defns)
	| Some items ->
	  let* elems =
	    Result_ext.fold_left_err
	      (fun elems tuple_defn ->
		let+ tuple = check_tuple universe arity tuple_defn in
		TupleSet.add tuple elems)
	      TupleSet.empty
	      items
	  in
	  Ok (IdentMap.add ident (arity, Some elems) predicate_defns))
      IdentMap.empty
      predicate_defns
  in
  let missing_predicates =
    predicate_defns |> IdentMap.to_seq |> Seq.map fst |> Seq.fold_left (fun required nm -> IdentMap.remove nm required) predicates
  in
  if IdentMap.is_empty missing_predicates then
    Ok { universe; predicate_defns }
  else
    Result_ext.errorf "Missing predicate definitions: %s are not defined"
      (String.concat ", " (List.map fst (IdentMap.bindings missing_predicates)))

module QueryEngine = struct

  (* Which is quicker? check for all possible values of each variable, or
     generate from the *)

  module ResultTuple = struct
    type t = string IdentMap.t
    let empty : t = IdentMap.empty
    let compare = IdentMap.compare String.compare
    let to_string t =
      "{" ^ String.concat ", " (List.map (fun (vnm, x) -> Printf.sprintf "%s = %s" vnm x) (IdentMap.bindings t)) ^ "}"
  end

    (*
  let rec eval_formula model = function
    | True -> ResultSet.singleton ResultTuple.empty
    | False -> ResultSet.empty
    | Atom (pred, terms) ->

    | Not fmla -> (* FIXME: need a convenient  *)
    *)

  let eval_term local_env = function
    | Var v -> IdentMap.find v local_env
    | Fun _ -> failwith "internal error: Fun in formula"

  let rec eval_formula model local_env = function
    | True -> true
    | False -> false
    | Atom ("=", [tm1; tm2]) ->
      String.equal (eval_term local_env tm1) (eval_term local_env tm2)
    | Atom ("!=", [tm1; tm2]) ->
      not (String.equal (eval_term local_env tm1) (eval_term local_env tm2))
    | Atom (pred, tms) ->
      (let tuple = List.map (eval_term local_env) tms in
      match IdentMap.find pred model.predicate_defns with
      | _, None -> failwith "internal error: undefined predicate"
      | _, Some tuples -> TupleSet.mem tuple tuples)
    | Imp (p, q) ->
      not (eval_formula model local_env p)
      || eval_formula model local_env q
    | And (p, q) ->
      eval_formula model local_env p && eval_formula model local_env q
    | Or (p, q) ->
      eval_formula model local_env p || eval_formula model local_env q
    | Not p ->
      not (eval_formula model local_env p)
    | Forall (vnm, p) ->
      IdentSet.for_all
	(fun x -> eval_formula model (IdentMap.add vnm x local_env) p)
	model.universe
    | Exists (vnm, p) ->
      IdentSet.exists
	(fun x -> eval_formula model (IdentMap.add vnm x local_env) p)
	model.universe

  module ResultSet = Set.Make (ResultTuple)

  let satisfying_assignments model vars formula =
    let vars = IdentSet.elements vars in
    let rec build results local_env = function
      | [] ->
	if eval_formula model local_env formula then
	  ResultSet.add local_env results
	else
	  results
      | v::vs ->
	IdentSet.fold
	  (fun x results ->
	    let local_env = IdentMap.add v x local_env in
	    build results local_env vs)
	  model.universe
	  results
    in
    build ResultSet.empty IdentMap.empty vars

end

type output_item =
  | Message of string
  | Table of { headers : string list; rows : string list list }

let messagef fmt = Printf.ksprintf (fun str -> Message str) fmt

let exec_structure_item env = function
  | Structure.Theory { name; items } ->
    begin
      if IdentMap.mem name env then
	Result_ext.errorf "The name '%s' has already been used for a definition" name
      else
	let+ theory = build_theory items in
	messagef "Theory '%s' defined" name,
	IdentMap.add name (Theory theory) env
    end
  | Structure.Model { name; theory_name; defns } ->
    begin
      if IdentMap.mem name env then
	Result_ext.errorf "The name '%s' has already been used for a definition" name
      else
	match IdentMap.find_opt theory_name env with
	| None ->
	  Result_ext.errorf "'%s' does not refer to a defined theory" theory_name
	| Some (Model _) ->
	  Result_ext.errorf "'%s' refers to a model; expecting a theory to be referenced here" name
	| Some (Theory theory) ->
	  let+ model = build_model theory.predicates defns in
	  messagef "Model '%s' for theory '%s' defined" name theory_name,
	  IdentMap.add name (Model (theory_name, model)) env
    end
  | Check { model_name; formula } ->
    begin
      match IdentMap.find_opt model_name env with
      | None ->
	Result_ext.errorf "'%s' does not refer to a defined model" model_name
      | Some (Theory _) ->
	Result_ext.errorf "'%s' refers to a theory; expecting a model to be referenced here" model_name
      | Some (Model (theory_name, model)) ->
	let theory = match IdentMap.find theory_name env with Model _ -> assert false | Theory theory -> theory in
	let+ free_vars = valid_formula theory.predicates formula in
	let results =
	  QueryEngine.satisfying_assignments model free_vars formula
	in
	if VarSet.is_empty free_vars then
	  (if QueryEngine.ResultSet.is_empty results then
	    messagef "Formula '%s' is not valid in model '%s'" (Formula.to_string formula) model_name,
	    env
	  else
	    messagef "Formula '%s' valid in model '%s'" (Formula.to_string formula) model_name,
	    env)
	else
	  let headers = IdentSet.elements free_vars in
	  let rows    = QueryEngine.ResultSet.fold (fun assignment -> List.cons (List.map (fun vnm -> IdentMap.find vnm assignment) headers)) results [] in
	  Table { headers; rows }, env
    end

let rec exec_all env outputs = function
  | [] ->
    Ok (List.rev outputs)
  | item :: items ->
    (match exec_structure_item env item with
    | Error msg ->
      Error (List.rev outputs, msg)
    | Ok (output, env) ->
      exec_all env (output::outputs) items)

let exec =
  exec_all IdentMap.empty []


(*


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

      *)
