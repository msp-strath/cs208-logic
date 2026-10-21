open Generalities
open Fol_formula
open Result_ext.Syntax

let errorf = Result_ext.errorf

module IdentMap = Map.Make (String)
module IdentSet = Set.Make (String)
module Tuple    = struct
  type t = string list
  let compare = List.compare String.compare
end
module TupleSet = Set.Make (Tuple)
module TupleMap = Map.Make (Tuple)

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

type structure = {
  universe : IdentSet.t; (* individuals, as a set of names *)
  predicate_defns : TupleSet.t IdentMap.t;
}

let pp_structure structure =
  let open Pretty in
  let curly_brak d =
    group (nest 2 (text "{" ^/^ d) ^/^ text "}")
  in
  let commas docs =
    of_seq (Seq_ext.intersperse (text "," ^^ group break) docs)
  in
  let universe_clause =
    let elems =
      commas (Seq.map text (IdentSet.to_seq structure.universe))
    in
    group (nest 1 (text "universe =" ^/^ curly_brak elems))
  in
  let pp_tuple = function
    | [x] -> text x
    | xs -> text "(" ^^ commas (Seq.map text (List.to_seq xs)) ^^ text ")"
  in
  let pp_tuples tuples =
    curly_brak (commas (Seq.map pp_tuple (TupleSet.to_seq tuples)))
  in
  let predicate_defn (predicate_name, elems) =
    group (nest 1 (text predicate_name ^^ text " =" ^/^ pp_tuples elems))
  in
  let predicate_clauses =
    structure.predicate_defns
    |> IdentMap.to_seq
    |> Seq.map predicate_defn
    |> Seq_ext.intersperse break
    |> of_seq
  in
  curly_brak (universe_clause ^/^ predicate_clauses)

type env_item =
  | Theory of theory
  | Model of string * structure

type env = env_item IdentMap.t

module WFF = struct

  module VarSet = Set.Make (String)

  let valid_term = function
    | Var v ->
      Ok (VarSet.singleton v)
    | Fun (f, _) ->
      errorf
	"Function symbol '%s' not declared: function symbols not supported."
	f

  let rec valid_formula vocab = function
    | True | False -> Ok VarSet.empty
    | Atom (r, tms) ->
      let* arity =
	match r with
        (* Always assume that equality and disequality are valid *)
	| "=" | "!=" -> Ok 2
	| r ->
	  match IdentMap.find_opt r vocab with
	  | None ->
	    errorf "Predicate symbol '%s' not declared" r
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
	errorf
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
      errorf
	"Variables %s are free in formula"
	(String.concat ", " (VarSet.elements vars))
end

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
	    errorf "Predicate symbol '%s' already declared." ident)
	| Structure.Axiom (ident, formula) ->
	  (match IdentMap.find_opt ident axioms with
	  | None ->
	    let location = () in
	    let axioms = IdentMap.add ident { formula; location } axioms in
	    Ok (predicates, axioms)
	  | Some { formula = _; location = _ } ->
	    errorf "Axiom '%s' already declared." ident))
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
	WFF.valid_closed_formula predicates formula)
  in
  Ok { predicates; axioms }

let list_is_singleton = function
  | [x] -> Some x
  | _ -> None

let check_tuple ~universe ~arity individuals =
  assert (arity >= 0);
  let rec check n rev_checked todo =
    match n, todo with
    | 0, []   -> Ok (List.rev rev_checked)
    | 0, _::_ -> errorf "Too many elements in tuple; expecting %d" arity
    | _, []   -> errorf "Too few elements in tuple; expecting %d" arity
    | n, x::todo ->
      (* FIXME: location information for better errors *)
      if IdentSet.mem x universe then
	check (n-1) (x::rev_checked) todo
      else
	errorf "Symbol '%s' not in the universe of this model" x
  in
  check arity [] individuals

module ConcreteStructure = struct
  type t = structure
  type individual = string
  type predicate_symbol = string

  module Domain = Boolean_algebra.Bool

  let universe model = IdentSet.to_seq model.universe
  let predicate model pred tuple =
    let tuples = IdentMap.find pred model.predicate_defns in
    TupleSet.mem tuple tuples
  let equal x y = String.equal x y
end

