open Sexplib0.Sexp_conv

module Syntax = struct

  module Program_var : sig
    type t [@@deriving sexp]

    val of_string : string -> t option
    val to_string : t -> string
  end = struct
    type t =
      string
    [@@deriving sexp]

    let is_upper = function
      | 'A' .. 'Z' -> true
      | _ -> false

    let is_alphanumeric = function
      | '0' .. '9' | 'a' .. 'z' | 'A' .. 'Z' | '_' -> true
      | _ -> false

    let of_string s =
      let valid =
        String.length s > 0
        && is_upper s.[0]
        && String.for_all is_alphanumeric s
      in
      if valid then Some s else None

    let to_string s = s
  end

  type expr =
    | Var   of Program_var.t
    | Const of int
  (*     | Add   of expr * expr *)
  [@@deriving sexp]

  let expr_of_sexp_human = function
    | Sexplib.Type.Atom atm ->
       (match int_of_string_opt atm with
       | Some i -> Some (Const i)
       | None ->
          (match Program_var.of_string atm with
          | Some v -> Some (Var v)
          | None -> None))
    | Sexplib.Type.List _ ->
       None

  let string_of_expr = function
    | Var v -> Program_var.to_string v
    | Const i -> string_of_int i

  type rel =
    | Eq | Ne (* | Lt | Le | Gt | Ge *)
  [@@deriving sexp]

  let string_of_rel = function
    | Eq -> "="
    | Ne -> "!="

  type boolean_expr =
    | Rel of expr * rel * expr
  (*
    | And of boolean_expr * boolean_expr
    | Or  of boolean_expr * boolean_expr
    | Not of boolean_expr
   *)
  [@@deriving sexp]

  let rel_of_atom = function
    | "=" -> Some Eq
    | "!=" -> Some Ne
    | _ -> None

  let boolean_expr_of_sexp_human = function
    | Sexplib.Type.List [ Atom rel; e1; e2 ] ->
       (match rel_of_atom rel, expr_of_sexp_human e1, expr_of_sexp_human e2 with
       | None, _, _ | _, None, _ | _, _, None ->
          None
       | Some rel, Some e1, Some e2 ->
          Some (Rel (e1, rel, e2)))
    | _ ->
       None

  let string_of_boolean_expr = function
    | Rel (e1, r, e2) ->
       Printf.sprintf "%s %s %s"
         (string_of_expr e1)
         (string_of_rel r)
         (string_of_expr e2)
end

