open Fol_formula
module Env = Map.Make (String)

let eval_term env = function
  | Var x -> Env.find x env
  | Fun _ -> failwith "invalid formula: function symbol"

type refutation =
  | IsFalse
  | Equal of term * Model.entity * term
  | NotEqual of term * Model.entity * term * Model.entity
  | NotInRelation of string * term list * Model.entity list
  | ConclFalse of verification * refutation
  | AndLeft of refutation * formula
  | AndRight of formula * refutation
  | OrFail of refutation * refutation
  | NotTrue of verification
  | ForallFail of string * Model.entity * refutation
  | ExistsFail of string * formula * (Model.entity * refutation) list

and verification =
  | IsTrue
  | Equal of term * Model.entity * term
  | NotEqual of term * Model.entity * term * Model.entity
  | InRelation of string * term list * Model.entity list
  | HypFalse of refutation * formula
  | ConclTrue of formula * verification
  | And of verification * verification
  | OrLeft of verification * formula
  | OrRight of formula * verification
  | NotFalse of refutation
  | ForallSuc of string * formula * (Model.entity * verification) list
  | ExistsSuc of string * Model.entity * verification

type outcome = Verified of verification | Refuted of refutation

let rec pp_refutation fmt = function
  | IsFalse -> Format.fprintf fmt "False"
  | NotEqual (x1, e1, x2, e2) ->
      Format.fprintf fmt "%a = %a refuted : %a = %a, but %a = %a" Term.pp x1
        Term.pp x2 Term.pp x1 Model.Entity.pp e1 Term.pp x2 Model.Entity.pp e2
  | Equal (x1, e, x2) ->
      Format.fprintf fmt "%a != %a refuted : both equal to %a" Term.pp x1
        Term.pp x2 Model.Entity.pp e
  | NotInRelation (r, tms, entities) ->
      Format.fprintf fmt "%s(%a) refuted : %a not in interpretation of %s" r
        Term.pp_tms tms Model.Tuple.pp entities r
  | ConclFalse (verification, reason) ->
      Format.fprintf fmt
        "@[<v2>Hypothesis verified:@,%a@]@,@[<v2>but conclusion refuted:@,%a@]"
        pp_verification verification pp_refutation reason
  | OrFail (reason1, reason2) ->
      Format.fprintf fmt
        "@[<v>Both branches of 'or' refuted:@,@[<v 2>- %a@]@,@[<v 2>- %a@]@,@]"
        pp_refutation reason1 pp_refutation reason2
  | AndLeft (reason, _) ->
      Format.fprintf fmt "@[<v>First component refuted:@,%a@]" pp_refutation
        reason
  | AndRight (_, reason) ->
      Format.fprintf fmt "@[<v>Second component refuted:@,%a@]" pp_refutation
        reason
  | NotTrue verification ->
      Format.fprintf fmt
        "@[<v2>negation refuted, because the subformula was verified:@,%a@]"
        pp_verification verification
  | ForallFail (x, entity, refutation) ->
      Format.fprintf fmt "@[<v2>when %s = %a:@,%a@]" x Model.Entity.pp entity
        pp_refutation refutation
  | ExistsFail (x, _f, refutations) ->
      let pp_exists_case fmt (e, refutation) =
        Format.fprintf fmt "- @[<v2>when %s = %a:@,%a@]" x Model.Entity.pp e
          pp_refutation refutation
      in
      Format.fprintf fmt "@[<v2>Exists refuted:@,%a@]"
        Fmt.(list ~sep:(any "@,") pp_exists_case)
        refutations

