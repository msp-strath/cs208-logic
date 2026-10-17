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
type structure = {
  universe : IdentSet.t; (* individuals, as a set of names *)
  predicate_defns : (int * TupleSet.t option) IdentMap.t;
}

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
      Result_ext.errorf
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
	WFF.valid_closed_formula predicates formula)
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
let build_structure predicates defns =
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

module type BOOLEAN_ALGEBRA = sig
  type t
  val one : t
  val zero : t
  val conj : t list -> t
  val disj : t list -> t
  val neg  : t -> t
end

module BoolBA = struct
  type t = bool
  let one = true
  let zero = false
  let conj = List.fold_left (&&) true
  let disj = List.fold_left (||) false
  let neg = not
end

module type FO_STRUCTURE = sig
  type t
  type individual
  type v
  val universe : t -> individual Seq.t
  val predicate : t -> string -> individual list -> v
  val equal : individual -> individual -> v
  (* val for_all : (individual -> v) -> v *)
  (* val exists : (individual -> v) -> v *)
end

module ConcreteStructure = struct
  type t = structure
  type individual = string
  type v = bool
  let universe model = IdentSet.to_seq model.universe
  let predicate model pred tuple =
    match IdentMap.find pred model.predicate_defns with
    | _, Some tuples -> TupleSet.mem tuple tuples
    | _, None -> failwith "undefined predicate"
  let equal x y = String.equal x y
end

module EvalFormula
  (BA : BOOLEAN_ALGEBRA)
  (S : FO_STRUCTURE with type v = BA.t and type individual = string) =
struct

  let eval_term local_env = function
    | Var v -> IdentMap.find v local_env
    | Fun _ -> failwith "internal error: Fun in formula"

  let rec eval_formula model local_env = function
    | True -> BA.one
    | False -> BA.zero
    | Atom ("=", [tm1; tm2]) ->
      S.equal (eval_term local_env tm1) (eval_term local_env tm2)
    | Atom ("!=", [tm1; tm2]) ->
      BA.neg (S.equal (eval_term local_env tm1) (eval_term local_env tm2))
    | Atom (pred, tms) ->
      let tuple = List.map (eval_term local_env) tms in
      S.predicate model pred tuple
    | Imp (p, q) ->
      BA.disj [
	BA.neg (eval_formula model local_env p);
	eval_formula model local_env q;
      ]
    | And (p, q) ->
      BA.conj [
	eval_formula model local_env p;
	eval_formula model local_env q;
      ]
    | Or (p, q) ->
      BA.disj [
	eval_formula model local_env p;
	eval_formula model local_env q;
      ]
    | Not p ->
      BA.neg (eval_formula model local_env p)
    | Forall (vnm, p) ->
      model
      |> S.universe
      |> Seq.map (fun x ->
	   eval_formula model (IdentMap.add vnm x local_env) p)
      |> List.of_seq
      |> BA.conj
    | Exists (vnm, p) ->
      model
      |> S.universe
      |> Seq.map (fun x ->
	   eval_formula model (IdentMap.add vnm x local_env) p)
      |> List.of_seq
      |> BA.disj
end

module QueryEngine = struct

  module BoolValued = EvalFormula (BoolBA) (ConcreteStructure)

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
  | [] -> Ok ()
  | invalid ->
    Result_ext.errorf "The axioms %s do not hold for this model"
      (String.concat ", " invalid)

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
	  let* structure = build_structure theory.predicates defns in
	  let+ () = check_axioms theory structure in
	  messagef "Model '%s' for theory '%s' defined" name theory_name,
	  IdentMap.add name (Model (theory_name, structure)) env
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
	let+ free_vars = WFF.valid_formula theory.predicates formula in
	let results =
	  QueryEngine.satisfying_assignments model free_vars formula
	in
	if WFF.VarSet.is_empty free_vars then
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
