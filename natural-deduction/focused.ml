open Fol_formula
open Sexplib0.Sexp_conv

type assumption = A_Termvar | A_Formula of formula [@@deriving sexp]

type goal = Checking of formula | Synthesis of formula * formula
[@@deriving sexp]

type update = unit

let empty_update = ()
let update_goal () f = f
let update_assumption () a = a
let combine_update () () = ()

(* to add:

   - 'compute'; where A ==> B rewrites according to the computation rules
         A ==> B    G |- B
       ---------------------
             G |- A

   - if we have a bunch of computation rules:
     - are these

   - 'rewrite'
*)

type rule =
  (* introduction rules *)
  | Introduce of string
  | Truth
  | Split
  | Left
  | Right
  | Exists of term
  | NotIntro of string
  | Refl
  | Induction of string
  (* Focusing *)
  | Use of string
  (* On Focused goals: eliminators *)
  | Implies_elim
  | Instantiate of term
  | Conj_elim1
  | Conj_elim2
  | Cases of string * string
  | ExElim of string * string
  | Absurd
  | NotElim
  | Subst of string * formula (* FIXME: formula with placemarkers for terms *)
  | Rewrite of [ `ltr | `rtl ]
  | Close
[@@deriving sexp]

module Rule = struct
  type t = rule

  let name = function
    | Introduce _ -> "Introduce"
    | Truth -> "True"
    | Split -> "Split"
    | Left -> "Left"
    | Right -> "Right"
    | Implies_elim -> "Apply"
    | Conj_elim1 -> "First"
    | Conj_elim2 -> "Second"
    | Absurd -> "False"
    | Close -> "Done"
    | Use _ -> "Use"
    | Cases _ -> "Cases"
    | Instantiate _ -> "Instantiate"
    | Exists _ -> "Exists"
    | ExElim _ -> "Unpack"
    | NotIntro _ -> "¬-Intro"
    | NotElim -> "¬-Elim"
    | Refl -> "Reflexivity"
    | Subst _ -> "Subst"
    | Rewrite `ltr -> "Rewrite→"
    | Rewrite `rtl -> "Rewrite←"
    | Induction _ -> "Induction"
end

type error = string

let errormsg msg = Error msg
let errormsgf fmt = Printf.ksprintf errormsg fmt

module Scoping = struct
  let rec lookup_var x = function
    | [] -> false
    | (y, A_Termvar) :: context -> x = y || lookup_var x context
    | (_, A_Formula _) :: context -> lookup_var x context

  let rec term_well_scoped context = function
    | Var x ->
        if lookup_var x context then Ok ()
        else Error (Printf.sprintf "variable '%s' not in scope" x)
    | Fun (_, tms) -> terms_well_scoped context tms

  and terms_well_scoped context = function
    | [] -> Ok ()
    | tm :: tms -> (
        match term_well_scoped context tm with
        | Ok () -> terms_well_scoped context tms
        | Error e -> Error e)
end