module Calculus = struct

  open Fol_formula
  open Syntax

  type meta_var =
    string

  let term_of_expr = function
    | Var var -> Term.Var (Program_var.to_string var)
    | Const i -> Term.Fun (string_of_int i, [])
    (* | Add (e1, e2) -> *)
    (*    Term.Fun ("+", [term_of_expr e1; term_of_expr e2]) *)

  let predicate_of_rel = function
    | Eq -> "="
    | Ne -> "!="
    (* | Lt -> "<" *)
    (* | Le -> "<=" *)
    (* | Gt -> ">" *)
    (* | Ge -> ">=" *)

  let formula_of_boolean_expr = function
    | Rel (e1, rel, e2) ->
       Atom (predicate_of_rel rel, [term_of_expr e1; term_of_expr e2])
    (* | And (p, q) -> *)
    (*    And (formula_of_boolean_expr p, formula_of_boolean_expr q) *)
    (* | Or (p, q) -> *)
    (*    Or (formula_of_boolean_expr p, formula_of_boolean_expr q) *)
    (* | Not p -> *)
    (*    Not (formula_of_boolean_expr p) *)

  type rule =
    | Done
    | Assign of Program_var.t * expr
    | Assert of formula
    | If     of boolean_expr
    | While  of boolean_expr
  [@@deriving sexp]

  type formula_or_meta =
    | Formula of formula
    | Meta    of meta_var
    | Or      of formula_or_meta * formula_or_meta

  type goal =
    | Program of { precond  : formula_or_meta
                 ; postcond : formula_or_meta
                 }

  type assumption =
    | Program_variable
    | Logic_variable

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
  let combine_update s1 s2 =
    MVarMap.union (fun _ a _b -> Some a) s1 s2

  type error = string

  open Generalities
  open Result_ext.Syntax

  let rec check_program_variable var = function
    | [] ->
       Result_ext.errorf "Program variable %s not in scope"
         (Program_var.to_string var)
    | (nm, Program_variable)::_ when String.equal (Program_var.to_string var) nm ->
       Ok ()
    | _::context ->
       check_program_variable var context

  let check_expr context = function
    | Const _ -> Ok ()
    | Var v   -> check_program_variable v context

  let check_boolean_expr context = function
    | Rel (e1, _, e2) ->
       let+ () = check_expr context e1
       and+ () = check_expr context e2
       in ()

  let name_set_of_context context =
    List.fold_right (fun (nm, _) -> NameSet.add nm) context NameSet.empty

  let rec scope_check_term names = function
    | Term.Var v ->
       if NameSet.mem v names then Ok ()
       else Error (Printf.sprintf "Name '%s' has not been declared" v)
    | Term.Fun (_, args) ->
       Result_ext.traverse_ (scope_check_term names) args

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

  let apply context rule = function
    | Program { precond = Meta _ | Or _; _ }->
       Error "Cannot work with unknown precondition"
    | Program { precond = Formula requires; postcond } ->
       (match rule with
       | Done ->
          (match postcond with
          | Formula ensures ->
             if Formula.alpha_equal requires ensures then
               Ok ([], empty_update)
             else
               Error "The precondition is not the same as the \
                      postcondition!"
          | Or _ ->
             Error "INTERNAL ERROR: unexpected Or"
          | Meta v ->
             Ok ([], MVarMap.singleton v requires))
       | Assign (program_var, expr) ->
          let* () = check_program_variable program_var context in
          let* () = check_expr context expr in
          let program_var = Program_var.to_string program_var in
          let logic_var =
            NameSet.fresh_for (name_set_of_context context) (String.lowercase_ascii program_var)
          in
          let p = Formula.subst program_var (Term.Var logic_var) requires in
          let e = Term.subst program_var (Term.Var logic_var) (term_of_expr expr) in
          let precond = Formula (Formula.Exists (logic_var, And (Atom ("=", [Term.Var program_var; e]), p))) in
          Ok ([ [], Program { precond; postcond } ], empty_update)
       | Assert fmla ->
          let* () = scope_check_formula (name_set_of_context context) fmla in
          (* FIXME: also check that requires |- fmla !!! Do this for
             equational logic with no functions... *)
          Ok ([ [], Program { precond = Formula fmla; postcond } ], empty_update)
       | If bool_expr ->
          let* () = check_boolean_expr context bool_expr in
          let cond = formula_of_boolean_expr bool_expr in
          (* FIXME: generate these! *)
          let mv1 = "R1" and mv2 = "R2" in
          Ok ([ [], Program { precond = Formula (And (cond, requires)); postcond = Meta mv1 }
              ; [], Program { precond = Formula (And (Not cond, requires)); postcond = Meta mv2 }
              ; [], Program { precond = Or (Meta mv1, Meta mv2); postcond }
              ],
              empty_update)
       | While bool_expr ->
          let* () = check_boolean_expr context bool_expr in
          let cond = formula_of_boolean_expr bool_expr in
          Ok ([ [], Program { precond = Formula (And (cond, requires)); postcond = Formula requires }
              ; [], Program { precond = Formula (And (Not cond, requires)); postcond }
              ], empty_update))

end