module SolverStructure () = struct

  module S = Solver.Make ()
  module Domain = S

  type individual = string
  type predicate_symbol = string

  type t = {
    universe : IdentSet.t;
    predicate_defns : TupleSet.t IdentMap.t;
    mutable predicate_vars : Domain.t TupleMap.t IdentMap.t
  }

  (* 'predicate_vars' should be initialised with all the undefined
     predicates. *)

  let universe t =
    IdentSet.to_seq t.universe

  let predicate (model : t) pred tuple =
    match IdentMap.find_opt pred model.predicate_defns with
    | Some tuples ->
      if TupleSet.mem tuple tuples then Domain.one else Domain.zero
    | None ->
      let tuples = IdentMap.find pred model.predicate_vars in
      match TupleMap.find_opt tuple tuples with
      | Some v -> v
      | None ->
	let v = S.gen () in
	model.predicate_vars <-
           IdentMap.add pred (TupleMap.add tuple v tuples) model.predicate_vars;
	v

  let equal x y =
    if String.equal x y then Domain.one else Domain.zero

  let complete_model (model : t) vars =
    List.iter S.add_assert vars;
    match S.solve () with
    | None ->
      None
    | Some assignment ->
      let new_predicate_defns =
	IdentMap.map (fun tuple_map ->
	  TupleMap.fold
	    (fun tuple v -> if assignment v then TupleSet.add tuple else Fun.id)
	    tuple_map
	    TupleSet.empty)
	  model.predicate_vars
      in
      let predicate_defns =
	IdentMap.union
	  (fun _ tuples1 tuples2 -> Some (TupleSet.union tuples1 tuples2))
	  model.predicate_defns
	  new_predicate_defns
      in
      Some ({ universe = model.universe; predicate_defns } : structure)
end

(* Build a structure as a collection of entities and predicate
   definitions, checking it against the given vocabulary. *)
let build_structure theory defns =
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
    match IdentMap.find_opt ident theory.predicates with
    | None -> errorf "Predicate '%s' not declared in this theory" ident
    | Some predicate_info -> Ok predicate_info
  in
  let* predicate_defns, incomplete =
    Result_ext.fold_left_err
      (fun (predicate_defns, incomplete) (ident, items) ->
	let* { arity; location = _ } = find_predicate_decl ident in
	let* () =
	  match IdentMap.find_opt ident predicate_defns with
	  | Some _ -> errorf "Multiple definitions of predicate '%s'" ident
	  | None -> Ok ()
	in
	match items with
	| None ->
	  Ok (predicate_defns, IdentMap.add ident TupleMap.empty incomplete)
	| Some items ->
	  let* elems =
	    Result_ext.fold_left_err
	      (fun elems tuple_defn ->
		let+ tuple = check_tuple ~universe ~arity tuple_defn in
		TupleSet.add tuple elems)
	      TupleSet.empty
	      items
	  in
	  Ok (IdentMap.add ident elems predicate_defns, incomplete))
      (IdentMap.empty, IdentMap.empty)
      predicate_defns
  in
  let mentioned_predicates =
    Seq.append
      (Seq.map fst (IdentMap.to_seq predicate_defns))
      (Seq.map fst (IdentMap.to_seq incomplete))
  in
  let missing_predicates =
    Seq.fold_left
      (fun required nm -> IdentMap.remove nm required)
      theory.predicates
      mentioned_predicates
  in
  let* () =
    if IdentMap.is_empty missing_predicates then Ok ()
    else
      errorf "Missing predicate definitions: %s are not defined"
	(String.concat ", " (List.map fst (IdentMap.bindings missing_predicates)))
  in
  (* Evaluate all the axioms of the theory in this partial model *)
  let module E = SolverStructure () in
  let module Ev = Formula_evaluator.Make (E) in
  let partial_model =
    let u = universe in
    E.{ universe = u; predicate_defns; predicate_vars = incomplete }
  in
  let axiom_vars =
    theory.axioms
    |> IdentMap.to_seq
    |> Seq.map (fun (_, { formula = fmla; location = _}) ->
                  Ev.eval_formula partial_model IdentMap.empty fmla)
    |> List.of_seq
  in
  match E.complete_model partial_model axiom_vars with
  | None ->
    (* FIXME: why not? *)
    errorf "Unable to complete model"
  | Some model ->
    Ok model