and pp_verification fmt = function
  | IsTrue -> Format.fprintf fmt "True"
  | Equal (x1, e, x2) ->
      Format.fprintf fmt "%a = %a verified : both equal to %a" Term.pp x1
        Term.pp x2 Model.Entity.pp e
  | NotEqual (x1, e1, x2, e2) ->
      Format.fprintf fmt "%a != %a verified : %a = %a and %a = %a" Term.pp x1
        Term.pp x2 Term.pp x1 Model.Entity.pp e1 Term.pp x2 Model.Entity.pp e2
  | InRelation (r, tms, entities) ->
      Format.fprintf fmt "%s(%a) verified : %a in interpretation of %s" r
        Term.pp_tms tms Model.Tuple.pp entities r
  | HypFalse (reason, _) ->
      Format.fprintf fmt "@[<v>hypothesis refuted:@,%a@]" pp_refutation reason
  | ConclTrue (_, reason) ->
      Format.fprintf fmt "@[<v>conclusion verified:@,%a@]" pp_verification
        reason
  | OrLeft (reason, _) ->
      Format.fprintf fmt "@[<v>left branch verified:@,%a@]" pp_verification
        reason
  | OrRight (_, reason) ->
      Format.fprintf fmt "@[<v>right branch verified:@,%a@]" pp_verification
        reason
  | And (reason1, reason2) ->
      Format.fprintf fmt
        "@[<v>both branches of 'and' verified:@,\
         @[<v 2>- %a@]@,\
         @[<v 2>- %a@]@,\
         @]"
        pp_verification reason1 pp_verification reason2
  | NotFalse refutation ->
      Format.fprintf fmt
        "@[<v2>negation refuted, because the subformula was verified:@,%a@]"
        pp_refutation refutation
  | ForallSuc (x, _f, verifications) ->
      let pp_forall_case fmt (e, verification) =
        Format.fprintf fmt "- @[<v2>when %s = %a:@,%a@]" x Model.Entity.pp e
          pp_verification verification
      in
      Format.fprintf fmt "%a" (*  "@[<v2>For all verified:@,%a@]" *)
        Fmt.(list ~sep:(any "@,") pp_forall_case)
        verifications
  | ExistsSuc (x, e, verification) ->
      Format.fprintf fmt "@[<v2>exists verified with %s = %a:@,%a@]" x
        Model.Entity.pp e pp_verification verification

let pp_outcome fmt = function
  | Verified verification ->
      Format.fprintf fmt "@[<v2>Verified:@,%a@]" pp_verification verification
  | Refuted refutation ->
      Format.fprintf fmt "@[<v2>Refuted:@,%a@]" pp_refutation refutation

let rec check model env = function
  | True -> Verified IsTrue
  | False -> Refuted IsFalse
  | Atom ("=", [ tm1; tm2 ]) ->
      let x = eval_term env tm1 and y = eval_term env tm2 in
      if Model.Entity.equal x y then Verified (Equal (tm1, x, tm2))
      else Refuted (NotEqual (tm1, x, tm2, y))
  | Atom ("!=", [ tm1; tm2 ]) ->
      let x = eval_term env tm1 and y = eval_term env tm2 in
      if Model.Entity.equal x y then Refuted (Equal (tm1, x, tm2))
      else Verified (NotEqual (tm1, x, tm2, y))
  | Atom (r, tms) ->
      let xs = List.map (eval_term env) tms in
      if Model.contains r xs model then Verified (InRelation (r, tms, xs))
      else Refuted (NotInRelation (r, tms, xs))
  | Imp (f1, f2) -> (
      match check model env f1 with
      | Verified reason1 -> (
          match check model env f2 with
          | Verified reason2 -> Verified (ConclTrue (f1, reason2))
          | Refuted reason2 -> Refuted (ConclFalse (reason1, reason2)))
      | Refuted reason -> Verified (HypFalse (reason, f2)))
  | And (f1, f2) -> (
      match check model env f1 with
      | Verified reason1 -> (
          match check model env f2 with
          | Verified reason2 -> Verified (And (reason1, reason2))
          | Refuted reason -> Refuted (AndRight (f1, reason)))
      | Refuted reason ->
          (* FIXME: try the other side too? *)
          Refuted (AndLeft (reason, f2)))
  | Or (f1, f2) -> (
      match check model env f1 with
      | Verified reason -> Verified (OrLeft (reason, f2))
      | Refuted reason1 -> (
          match check model env f2 with
          | Verified reason -> Verified (OrRight (f1, reason))
          | Refuted reason2 -> Refuted (OrFail (reason1, reason2))))
  | Not f -> (
      match check model env f with
      | Verified reason -> Refuted (NotTrue reason)
      | Refuted reason -> Verified (NotFalse reason))
  | Forall (x, f) ->
      let rec check_all verfications = function
        | [] -> Verified (ForallSuc (x, f, List.rev verfications))
        | entity :: entities -> (
            let env = Env.add x entity env in
            match check model env f with
            | Verified reason ->
                check_all ((entity, reason) :: verfications) entities
            | Refuted reason -> Refuted (ForallFail (x, entity, reason)))
      in
      check_all [] model.universe
  | Exists (x, f) ->
      let rec check_all refutations = function
        | [] -> Refuted (ExistsFail (x, f, List.rev refutations))
        | entity :: entities -> (
            let env = Env.add x entity env in
            match check model env f with
            | Verified reason -> Verified (ExistsSuc (x, entity, reason))
            | Refuted reason ->
                check_all ((entity, reason) :: refutations) entities)
      in
      check_all [] model.universe

let check_closed model formula = check model Env.empty formula
