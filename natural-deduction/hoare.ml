open Generalities
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

  (* FIXME: make this a 'Term' *)
  type expr =
    | Var   of Program_var.t
    | Const of int
    | Add   of expr * expr
  [@@deriving sexp]

  let rec expr_of_sexp_human = function
    | Sexplib.Type.Atom atm ->
       (match int_of_string_opt atm with
       | Some i -> Some (Const i)
       | None ->
          (match Program_var.of_string atm with
          | Some v -> Some (Var v)
          | None -> None))
    | Sexplib.Type.List [Atom "add"; e1; e2] ->
       (match expr_of_sexp_human e1, expr_of_sexp_human e2 with
       | Some e1, Some e2 ->
          Some (Add (e1, e2))
       | None, _ | _, None ->
          None)
    | Sexplib.Type.List _ ->
       None

  let rec string_of_expr = function
    | Var v -> Program_var.to_string v
    | Const i -> string_of_int i
    | Add (e1, e2) ->
       Printf.sprintf "add(%s, %s)"
         (string_of_expr e1)
         (string_of_expr e2)

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

  let gen_meta =
    let next = ref 0 in
    fun () ->
    let id = !next in
    incr next;
    "P" ^ string_of_int id

  let rec term_of_expr = function
    | Var var -> Term.Var (Program_var.to_string var)
    | Const i -> Term.Fun (string_of_int i, [])
    | Add (e1, e2) ->
       Term.Fun ("add", [term_of_expr e1; term_of_expr e2])

  let formula_of_boolean_expr = function
    | Rel (e1, Eq, e2) ->
       Atom ("=", [term_of_expr e1; term_of_expr e2])
    | Rel (e1, Ne, e2) ->
       Not (Atom ("=", [term_of_expr e1; term_of_expr e2]))

  type program_rule =
    | End
    | Assign of Program_var.t * expr
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

  let rec check_program_variable var = function
    | [] ->
       Result_ext.errorf "Program variable %s not in scope"
         (Program_var.to_string var)
    | (nm, Program_variable)::_ when String.equal (Program_var.to_string var) nm ->
       Ok ()
    | _::context ->
       check_program_variable var context

  let rec check_expr context = function
    | Const _ ->
       Ok ()
    | Var v ->
       check_program_variable v context
    | Add (e1, e2) ->
       let+ () = check_expr context e1
       and+ () = check_expr context e2
       in ()

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
          let program_var = Program_var.to_string program_var in
          let logic_var =
            NameSet.fresh_for (name_set_of_context context) (String.lowercase_ascii program_var)
          in
          let p = Formula.subst program_var (Term.Var logic_var) precond in
          let e = Term.subst program_var (Term.Var logic_var) (term_of_expr expr) in
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
          Ok ([ [], Program { precond = Formula (And (cond, precond)); postcond = Formula precond }
              ; [], Program { precond = Formula (And (Not cond, precond)); postcond }
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

end

module Make_renderer (Html : Html_sig.S) = struct
  open Focused_proof_renderer.HTML_Bits (Html)
  open Fol_formula
  open Syntax

  module FR = Focused_proof_renderer.Make (Html)

  let (@|) e es = e (Html.concat_list es)

  let render_hole ~goal ~command_entry ~msg =
    let open Html in
    let rendered_msg =
      match msg with
      | None -> empty
      | Some msg -> div ~attrs:[ A.class_ "errormsg" ] (text msg)
    in
    match goal with
    | Calculus.Entailment goal ->
       FR.render_hole ~goal ~command_entry ~msg
    | Calculus.Program { precond; postcond } ->
       div ~attrs:[ A.class_ "hole" ]
         (vertical @| [
            comment (Pretty.(group (Calculus.pp_formula_or_meta precond)));
            command_entry;
            rendered_msg;
            comment (Pretty.(group (Calculus.pp_formula_or_meta postcond)))
          ])

  let render_rule ~resetbutton ~rule ~children:boxes =
    let open Html in
    match rule with
    | Calculus.Program_rule End ->
       (match boxes with
       | [] ->
          div (resetbutton ^^ code (text "end"))
       | [ proof ] ->
          vertical @| [
             div (resetbutton ^^ code (textf "end"));
             div (textf "Proof:");
             indent_box proof;
             div (textf "End proof");
           ]
       | _ ->
          text "SOMETHING WENT WRONG")
    | Calculus.Program_rule (Assign (var, expr)) ->
       vertical @| [
          div (resetbutton ^^ code (textf "%s := %s;" (Program_var.to_string var) (string_of_expr expr)));
          concat_list boxes
        ]
    | Calculus.Program_rule (Assert fmla) ->
       (match boxes with
       | [ proof; continuation ] ->
          (* FIXME: HTML rendering of formula? *)
          vertical @| [
             div (resetbutton ^^ code (textf "assert \"%s\";" (Formula.to_string fmla)));
             div (textf "Proof:");
             indent_box proof;
             div (textf "End proof");
             continuation
           ]
       | _ ->
          text "SOMETHING WENT WRONG")
    | Calculus.Program_rule (If bool_expr) ->
       (match boxes with
       | [ then_case; else_case; continuation ] ->
          vertical @| [
             div (resetbutton ^^ code (textf "if (%s) {" (string_of_boolean_expr bool_expr)));
             indent_box then_case;
             div (code (text "} else {"));
             indent_box else_case;
             div (code (text "}"));
             continuation
           ]
       | _ ->
          text "SOMETHING WENT WRONG")
    | Calculus.Program_rule (While bool_expr) ->
       (match boxes with
       | [ body; continuation ] ->
          vertical @| [
             div (resetbutton ^^ code (textf "while (%s) {" (string_of_boolean_expr bool_expr)));
             indent_box body;
             div (code (text "}"));
             continuation
           ]
       | _ ->
          text "SOMETHING WENT WRONG")
    | Calculus.Proof_rule rule ->
       FR.render_rule ~resetbutton ~rule ~children:boxes

  let render_assumption = function
    | nm, Calculus.Program_variable ->
       comment Pretty.(textf "{ ‘%s’ is a program variable }" nm)
    | nm, Calculus.Logic_variable ->
       FR.render_assumption (nm, Focused.A_Termvar)
    | nm, Calculus.Assumed_formula fmla ->
       FR.render_assumption (nm, Focused.A_Formula fmla)

  let prologue = function
    | Calculus.Program { precond; _ } ->
       comment Pretty.(group (nest 4 (text "{ requires" ^^ break ^^ Calculus.pp_formula_or_meta precond) ^^ break ^^ text "}"))
    | _ ->
       (* SHOULDN'T HAPPEN! *)
       Html.empty

  let epilogue = function
    | Calculus.Program { postcond; _ } ->
       comment Pretty.(group (nest 4 (text "{ ensures" ^^ break ^^ Calculus.pp_formula_or_meta postcond) ^^ break ^^ text "}"))
    | _ ->
       Html.empty

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
    | Calculus.Entailment goal ->
       Focused_ui2.string_of_goal goal

  let string_of_assumption nm = function
    | Calculus.Program_variable -> nm
    | Calculus.Logic_variable -> nm
    | Calculus.Assumed_formula f -> nm ^ " : " ^ Formula.to_string f

  let label_of_program_rule = function
    | Calculus.End -> "end"
    | Calculus.Assign (v, expr) ->
       Printf.sprintf "%s := %s" (Syntax.Program_var.to_string v) (Syntax.string_of_expr expr)
    | Calculus.Assert f ->
       Printf.sprintf "assert %s" (Formula.to_string f)
    | Calculus.If cond ->
       Printf.sprintf "if(%s)" (Syntax.string_of_boolean_expr cond)
    | Calculus.While cond ->
       Printf.sprintf "while(%s)" (Syntax.string_of_boolean_expr cond)

  let label_of_rule = function
    | Calculus.Program_rule rule ->
       label_of_program_rule rule
    | Calculus.Proof_rule rule ->
       Focused_ui2.label_of_rule rule

  let string_of_error e = e

  open Result_ext.Syntax

  (* FIXME: replace this with a nicer parser that matches the output format. *)
  let parse_rule str =  (* FIXME: allow the parser to depend on the goal? *)
    match Sexplib.Sexp.of_string str with
    | exception _ ->
       let* rule = Focused_ui2.parse_rule str in
       Ok (Calculus.Proof_rule rule)
    | Sexplib.Type.Atom "end" ->
       Ok (Calculus.Program_rule End)
    | Sexplib.Type.List [ Atom "if"; e ] ->
       (match Syntax.boolean_expr_of_sexp_human e with
       | None   -> Error "invalid boolean expression"
       | Some e -> Ok (Program_rule (If e)))
    | Sexplib.Type.List [ Atom "while"; e ] ->
       (match Syntax.boolean_expr_of_sexp_human e with
       | None   -> Error "invalid boolean expression"
       | Some e -> Ok (Program_rule (While e)))
    | Sexplib.Type.List [ Atom "assert"; Atom fmla ] ->
       (match Formula.of_string fmla with
       | Ok fmla -> Ok (Program_rule (Assert fmla))
       | Error _ -> Error "invalid formula")
    | Sexplib.Type.List [ Atom ":="; Atom v; e ] ->
       (match Syntax.Program_var.of_string v, Syntax.expr_of_sexp_human e with
       | None, _ | _, None ->
          Error "invalid assignment"
       | Some var, Some e ->
          Ok (Program_rule (Assign (var, e))))
    | Sexplib.Type.Atom _atm ->
       let* rule = Focused_ui2.parse_rule str in
       Ok (Calculus.Proof_rule rule)
    | _ ->
       Error "command not understood"

end

(* This is a generic UI for any 'vertical' proof format *)
module MakeUI
         (M : sig
            module Calculus : Proof_tree.CALCULUS
                   with type error = string

            module Renderer (Html : Html_sig.S) : sig
              val render_hole : goal:Calculus.goal -> command_entry:'a Html.t -> msg:string option -> 'a Html.t
              val render_rule : resetbutton:'a Html.t -> rule:Calculus.rule -> children:'a Html.t list -> 'a Html.t
              val render_assumption : string * Calculus.assumption -> 'a Html.t

              val prologue : Calculus.goal -> 'a Html.t
              val epilogue : Calculus.goal -> 'a Html.t
            end

            val parse_rule : string -> (Calculus.rule, string) result
          end)
         (Param : sig
            val assumptions : (string * M.Calculus.assumption) list
            val goal        : M.Calculus.goal
          end) :
sig
  type state

  type action

  val sexp_of_state : state -> Sexplib.Type.t
  val state_of_sexp : Sexplib.Type.t -> state option

  val initial : state
  val render : state -> action Ulmus.html
  val update : action -> state -> state
end = struct

  open M
  open Param

  module Hole = struct
    type goal = Calculus.goal

    type t =
      { command : string
      ; message : string option
      } [@@deriving sexp]

    let empty _ = { command = ""; message = None }
  end

  module PT = Proof_tree.Make (Calculus) (Hole)

  type state = PT.t

  let sexp_of_state state = PT.sexp_of_tree (PT.to_tree state)

  let state_of_sexp sexp =
    match PT.of_tree assumptions goal (PT.tree_of_sexp sexp) with
    | Ok state -> Some state
    | Error _ | exception _ -> None

  let initial =
    PT.init ~assumptions goal

  type action =
    | UpdateHole of PT.point * Hole.t
    | SendHole of PT.point * string
    | ResetTo of PT.point

  module H = Focused_proof_renderer.HTML_Bits (Ulmus.Html)
  open Renderer (Ulmus.Html)

  let resetbutton pt =
    let open Ulmus.Html in
    button
      ~attrs:[ E.onclick (ResetTo pt); A.class_ "resetbutton" ]
      (text "reset")

  let render_box assumps content position =
    let open Ulmus.Html in
    match assumps, position with
    | [], _ | _, `Top ->
       (* Do not render top-level assumptions *)
       content `Inner
    | assumps, _ ->
       H.vertical (concat_map render_assumption assumps ^^ content `Inner)

  let (@|) e es = e (Ulmus.Html.concat_list es)

  let render t =
    let goal = PT.root_goal t in
    let open Ulmus.Html in
    H.vertical @| [
        prologue goal;
        PT.fold
          (fun pt Hole.{ command; message } _ ->
            let command_entry =
              input
                ~attrs:[
                  A.class_ "commandinput";
                  A.value command;
                  A.placeholder "<command>";
                  E.oninput (fun command -> UpdateHole (pt, { command; message }));
                  E.onkeydown (fun _mods key ->
                      match key with
                      | Js_of_ocaml.Dom_html.Keyboard_code.Enter ->
                         Some (SendHole (pt, command))
                      | _ -> None);
                ]
            in
            render_hole ~goal:(PT.goal pt) ~command_entry ~msg:message)
          (fun pt rule children _ ->
            let children = List.map (fun c -> c `Inner) children in
            render_rule ~resetbutton:(resetbutton pt) ~rule ~children)
          render_box
          t
          `Top;
        epilogue goal
      ]

  let update action _prooftree =
    match action with
    | UpdateHole (pt, hole_data) ->
       PT.set_hole hole_data pt
    | SendHole (pt, command) ->
       (match parse_rule command with
       | Ok rule ->
          (match PT.apply rule pt with
          | Ok prooftree -> prooftree
          | Error (`RuleError msg) -> PT.set_hole { command; message = Some msg } pt)
       | Error msg ->
          PT.set_hole { command; message = Some msg } pt)
    | ResetTo pt ->
       (* let tree = PT.subtree_of_point pt in
          let command = string_of_tee tree in *)
       PT.set_hole { command = ""; message = None } pt

