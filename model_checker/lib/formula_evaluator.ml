open! Generalities

module type STRUCTURE = sig
  type t

  type individual

  type predicate_symbol

  module Domain : Boolean_algebra.S

  val universe : t -> individual Seq.t

  val predicate : t -> predicate_symbol -> individual list -> Domain.t

  val equal : individual -> individual -> Domain.t

  (* val for_all : (individual -> v) -> v *)
  (* val exists : (individual -> v) -> v *)
end

module Make
  (S : STRUCTURE with type individual = string and type predicate_symbol = string) :
sig
  module Env : Map.S with type key = string and type 'a t = 'a Map.Make(String).t
  val eval_formula : S.t -> S.individual Env.t -> Fol_formula.formula -> S.Domain.t
end =
struct

  open Fol_formula

  module Env = Map.Make (String)

  module Domain = S.Domain

  let eval_term local_env = function
    | Var v -> Env.find v local_env
    | Fun _ -> failwith "internal error: Fun in formula"

  (** [eval_formula structure local_env fmla] evaluates the formula [fmla],
      using [structure] to interpret predicate symbols and equality,
      and [local_env] to interpret free variables. Raises {!Not_found}
      if [local_env] does not define all of the free variables in
      [fmla].

      *)
  let rec eval_formula model local_env = function
    | True ->
      Domain.one
    | False ->
      Domain.zero
    | Atom ("=", [tm1; tm2]) ->
      S.equal (eval_term local_env tm1) (eval_term local_env tm2)
    | Atom ("!=", [tm1; tm2]) ->
      Domain.neg (S.equal (eval_term local_env tm1) (eval_term local_env tm2))
    | Atom (pred, tms) ->
      let tuple = List.map (eval_term local_env) tms in
      S.predicate model pred tuple
    | Imp (p, q) ->
      Domain.disj [
	Domain.neg (eval_formula model local_env p);
	eval_formula model local_env q;
      ]
    | And (p, q) ->
      Domain.conj [
	eval_formula model local_env p;
	eval_formula model local_env q;
      ]
    | Or (p, q) ->
      Domain.disj [
	eval_formula model local_env p;
	eval_formula model local_env q;
      ]
    | Not p ->
      Domain.neg (eval_formula model local_env p)
    | Forall (vnm, p) ->
      model
      |> S.universe
      |> Seq.map (fun x ->
	   eval_formula model (Env.add vnm x local_env) p)
      |> List.of_seq
      |> Domain.conj
    | Exists (vnm, p) ->
      model
      |> S.universe
      |> Seq.map (fun x ->
	   eval_formula model (Env.add vnm x local_env) p)
      |> List.of_seq
      |> Domain.disj

end
