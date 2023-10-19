(* From a vocabulary and axiomatisation, generate models for a given
   cardinality, using Msat. *)

(* scheme:
   - assume the universe has cardinality 'n'
   - for each predicate pred/k, have n^k atoms
   - unfold quantifiers to conjunctions and disjunctions
*)

module type LOGIC = sig
  type t
  type v

  val gen : t -> v
  val add_implies : t -> v -> v -> v
  val add_conj : t -> v list -> v
  val add_disj : t -> v list -> v
  val add_not : t -> v -> v
  val add_assert : t -> v -> unit
end

module L = struct
  type t = Msat_sat.solver * int ref
  type v = Msat_sat.Int_lit.t

  let neg = Msat_sat.Int_lit.neg

  (* FIXME: memoisation:
     - have a hash table that stores operations -> atom names
     - sort the conjunctions and disjunctions before use, and remove duplicates
     - also store ones that are definitely true or definitely false, and use this in simplification of ANDs and ORs
  *)

  let create () = (Msat_sat.create (), ref 1)

  let gen (_, r) =
    let v = !r in
    incr r;
    Msat_sat.Int_lit.make v

  let add_conj ((solver, _) as t) vs =
    let x = gen t in
    Msat_sat.assume solver
      ((x :: List.map neg vs) :: List.map (fun v -> [ neg x; v ]) vs)
      ();
    x

  let add_disj ((solver, _) as t) vs =
    let x = gen t in
    Msat_sat.assume solver
      ((neg x :: vs) :: List.map (fun v -> [ x; neg v ]) vs)
      ();
    x

  let add_not ((solver, _) as t) v =
    let x = gen t in
    Msat_sat.assume solver [ [ neg x; neg v ]; [ x; v ] ] ();
    x

  let add_implies ((solver, _) as t) v1 v2 =
    let x = gen t in
    Msat_sat.assume solver
      [ [ neg v1; v2; neg x ]; [ v1; x ]; [ neg v2; x ] ]
      ();
    x

  let add_assert (solver, _) v = Msat_sat.assume solver [ [ v ] ] ()
end

open Fol_formula
module Env = Map.Make (String)

let enumerate n =
  let rec enumerate xs = function
    | 0 -> xs
    | n -> enumerate ((n - 1) :: xs) (n - 1)
  in
  enumerate [] n

let eval env = function
  | Var x -> Env.find x env
  | Fun (s, []) -> (
      match int_of_string s with
      | i -> i (* FIXME:check that it is less than the cardinality *)
      | exception _ -> invalid_arg "function symbol found")
  | Fun _ -> invalid_arg "function symbol found"

(* Optimisations:
   - Symmetric relations
   - So can (partial) functional relations?
   - How can we generate unique models up to permutation of the universe?
     - This would significantly
   - <=> can be handled specially so save space
     - could just be pattern matched specially below??
   - Exists unique could be translated into an XOR?
     - An OR + n^2 pairwise mutual exclusion constraints
   - Things like: there are exactly three things that are colours
   - Special case finite domain arithmetic

   - Symmetry breaking predicates, computed from how we use the
*)

(* - synthesis from partial models
   - the universe is always given in advance
   - predicates can have definitely "yes" bits, and definitely "no" bits
*)

let rec translate_formula cardinality table clauses env = function
  | True -> L.add_conj clauses []
  | False -> L.add_disj clauses []
  | Atom ("=", [ tm1; tm2 ]) ->
      let x1 = eval env tm1 in
      let x2 = eval env tm2 in
      if x1 = x2 then L.add_conj clauses [] else L.add_disj clauses []
  | Atom ("lt", [ tm1; tm2 ]) ->
      let x1 = eval env tm1 in
      let x2 = eval env tm2 in
      if x1 < x2 then L.add_conj clauses [] else L.add_disj clauses []
  | Atom (r, tms) -> (
      let name = (r, List.map (eval env) tms) in
      match Hashtbl.find table name with
      | exception Not_found ->
          let v = L.gen clauses in
          Hashtbl.add table name v;
          v
      | v -> v)
  | Imp (f1, f2) ->
      let v1 = translate_formula cardinality table clauses env f1 in
      let v2 = translate_formula cardinality table clauses env f2 in
      L.add_implies clauses v1 v2
  | And (f1, f2) ->
      let v1 = translate_formula cardinality table clauses env f1 in
      let v2 = translate_formula cardinality table clauses env f2 in
      L.add_conj clauses [ v1; v2 ]
  | Or (f1, f2) ->
      let v1 = translate_formula cardinality table clauses env f1 in
      let v2 = translate_formula cardinality table clauses env f2 in
      L.add_disj clauses [ v1; v2 ]
  | Not f ->
      let v = translate_formula cardinality table clauses env f in
      L.add_not clauses v
  | Forall (x, f) ->
      enumerate cardinality
      |> List.map (fun i ->
             translate_formula cardinality table clauses (Env.add x i env) f)
      |> L.add_conj clauses
  | Exists (x, f) ->
      enumerate cardinality
      |> List.map (fun i ->
             translate_formula cardinality table clauses (Env.add x i env) f)
      |> L.add_disj clauses

let assert_axioms cardinality table clauses axioms =
  axioms
  |> List.iter (fun f ->
         let v = translate_formula cardinality table clauses Env.empty f in
         L.add_assert clauses v)

let make_entity n =
  let letter i = Char.chr (i + 97) in
  if n < 26 then String.make 1 (letter n)
  else
    let buffer = Buffer.create 5 in
    let rec loop n =
      if n >= 0 then (
        Buffer.add_char buffer (letter (n mod 26));
        loop ((n / 26) - 1))
    in
    loop n;
    let l = Buffer.length buffer in
    String.init l (fun i -> Buffer.nth buffer (l - i - 1))

let make_universe cardinality = enumerate cardinality |> List.map make_entity

let extract_model cardinality table eval vocab =
  (* let open Model_checker in *)
  let relations =
    vocab.Vocabulary.pred_arity
    |> PredicateMap.map (fun _ -> Model.TupleSet.empty)
    |> Hashtbl.fold
         (fun (r, tuple) v relations ->
           if eval v then
             let tupleset = PredicateMap.find r relations in
             let tuple = List.map make_entity tuple in
             let tupleset = Model.TupleSet.add tuple tupleset in
             PredicateMap.add r tupleset relations
           else relations)
         table
  in
  Model.{ universe = make_universe cardinality; relations }

let generate cardinality vocab axioms =
  let table = Hashtbl.create 1024 in
  let ((solver, _) as clauses) = L.create () in
  assert_axioms cardinality table clauses axioms;
  match Msat_sat.solve solver with
  | Msat_sat.Unsat _ ->
      Error (Printf.sprintf "No model found of cardinality %d" cardinality)
  | Msat_sat.Sat { eval; _ } ->
      let model = extract_model cardinality table eval vocab in
      (* add the negation of this model, and iterate to generate more
         models *)
      Ok model