end

module Config_parser = struct
  open Generalities.Sexp_parser
  open Syntax
  open Fol_formula

  type config =
    { program_vars : Program_var.t list
    ; logic_vars   : string list
    ; assumptions  : (string * formula) list
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

    let assumption =
    sequence
      (let+ name       = consume_next atom
       and+ assumption = consume_next formula
       and+ ()         = assert_nothing_left in
       (name, assumption))

  let config_p =
    tagged "hoare"
      (let+ program_vars = consume_opt "program_vars" (many program_var_p)
       and+ logic_vars   = consume_opt "logic_vars" (many logic_var_p)
       and+ assumptions  = consume_opt "assumptions" (many assumption)
       and+ precond      = consume_one "precond" (one formula)
       and+ postcond     = consume_one "postcond" (one formula) in
       let program_vars = Option.value ~default:[] program_vars in
       let logic_vars   = Option.value ~default:[] logic_vars in
       let assumptions  = Option.value ~default:[] assumptions in
       (* FIXME: check that requires and ensures are well-scoped in
          the program and logic vars, and that all of the assumptions
          are closed. *)
       { program_vars; logic_vars; assumptions; precond; postcond })

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
  | Ok Config_parser.{ precond; postcond; assumptions; program_vars; logic_vars } ->
     let assumptions =
       List.map (fun nm -> Syntax.Program_var.to_string nm, Calculus.Program_variable) program_vars
       @ List.map (fun nm -> nm, Calculus.Logic_variable) logic_vars
       @ List.map (fun (nm, fmla) -> nm, Calculus.Assumed_formula fmla) assumptions
     and goal =
       Calculus.Program
         { precond = Formula precond
         ; postcond = Formula postcond
         }
     in
     let module Component = struct
         module M = struct
           module Calculus = Calculus
           module Renderer = Make_renderer
           let parse_rule = UI.parse_rule
         end
         include MakeUI (M) (struct let assumptions = assumptions let goal = goal end)

         let serialise t =
           Sexplib.Sexp.to_string (sexp_of_state t)
         let deserialise str =
           match state_of_sexp (Sexplib.Sexp.of_string str) with
           | None | exception _ -> None
           | Some t -> Some t
       end
     in
     (module Component : Ulmus.PERSISTENT)
