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

         (* TODO: from sexps *)
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

  type goal =
    { requires : formula_or_meta
    ; ensures  : formula_or_meta
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
  let update_formula subst = function
    | Formula f -> Formula f
    | Meta v ->
       match MVarMap.find_opt v subst with
       | None -> Meta v
       | Some f -> Formula f
  let update_goal subst { requires; ensures } =
    { requires = update_formula subst requires
    ; ensures  = update_formula subst ensures
    }
  let combine_update s1 s2 =
    MVarMap.union (fun _ a _b -> Some a) s1 s2

  type error = string

  let apply _context rule { requires; ensures } =
    match requires with
    | Meta _ ->
       Error "Cannot work with unknown precondition"
    | Formula requires ->
       match rule with
       | Done ->
          (match ensures with
          | Formula ensures ->
             if Formula.alpha_equal requires ensures then
               Ok ([], empty_update)
             else
               Error "Requires is not equal to ensures!"
          | Meta v ->
             Ok ([], MVarMap.singleton v requires))
       | Assign (program_var, expr) ->
          (* FIXME: check program_var and expr are well scoped *)
          let program_var = Program_var.to_string program_var in
          let logic_var = String.lowercase_ascii program_var in
          (* FIXME: make sure it is fresh for the context *)
          let p = Formula.subst program_var (Term.Var logic_var) requires in
          let e = Term.subst program_var (Term.Var logic_var) (term_of_expr expr) in
          let requires = Formula (Formula.Exists (logic_var, And (Atom ("=", [Term.Var program_var; e]), p))) in
          Ok ([ [], { requires; ensures } ], empty_update)
       | Assert fmla ->
          (* FIXME: Scope check fmla *)
          (* FIXME: also check that requires |- fmla !!! Do this for
             equational logic with no functions... *)
          Ok ([ [], { requires = Formula fmla; ensures } ], empty_update)
       | If _bool_expr ->
          Error "implement If"
       | While bool_expr ->
          (* scope check 'bool_expr' *)
          let cond = formula_of_boolean_expr bool_expr in
          Ok ([ [], { requires = Formula (And (cond, requires)); ensures = Formula requires }
              ; [], { requires = Formula (And (Not cond, requires)); ensures }
              ], empty_update)

end

module UI : Proof_tree_UI2.UI_SPEC with module Calculus = Calculus = struct

  open Fol_formula

  module Calculus = Calculus

  let string_of_formula_or_meta = function
    | Calculus.Formula f -> Formula.to_string f
    | Calculus.Meta v    -> "?" ^ v

  let string_of_goal { Calculus.requires; ensures } =
    Printf.sprintf "{%s} - {%s}"
      (string_of_formula_or_meta requires)
      (string_of_formula_or_meta ensures)

  let string_of_assumption _nm = function
    | Calculus.Program_variable -> "program variable"
    | Calculus.Logic_variable -> "logic variable"

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
    ; requires     : formula
    ; ensures      : formula
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
       and+ requires     = consume_one "requires" (one formula)
       and+ ensures      = consume_one "ensures" (one formula) in
       let program_vars = Option.value ~default:[] program_vars in
       let logic_vars   = Option.value ~default:[] logic_vars in
       { program_vars; logic_vars; requires; ensures })

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
  | Ok Config_parser.{ requires; ensures; program_vars; logic_vars } ->
     let module G = struct
         let assumptions =
           List.map (fun nm -> Syntax.Program_var.to_string nm, Calculus.Program_variable) program_vars
           @ List.map (fun nm -> nm, Calculus.Logic_variable) logic_vars
         let goal =
           Calculus.{ requires = Formula requires; ensures = Formula ensures }
       end
     in
     (module Proof_tree_UI2.Make (UI) (G) : Ulmus.PERSISTENT)
