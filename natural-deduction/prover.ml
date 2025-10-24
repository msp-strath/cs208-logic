open Fol_formula

module type SOLVER = sig
  type store

  val initial : store

  val check_consistent : store -> bool

  val add_literal : bool * string * Term.t list -> store -> store
end

module Atom_solver = struct

  type store =
    | Inconsistent
    | Consistent of { positive : (string * Term.t list) list
                    ; negative : (string * Term.t list) list
                    }

  let initial =
    Consistent { positive = []; negative = [] }

  let check_consistent = function
    | Inconsistent -> false
    | Consistent _ -> true

  let add_literal (pol, rel, terms) store =
    match store with
    | Inconsistent -> Inconsistent
    | Consistent { positive; negative } ->
       let atom = rel, terms in
       match pol with
       | true ->
          if List.mem atom negative then Inconsistent
          else Consistent { positive = atom :: positive ; negative }
       | false ->
          if List.mem atom positive then Inconsistent
          else Consistent { positive ; negative = atom :: negative }

end

module Equality_solver = struct

  module UF = Union_find

  module TermSet = Set.Make (Term)
  module TermMap = Map.Make (Term)

  type constraint_set =
    { mutable terms         : TermSet.t UF.point TermMap.t
    }

  (* Adds a term and all its children to the congruence graph and
     returns the point for it *)
  let rec add_term graph parent_opt term =
    match TermMap.find_opt term graph.terms with
    | None ->
       let parent_set =
         match parent_opt with
         | None -> TermSet.empty
         | Some parent -> TermSet.singleton parent
       in
       let point = UF.make_class parent_set in
       graph.terms <- TermMap.add term point graph.terms;
       (match term with
       | Var _ -> point
       | Fun (_, terms) ->
          List.iter (fun child -> ignore (add_term graph (Some term) child)) terms;
          point)
    | Some point ->
       (match parent_opt with
       | None ->
          point
       | Some parent ->
          UF.update (TermSet.add parent) point;
          point)

  (* Test whether or not the two terms given are considered equal in the
     current state. *)
  let is_equal graph term1 term2 =
    let point1 = add_term graph None term1 in
    let point2 = add_term graph None term2 in
    UF.equal point1 point2

  (* Two terms are congruent if they have the same function symbol and
     all their children are equal. *)
  let congruent graph term1 term2 =
    match term1, term2 with
    | Var _, _ | _, Var _ -> false
    | Fun (f1, terms1), Fun (f2, terms2) ->
       String.equal f1 f2
       && List.length terms1 = List.length terms2
       && List.for_all2 (is_equal graph) terms1 terms2

  (* Equate two terms, propagating any congruences that become
     true. FIXME: could use a worklist to avoid recursion? *)
  let rec equate graph (point1, point2) =
    if not (UF.equal point1 point2) then
      let parents1 = UF.find point1 in
      let parents2 = UF.find point2 in
      UF.union TermSet.union point1 point2;
      TermSet.iter
        (fun parent1 ->
          TermSet.iter
            (fun parent2 ->
              if congruent graph parent1 parent2 then
                equate graph
                  (TermMap.find parent1 graph.terms,
                   TermMap.find parent2 graph.terms))
            parents2)
        parents1

  type store =
    (bool * string * Term.t list) list

  let initial = []

  let check_consistent atoms =
    let graph = { terms = TermMap.empty } in
    let true_tm = add_term graph None (Fun ("TRUE", [])) in
    let false_tm = add_term graph None (Fun ("FALSE", [])) in
    let eqs, diseqs =
      List.fold_left
        (fun (eqs, diseqs) literal ->
          match literal with
          | true, "=", [t1; t2] ->
             ((add_term graph None t1, add_term graph None t2) :: eqs, diseqs)
          | false, "=", [t1; t2] ->
             (eqs, (add_term graph None t1, add_term graph None t2) :: diseqs)
          | true, r, tms ->
             ((add_term graph None (Fun (r, tms)), true_tm) :: eqs, diseqs)
          | false, r, tms ->
             ((add_term graph None (Fun (r, tms)), false_tm) :: eqs, diseqs))
        ([] , [true_tm, false_tm])
        atoms
    in
    List.iter (equate graph) eqs;
    List.for_all (fun (p1, p2) -> not (UF.equal p1 p2)) diseqs

  let add_literal = List.cons

end

module Make (S : SOLVER) = struct

  open Fol_formula

  let combine x y = match x with
    | `Proved -> y
    | `Counter store -> `Counter store

  (* A simpistic tableaux prover *)
  let rec prove names store : (bool * formula) list -> [ `Proved | `Counter of S.store ] = function
    | [] ->
       if S.check_consistent store then
         `Counter store
       else
         `Proved

    | ((false, True) | (true, False))::fmlas ->
       prove names store fmlas

    | ((true, True) | (false, False))::_fmlas ->
       `Proved

    | ((true as pol), And (p, q) | (false as pol, Or (p, q)))::fmlas ->
       combine (prove names store ((pol, p)::fmlas)) (prove names store ((pol, q)::fmlas))

    | ((true as pol), Or (p, q) | (false as pol, And (p, q)))::fmlas ->
       prove names store ((pol, p)::(pol, q)::fmlas)

    | ((true as pol), Forall (x, p) | (false as pol, Exists (x, p)))::fmlas ->
       let fresh_x = NameSet.fresh_for names x in
       let p = Formula.subst x (Var fresh_x) p in
       let names = NameSet.add fresh_x names in
       prove names store ((pol, p)::fmlas)

    | (true, Imp (p, q))::fmlas ->
       prove names store ((false,p)::(true,q)::fmlas)
    | (false, Imp (p, q))::fmlas ->
       combine (prove names store ((true, p)::fmlas)) (prove names store ((false, q)::fmlas))

    | (pol, Not p)::fmlas ->
       prove names store ((not pol, p)::fmlas)

    | (pol, Atom (rel, terms))::fmlas ->
       let store = S.add_literal (not pol, rel, terms) store in
       prove names store fmlas

    | (true, Exists (_x, _p) | false, Forall (_x, _p))::fmlas ->
       (* FIXME: keep 'Ex(x,p)' in another store in case it can be
          instantiated with some other parts later. For now, just
          ignoring positive existentials.
        *)
       prove names store fmlas

  let prove names sequent =
    prove names S.initial sequent

end