module UI : Proof_tree_UI2.UI_SPEC with module Calculus = Calculus = struct

  open Fol_formula

  module Calculus = Calculus

  let rec string_of_formula_or_meta = function
    | Calculus.Formula f -> Formula.to_string f
    | Calculus.Meta v    -> "?" ^ v
    | Calculus.Or (p, q) ->
       "(" ^ string_of_formula_or_meta p ^ ") ∨ (" ^ string_of_formula_or_meta q ^ ")"

  let string_of_goal = function
    | Calculus.Program { precond; postcond } ->
        Printf.sprintf "{%s} - {%s}"
          (string_of_formula_or_meta precond)
          (string_of_formula_or_meta postcond)

  let string_of_assumption nm = function
    | Calculus.Program_variable -> nm
    | Calculus.Logic_variable -> nm

  let label_of_rule = function
    | Calculus.Done -> "done"
    | Calculus.Assign (v, expr) ->
       Printf.sprintf "%s := %s" (Syntax.Program_var.to_string v) (Syntax.string_of_expr expr)
    | Calculus.Assert f ->
       Printf.sprintf "assert %s" (Formula.to_string f)
    | Calculus.If cond ->
       Printf.sprintf "if(%s)" (Syntax.string_of_boolean_expr cond)
    | Calculus.While cond ->
       Printf.sprintf "while(%s)" (Syntax.string_of_boolean_expr cond)

  let string_of_error e = e

  (* FIXME: replace this with a nicer parser that matches the output format. *)
  let parse_rule str =
    match Sexplib.Sexp.of_string str with
    | exception _ ->
       Error "command not understood"
    | Sexplib.Type.Atom "done" ->
       Ok Calculus.Done
    | Sexplib.Type.List [ Atom "if"; e ] ->
       (match Syntax.boolean_expr_of_sexp_human e with
       | None   -> Error "invalid boolean expression"
       | Some e -> Ok (If e))
    | Sexplib.Type.List [ Atom "while"; e ] ->
       (match Syntax.boolean_expr_of_sexp_human e with
       | None   -> Error "invalid boolean expression"
       | Some e -> Ok (While e))
    | Sexplib.Type.List [ Atom "assert"; Atom fmla ] ->
       (match Formula.of_string fmla with
       | Ok fmla -> Ok (Assert fmla)
       | Error _ -> Error "invalid formula")
    | Sexplib.Type.List [ Atom ":="; Atom v; e ] ->
       (match Syntax.Program_var.of_string v, Syntax.expr_of_sexp_human e with
       | None, _ | _, None ->
          Error "invalid assignment"
       | Some var, Some e ->
          Ok (Assign (var, e)))
    | _ ->
       Error "command not understood"

end

module Config_parser = struct
  open Generalities.Sexp_parser
  open Syntax
  open Fol_formula

  type config =
    { program_vars : Program_var.t list
    ; logic_vars   : string list
    ; precond      : formula
    ; postcond     : formula
    }

  let formula =
    let+? str = atom in
    Result.map_error
      (function `Parse e ->
         Parser_util.Driver.string_of_error e)
      (Fol_formula.Formula.of_string str)

  let program_var_p =
    let+? str = atom in
    Option.to_result
      ~none:"invalid program variable"
      (Program_var.of_string str)

  let logic_var_p =
    let+? str = atom in
    (* FIXME: lower case *)
    Ok str

  let config_p =
    tagged "hoare"
      (let+ program_vars = consume_opt "program_vars" (many program_var_p)
       and+ logic_vars   = consume_opt "logic_vars" (many logic_var_p)
       and+ precond      = consume_one "precond" (one formula)
       and+ postcond     = consume_one "postcond" (one formula) in
       let program_vars = Option.value ~default:[] program_vars in
       let logic_vars   = Option.value ~default:[] logic_vars in
       (* FIXME: check that requires and ensures are well-scoped in
          the program and logic vars *)
       { program_vars; logic_vars; precond; postcond })

end

let component config =
  match Config_parser.config_p (Sexplib.Sexp.of_string config) with
  | exception exn ->
     let message = "Configuration failure: " ^ Printexc.to_string exn in
     Widgets.Error_display.component message
  | Error err ->
     let detail = Generalities.Annotated.detail err in
     let message = "Configuration failure: " ^ detail in
     Widgets.Error_display.component message
  | Ok Config_parser.{ precond; postcond; program_vars; logic_vars } ->
     let module G = struct
         let assumptions =
           List.map (fun nm -> Syntax.Program_var.to_string nm, Calculus.Program_variable) program_vars
           @ List.map (fun nm -> nm, Calculus.Logic_variable) logic_vars
         let goal =
           Calculus.Program
             { precond = Formula precond
             ; postcond = Formula postcond
             }
       end
     in
     (module Proof_tree_UI2.Make (UI) (G) : Ulmus.PERSISTENT)
