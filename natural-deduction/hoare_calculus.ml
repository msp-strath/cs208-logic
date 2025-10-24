open Generalities
open Sexplib0.Sexp_conv
open Fol_formula

type meta_var =
  string

let gen_meta =
  let next = ref 0 in
  fun () ->
  let id = !next in
  incr next;
  "P" ^ string_of_int id

(******************************************************************************)
(* Boolean Expressions *)
type rel = Eq | Ne [@@deriving sexp]

let string_of_rel = function
  | Eq -> "="
  | Ne -> "!="

type boolean_expr =
  | Rel of Term.t * rel * Term.t [@@deriving sexp]

let string_of_boolean_expr = function
  | Rel (e1, r, e2) ->
     Printf.sprintf "%s %s %s"
       (Term.to_string e1)
       (string_of_rel r)
       (Term.to_string e2)

let formula_of_boolean_expr = function
  | Rel (e1, Eq, e2) ->
     Atom ("=", [e1; e2])
  | Rel (e1, Ne, e2) ->
     Not (Atom ("=", [e1; e2]))

let formula_of_boolean_expr_negated = function
  | Rel (e1, Eq, e2) ->
     Not (Atom ("=", [e1; e2]))
  | Rel (e1, Ne, e2) ->
     Atom ("=", [e1; e2])

type program_rule =
  | End
  | Assign of string * Term.t
  | Assert of formula
  | If     of boolean_expr
  | While  of boolean_expr
  [@@deriving sexp]

type rule =
  | Program_rule of program_rule
  | Proof_rule   of Focused.rule
  [@@deriving sexp]

type formula_or_meta =
  | Formula of formula
  | Meta    of meta_var
  | Or      of formula_or_meta * formula_or_meta

let rec pp_formula_or_meta = function
  | Formula f -> Formula.to_doc f
  | Meta v    -> Pretty.text ("?" ^ v)
  | Or (p, q) -> Pretty.(text "(" ^^ pp_formula_or_meta p ^^ text ") ∨ (" ^^  pp_formula_or_meta q ^^ text ")")

type goal =
  | Program of
      { precond  : formula_or_meta
      ; postcond : formula_or_meta
      }
  | Entailment of Focused.goal

type assumption =
  | Program_variable
  | Logic_variable
  | Assumed_formula of formula

(* Rules (forward reasoning to construct the program)

   if the 'requires' is not yet instantiated, then disallow any rule application.

   end:           {P}-{P}.
     - if the second one is a meta-variable, then it can be instantiated here.

   assign x := E: {P}-{Q} <- {EX y. x = E[y/x] /\ P[y/x]}-{Q}.

   implies:       {P}-{Q} <- P |- P', {P'}-{Q}.

   if E:          {P}-{Q} <- {E /\ P}-{Q1}, {¬E /\ P}-{Q2}, {Q1 \/ Q2}-{Q}
     - makes two new meta-variables, one for each branch

   while E:       {P}-{Q} <- {E /\ P}-{P}, {¬E /\ P}-{Q}

 *)

(******************************************************************************)
(* Updates and substitutions *)

module MVarMap = Map.Make (String)

type update = formula MVarMap.t

let empty_update = MVarMap.empty
let update_assumption _subst assump = assump
let rec update_formula subst = function
  | Formula f -> Formula f
  | Meta v ->
     (match MVarMap.find_opt v subst with
     | None -> Meta v
     | Some f -> Formula f)
  | Or (p, q) ->
     (match update_formula subst p, update_formula subst q with
     | Formula p, Formula q -> Formula (Or (p, q))
     | p, q -> Or (p, q))
let update_goal subst = function
  | Program { precond; postcond } ->
     Program
       { precond = update_formula subst precond
       ; postcond  = update_formula subst postcond
       }
  | Entailment _ as goal ->
     goal
let combine_update s1 s2 =
  MVarMap.union (fun _ a _b -> Some a) s1 s2

type error = string

open Result_ext.Syntax

(** Check that a variable is declared as a program variable in the
    current scope. *)
let rec check_program_variable var = function
  | [] ->
     Result_ext.errorf "Program variable %s not in scope"
       var
  | (nm, Program_variable)::_ when String.equal var nm ->
     Ok ()
  | _::context ->
     check_program_variable var context

(** Check a term is well-scoped as a program expression *)
let rec check_expr context = function
  | Term.Var v ->
     check_program_variable v context
  | Term.Fun (_, tms) ->
     Result_ext.traverse_ (check_expr context) tms

(** Check that a boolean expression is well-scoped as a program
    expression *)
