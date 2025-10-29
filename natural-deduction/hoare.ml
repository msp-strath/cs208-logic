open Generalities
open Sexplib0.Sexp_conv

module Make_renderer (Html : Html_sig.S) = struct
  open Focused_proof_renderer.HTML_Bits (Html)
  open Fol_formula
  open Hoare_calculus

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
    | Entailment goal ->
       FR.render_hole ~goal ~command_entry ~msg
    | Program { precond; postcond } ->
       div ~attrs:[ A.class_ "hole" ]
         (vertical @| [
            comment (Pretty.(group (pp_formula_or_meta precond)));
            command_entry;
            rendered_msg;
            comment (Pretty.(group (pp_formula_or_meta postcond)))
          ])

  let render_rule ~resetbutton ~rule ~children:boxes =
    let open Html in
    match rule with
    | Program_rule End ->
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
    | Program_rule (Assign (var, expr)) ->
       vertical @| [
          div (resetbutton ^^ code (textf "%s := %s" var (Term.to_string expr)));
          concat_list boxes
        ]
    | Program_rule (Assert fmla) ->
       (match boxes with
       | [ proof; continuation ] ->
          (* FIXME: HTML rendering of formula?

             FIXME: hiding proofs?
           *)
          vertical @| [
             div (resetbutton ^^ code (textf "assert (%s)" (Formula.to_string fmla)));
             div (textf "Proof:");
             indent_box proof;
             div (textf "End proof");
             continuation
           ]
       | _ ->
          text "SOMETHING WENT WRONG")
    | Program_rule (If bool_expr) ->
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
    | Program_rule (While bool_expr) ->
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
    | Proof_rule rule ->
       FR.render_rule ~resetbutton ~rule ~children:boxes

  let render_assumption = function
    | nm, Program_variable ->
       comment Pretty.(textf "{ ‘%s’ is a program variable }" nm)
    | nm, Logic_variable ->
       FR.render_assumption (nm, Focused.A_Termvar)
    | nm, Assumed_formula fmla ->
       FR.render_assumption (nm, Focused.A_Formula fmla)

  let prologue assumptions = function
    | Program { precond; _ } ->
       let logic_vars = List.rev @@ List.filter_map (function (nm, Logic_variable) -> Some nm | _ -> None) assumptions in
       let prog_vars = List.rev @@ List.filter_map (function (nm, Program_variable) -> Some nm | _ -> None) assumptions in
       let assumps = List.rev @@ List.filter_map (function (nm, Assumed_formula f) -> Some (nm, f) | _ -> None) assumptions in
       let open Html in
       vertical @| [
           (match logic_vars with
           | [] -> empty
           | _ -> div (strong (text "for all ") ^^ text (String.concat ", " logic_vars)));
           (match assumps with
           | [] -> empty
           | _ ->
              div (strong (text "assuming")) ^^
                indent_box (vertical (concat_map (fun (nm, f) -> div (text nm ^^ text " : " ^^ text (Formula.to_string f))) assumps)));
           div (strong (text "var ") ^^ code (text (String.concat ", " prog_vars)));
           div (strong (text "precondition ")
                ^^ text (Pretty.to_string ~width: 100 (pp_formula_or_meta precond)))
         ]
    | _ ->
       (* SHOULDN'T HAPPEN! *)
       Html.empty

  let epilogue = function
    | Program { postcond; _ } ->
       let open Html in
       vertical @| [
          div (strong (text "postcondition ")
               ^^ text (Pretty.to_string ~width: 100 (pp_formula_or_meta postcond)))

        ]
    | _ ->
       Html.empty

end

module UI (* : Proof_tree_UI2.UI_SPEC with module Calculus = Calculus *) = struct

  open Hoare_calculus

  (*
  open Fol_formula

  module Calculus = Hoare_calculus

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
       Printf.sprintf "%s := %s" v (Term.to_string expr)
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
   *)
  open Result_ext.Syntax

  (* FIXME: replace this with a nicer parser that matches the output format. *)
  let parse_rule goal str =
    match goal with
    | Entailment _ ->
       let+ rule = Focused_ui2.parse_rule str in
       Proof_rule rule
    | Program _ ->
       let lexbuf = Lexing.from_string str in
       try
         Ok (Program_rule
               (Hoare_parser.whole_command Hoare_lexer.token lexbuf))
       with _ ->
         Error "command not understood"

    (* FIXME: allow the parser to depend on the goal? *)
    (* match Sexplib.Sexp.of_string str with
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
    | _ -> *)
             (*        Error ("command not understood: " ^ str) *)

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

              val prologue : (string * Calculus.assumption) list -> Calculus.goal -> 'a Html.t
              val epilogue : Calculus.goal -> 'a Html.t
            end

            val parse_rule : Calculus.goal -> string -> (Calculus.rule, string) result
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
    let assumptions = PT.root_assumptions t in
    let goal = PT.root_goal t in
    let open Ulmus.Html in
    H.vertical @| [
        prologue assumptions goal;
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
       (match parse_rule (PT.goal pt) command with
       | Ok rule ->
          (match PT.apply rule pt with
          | Ok prooftree -> prooftree
          | Error (`RuleError msg) -> PT.set_hole { command; message = Some msg } pt)
       | Error msg ->
          PT.set_hole { command; message = Some msg } pt)
    | ResetTo pt ->
       (* let tree = PT.subtree_of_point pt in
          let command = string_of_tree tree in *)
       PT.set_hole { command = ""; message = None } pt

end

module Config_parser = struct
  open Generalities.Sexp_parser
  open Fol_formula

  type config =
    { program_vars : string list
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
    (* FIXME: check captialisation *)
    Ok str

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
          are well scoped and do not contain program_vars. *)
       { program_vars; logic_vars; assumptions; precond; postcond })

end

open Hoare_calculus

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
       List.map (fun nm -> nm, Program_variable) program_vars
       @ List.map (fun nm -> nm, Logic_variable) logic_vars
       @ List.map (fun (nm, fmla) -> nm, Assumed_formula fmla) assumptions
     and goal =
       Program
         { precond = Formula precond
         ; postcond = Formula postcond
         }
     in
     let module Component = struct
         module M = struct
           module Calculus = Hoare_calculus
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