let apply context rule goal =
  match rule with
  | Introduce x -> (
      match goal with
      | Checking (Imp (a, b)) -> Ok ([ ([ (x, A_Formula a) ], Checking b) ], ())
      | Checking (Forall (y, a)) ->
          if Scoping.lookup_var x context then
            errormsgf "variable '%s' is already used in the context" x
          else
            Ok
              ( [ ([ (x, A_Termvar) ], Checking (Formula.subst y (Var x) a)) ],
                () )
      | Checking _ ->
          errormsg "introduce not possible here: goal not an implication"
      | Synthesis _ -> errormsg "introduce not possible here: in focused mode")
  | Truth -> (
      match goal with
      | Checking True -> Ok ([], ())
      | Checking _ -> errormsg "true not possible here: goal not 'True'"
      | Synthesis _ -> errormsg "true not possible here: in focused mode")
  | Split -> (
      match goal with
      | Checking (And (a, b)) -> Ok ([ ([], Checking a); ([], Checking b) ], ())
      | Checking _ -> errormsg "split not possible here: goal not a conjunction"
      | Synthesis _ -> errormsg "split not possible here: in focused mode")
  | Left -> (
      match goal with
      | Checking (Or (a, _)) -> Ok ([ ([], Checking a) ], ())
      | Checking _ -> errormsg "left not possible here: goal not a disjunction"
      | Synthesis _ -> errormsg "left not possible here: in focused mode")
  | Right -> (
      match goal with
      | Checking (Or (_, b)) -> Ok ([ ([], Checking b) ], ())
      | Checking _ -> errormsg "right not possible here: goal not a disjunction"
      | Synthesis _ -> errormsg "right not possible here: in focused mode")
  | Exists term -> (
      match goal with
      | Checking (Exists (x, a)) -> (
          match Scoping.term_well_scoped context term with
          | Ok () -> Ok ([ ([], Checking (Formula.subst x term a)) ], ())
          | Error msg -> errormsgf "term not well scoped: %s" msg)
      | _ -> errormsg "cannot give an existential witness here")
  | NotIntro h -> (
      match goal with
      | Checking (Not a) -> Ok ([ ([ (h, A_Formula a) ], Checking False) ], ())
      | Checking _ ->
          errormsg "not-intro not possible here: goal is not a negation"
      | Synthesis _ -> errormsg "not-intro not possible here: in focused mode")
  | Refl -> (
      match goal with
      | Checking (Atom ("=", [ t1; t2 ])) ->
          if Term.equal t1 t2 then Ok ([], ())
          else errormsg "refl: terms not equal"
      | Checking _ -> errormsg "refl: not an equality"
      | Synthesis _ -> errormsg "refl not possible here: in focused mode")
  | Induction var -> (
      match goal with
      | Checking goal -> (
          match List.assoc var context with
          | exception Not_found -> errormsgf "Name ‘%s’ not in scope" var
          | A_Formula _ ->
              errormsgf
                "The name ‘%s’ refers to an assumed formula, not a term \
                 variable"
                var
          | A_Termvar ->
              let names =
                List.fold_left
                  (fun nms (nm, _) -> NameSet.add nm nms)
                  NameSet.empty context
              in
              let var2 = NameSet.fresh_for names var in
              let ih =
                NameSet.fresh_for (NameSet.add var2 names)
                  "induction-hypothesis"
              in
              Ok
                ( [
                    ([], Checking (Formula.subst var (Fun ("0", [])) goal));
                    ( [
                        (var2, A_Termvar);
                        (ih, A_Formula (Formula.subst var (Var var2) goal));
                      ],
                      Checking
                        (Formula.subst var (Fun ("S", [ Var var2 ])) goal) );
                  ],
                  () ))
      | Synthesis _ ->
          errormsg "induction not possible: a formula is already in focus")
  | Use varname -> (
      match goal with
      | Checking goal -> (
          match List.assoc varname context with
          | exception Not_found -> errormsgf "No such assumption ‘%s’" varname
          | A_Formula formula -> Ok ([ ([], Synthesis (formula, goal)) ], ())
          | A_Termvar -> errormsgf "cannot use a term variable ‘%s’" varname)
      | Synthesis _ ->
          errormsg "use not possible: a formula is already in focus")
  | Implies_elim -> (
      match goal with
      | Synthesis (Imp (a, b), c) ->
          Ok ([ ([], Checking a); ([], Synthesis (b, c)) ], ())
      | _ -> errormsg "apply not possible: not focused on an implication")
  | Instantiate term -> (
      match goal with
      | Synthesis (Forall (x, a), c) -> (
          match Scoping.term_well_scoped context term with
          | Ok () -> Ok ([ ([], Synthesis (Formula.subst x term a, c)) ], ())
          | Error msg -> errormsgf "term not well scoped: %s" msg)
      | _ ->
          errormsg
            "instantiate not possible: not focused on a universal formula")
  | Conj_elim1 -> (
      match goal with
      | Synthesis (And (a, _), c) -> Ok ([ ([], Synthesis (a, c)) ], ())
      | _ -> errormsg "first not possible: not focused on an conjunction")
  | Conj_elim2 -> (
      match goal with
      | Synthesis (And (_, b), c) -> Ok ([ ([], Synthesis (b, c)) ], ())
      | _ -> errormsg "second not possible: not focused on an conjunction")
  | Cases (x, y) -> (
      match goal with
      | Synthesis (Or (a, b), c) ->
          Ok
            ( [
                ([ (x, A_Formula a) ], Checking c);
                ([ (y, A_Formula b) ], Checking c);
              ],
              () )
      | _ -> errormsg "cases not possible: not focused on an disjunction")
  | ExElim (x, y) -> (
      match goal with
      | Synthesis (Exists (z, a), c) ->
          if Scoping.lookup_var x context then
            errormsgf "variable '%s' is already in scope" x
          else
            Ok
              ( [
                  ( [
                      (x, A_Termvar); (y, A_Formula (Formula.subst z (Var x) a));
                    ],
                    Checking c );
                ],
                () )
      | _ -> errormsg "unpack not possible: not focused on an existential")
  | Absurd -> (
      match goal with
      | Synthesis (False, _) -> Ok ([], ())
      | _ -> errormsg "false not possible: not focused on 'F' (false)")
  | NotElim -> (
      match goal with
      | Synthesis (Not a, _) -> Ok ([ ([], Checking a) ], ())
      | _ -> errormsg "not-elim not possible: not focused on a negation")
  | Subst (x, pattern) -> (
      match goal with
      | Synthesis (Atom ("=", [ t1; t2 ]), goal) ->
          if Formula.alpha_equal (Formula.subst x t1 pattern) goal then
            Ok ([ ([], Checking (Formula.subst x t2 pattern)) ], ())
          else errormsg "subst: pattern with LHS does not match goal"
            (* FIXME: much better error message *)
      | _ -> errormsg "substitution not possible: not focused on an equality")
  | Rewrite dir -> (
      match goal with
      | Synthesis (Atom ("=", [ t1; t2 ]), goal) ->
          let t1, t2 = match dir with `ltr -> (t1, t2) | `rtl -> (t2, t1) in
          let goal' = Formula.rewrite t1 t2 goal in
          if Formula.alpha_equal goal goal' then
            Error
              ("nothing to rewrite in this direction: the term "
             ^ Term.to_string t1 ^ " does not appear in the goal")
          else Ok ([ ([], Checking goal') ], ())
      | _ -> errormsg "rewrite not possible: not focused on an equality")
  | Close -> (
      match goal with
      | Synthesis (a, c) ->
          if Formula.alpha_equal a c then Ok ([], ())
          else errormsg "focus and goal do not match!"
      | Checking _ ->
          errormsg "done not possible: no formula is currently in focus")