let check_boolean_expr context = function
  | Rel (e1, _, e2) ->
     let+ () = check_expr context e1
     and+ () = check_expr context e2
     in ()

let name_set_of_context context =
  List.fold_right (fun (nm, _) -> NameSet.add nm) context NameSet.empty

(** Check that a term is well-scoped for logical variables *)
let rec scope_check_term names = function
  | Term.Var v ->
     if NameSet.mem v names then Ok ()
     else Error (Printf.sprintf "Name '%s' has not been declared" v)
  | Term.Fun (_, args) ->
     Result_ext.traverse_ (scope_check_term names) args

(** Scope check a formula. FIXME: move this to Fol_formula. *)
let rec scope_check_formula names = function
  | True | False ->
     Ok ()
  | Atom (_, terms) ->
     Result_ext.traverse_ (scope_check_term names) terms
  | Imp (p, q) | Or (p, q) | And (p, q) ->
     let+ () = scope_check_formula names p
     and+ () = scope_check_formula names q
     in ()
  | Not p ->
     scope_check_formula names p
  | Forall (x, p) | Exists (x, p) ->
     scope_check_formula (NameSet.add x names) p

let to_focused_context =
  List.map
    (function
     | (nm, (Program_variable | Logic_variable)) -> (nm, Focused.A_Termvar)
     | (nm, Assumed_formula f)                   -> (nm, Focused.A_Formula f))

let of_focused_context =
  List.map
    (function
     | (nm, Focused.A_Termvar)   -> (nm, Logic_variable)
     | (nm, Focused.A_Formula f) -> (nm, Assumed_formula f))

let apply context rule = function
  | Program { precond = Meta _ | Or _; _ }->
     Error "Cannot work with unknown precondition"
  | Program { precond = Formula precond; postcond } ->
     (match rule with
     | Program_rule End ->
        (match postcond with
        | Formula postcond ->
           if Formula.alpha_equal precond postcond then
             Ok ([], empty_update)
           else
             Ok ([ ["H", Assumed_formula precond ], Entailment (Focused.Checking postcond)
                 ], empty_update)
        | Or _ ->
           Error "INTERNAL ERROR: unexpected Or"
        | Meta v ->
           Ok ([], MVarMap.singleton v precond))
     | Program_rule (Assign (program_var, expr)) ->
        let* () = check_program_variable program_var context in
        let* () = check_expr context expr in
        let logic_var =
          NameSet.fresh_for (name_set_of_context context) (String.lowercase_ascii program_var)
        in
        let p = Formula.subst program_var (Term.Var logic_var) precond in
        let e = Term.subst program_var (Term.Var logic_var) expr in
        let precond = Formula (Formula.Exists (logic_var, And (Atom ("=", [Term.Var program_var; e]), p))) in
        Ok ([ [], Program { precond; postcond } ], empty_update)
     | Program_rule (Assert fmla) ->
        let* () = scope_check_formula (name_set_of_context context) fmla in
        Ok ([ ["H", Assumed_formula precond], Entailment (Focused.Checking fmla)
            ; [], Program { precond = Formula fmla; postcond } ],
            empty_update )
     | Program_rule (If bool_expr) ->
        let* () = check_boolean_expr context bool_expr in
        let cond = formula_of_boolean_expr bool_expr in
        let mv1 = gen_meta () and mv2 = gen_meta () in
        Ok ([ [], Program { precond = Formula (And (cond, precond)); postcond = Meta mv1 }
            ; [], Program { precond = Formula (And (Not cond, precond)); postcond = Meta mv2 }
            ; [], Program { precond = Or (Meta mv1, Meta mv2); postcond }
            ],
            empty_update)
     | Program_rule (While bool_expr) ->
        let* () = check_boolean_expr context bool_expr in
        let cond = formula_of_boolean_expr bool_expr in
        let condn = formula_of_boolean_expr_negated bool_expr in
        Ok ([ [], Program { precond = Formula (And (cond, precond)); postcond = Formula precond }
            ; [], Program { precond = Formula (And (condn, precond)); postcond }
            ], empty_update)
     | Proof_rule _ ->
        Error "Cannot use a proof rule here")
  | Entailment goal ->
     (match rule with
     | Program_rule _ ->
        Error "Cannot use a program rule here"
     | Proof_rule rule ->
        let context = to_focused_context context in
        let* subgoals, () = Focused.apply context rule goal in
        Ok (List.map (fun (assumps, subgoal) -> (of_focused_context assumps, Entailment subgoal)) subgoals,
            empty_update))