module QueryEngine = struct

  module BoolValued = Formula_evaluator.Make (ConcreteStructure)

  module ResultTuple = struct
    type t = string IdentMap.t
    let empty : t = IdentMap.empty
    let compare = IdentMap.compare String.compare
    let to_string t =
      "{" ^ String.concat ", " (List.map (fun (vnm, x) -> Printf.sprintf "%s = %s" vnm x) (IdentMap.bindings t)) ^ "}"
  end

  module ResultSet = Set.Make (ResultTuple)

  let satisfying_assignments structure vars formula =
    let vars = WFF.VarSet.elements vars in
    let rec build results local_env = function
      | [] ->
	if BoolValued.eval_formula structure local_env formula then
	  ResultSet.add local_env results
	else
	  results
      | v::vs ->
	IdentSet.fold
	  (fun x results ->
	    let local_env = IdentMap.add v x local_env in
	    build results local_env vs)
	  structure.universe
	  results
    in
    build ResultSet.empty IdentMap.empty vars

  (* assumes that formula is closed *)
  let is_valid structure formula =
    BoolValued.eval_formula structure IdentMap.empty formula

end

let check_axioms theory structure =
  let invalid_axioms =
    IdentMap.fold
      (fun axiom_name { formula; location = _} invalid ->
	if not (QueryEngine.is_valid structure formula) then
	  axiom_name :: invalid
	else
	  invalid)
      theory.axioms
      []
  in
  match invalid_axioms with
  | [] ->
    Ok ()
  | invalid ->
    (* FIXME: explain why not. *)
    errorf "The axioms %s do not hold for this model"
      (String.concat ", " invalid)

type output_item =
  | Message of string
  | Pretty  of Pretty.document
  | Table   of { headers : string list; rows : string list list }

let messagef fmt = Printf.ksprintf (fun str -> Message str) fmt

let exec_structure_item env = function

  | Structure.Theory { name; items } ->
    begin
      if IdentMap.mem name env then
	errorf "The name '%s' has already been used for a definition" name
      else
	let+ theory = build_theory items in
	[ messagef "Theory '%s' defined" name ],
	IdentMap.add name (Theory theory) env
    end

  | Structure.Model { name; theory_name; defns } ->
    begin
      if IdentMap.mem name env then
	errorf "The name '%s' has already been used for a definition" name
      else
	match IdentMap.find_opt theory_name env with
	| None ->
	  errorf "'%s' does not refer to a defined theory" theory_name
	| Some (Model _) ->
	  errorf "'%s' refers to a model; expecting a theory to be referenced here" name
	| Some (Theory theory) ->
	  let+ structure = build_structure theory defns in
	  [
	    messagef "Model '%s' for theory '%s' defined" name theory_name;
	    Pretty (pp_structure structure)
	  ],
	  IdentMap.add name (Model (theory_name, structure)) env
    end

  | Check { model_name; formula } ->
    begin
      match IdentMap.find_opt model_name env with
      | None ->
	errorf "'%s' does not refer to a defined model" model_name
      | Some (Theory _) ->
	errorf "'%s' refers to a theory; expecting a model to be referenced here" model_name
      | Some (Model (theory_name, model)) ->
	let theory = match IdentMap.find theory_name env with Model _ -> assert false | Theory theory -> theory in
	let+ free_vars = WFF.valid_formula theory.predicates formula in
	let results =
	  QueryEngine.satisfying_assignments model free_vars formula
	in
	if WFF.VarSet.is_empty free_vars then
	  (if QueryEngine.ResultSet.is_empty results then
	    [ messagef "NOT VALID: %s |= %s" model_name (Formula.to_string formula) ] ,
	    env
	  else
	    [ messagef "VALID: %s |= %s" model_name (Formula.to_string formula) ],
	    env)
	else
	  let headers = IdentSet.elements free_vars in
	  let rows =
	    List.rev
	      (QueryEngine.ResultSet.fold
		(fun assignment ->
		  List.cons (List.map (fun vnm -> IdentMap.find vnm assignment) headers))
		results
		[])
	  in
	  [ messagef "Results of query %s |= %s" model_name (Formula.to_string formula);
	    Table { headers; rows }
	  ], env
    end

let rec exec_all env outputs = function
  | [] ->
    Ok (List.rev outputs)
  | item :: items ->
    (match exec_structure_item env item with
    | Error msg ->
      Error (List.rev outputs, msg)
    | Ok (output, env) ->
      exec_all env (List.rev_append output outputs) items)

let exec =
  exec_all IdentMap.empty []
