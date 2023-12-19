module type UI_SPEC = sig
  module Calculus : Proof_tree.CALCULUS

  val string_of_goal : Calculus.goal -> string

  val string_of_assumption : string -> Calculus.assumption -> string

  val string_of_error : Calculus.error -> string

  val label_of_rule : Calculus.rule -> string

  val parse_rule : string -> (Calculus.rule, string) result
end

open Sexplib0.Sexp_conv

module Make
         (Spec : UI_SPEC)
         (Goal : sig val goal : Spec.Calculus.goal end)
       : Ulmus.PERSISTENT
  = struct

  open Spec

  module Hole = struct
    type goal = Calculus.goal
    type t =
      { user_input : string;
        message    : string option
      } [@@deriving sexp]

    let void =
      { user_input = ""; message = None }

    let empty _ = void
  end

  module PT = Proof_tree.Make (Calculus) (Hole)

  type state = PT.t

  let serialise tree =
    Sexplib.Sexp.to_string (PT.sexp_of_tree (PT.to_tree tree))

  let deserialise string =
    let sexp = Sexplib.Sexp.of_string string in
    match PT.of_tree [] Goal.goal (PT.tree_of_sexp sexp) with
    | Ok state -> Some state
    | Error _ -> None

  type action =
    | Update of PT.point * string
    | ResetTo of PT.point
    | SendRule of PT.point * string

  open Ulmus.Html

  let proofbox elements =
    div ~attrs:[ A.class_ "proofbox" ] elements

  let premisebox elements =
    div ~attrs:[ A.class_ "premisebox" ] elements

  let formulabox point formula =
    div
      ~attrs:
      [
        A.class_ "formulabox";
        E.onclick (ResetTo point);
        A.title "Click to reset proof to this formula";
      ]
      (text (string_of_goal formula))

  let formulabox_inactive content =
    div ~attrs:[ A.class_ "formulabox" ] content

  let assumption_box ~assumptions content =
    div ~attrs:[ A.class_ "assumptionbox" ]
      begin%concat
        div ~attrs:[ A.class_ "assumption" ]
          [%concat text "with "; assumptions];
        content
      end

  let render_rule_application point rule rendered_premises =
    let name = label_of_rule rule in
    proofbox
      [%concat
        premisebox
          [%concat
            concat_list rendered_premises;
            div ~attrs:[ A.class_ "rulename" ] (text name)];
        formulabox point (PT.goal point)]

  let render_box assumptions rendered_subtree =
    match assumptions with
    | [] -> rendered_subtree
    | assumptions ->
        let assumptions =
          concat_map
            (fun (name, f) -> text (string_of_assumption name f ^ ", "))
            assumptions
        in
        assumption_box ~assumptions rendered_subtree

  let render_hole point Hole.{ user_input; message } =
    let conclusion = PT.goal point in
    proofbox
      (premisebox
         (input
            ~attrs:[
              A.class_ "proofcommand";
              A.value user_input;
              A.placeholder "<command>";
              E.oninput (fun value -> Update (point, value));
              E.onkeydown (fun _mods key ->
                  match key with
                  | Js_of_ocaml.Dom_html.Keyboard_code.Enter ->
                     Some (SendRule (point, user_input))
                  | _ ->
                     None)
         ] ^^ (match message with
               | Some msg -> p (text msg)
               | None -> empty))
       ^^
         formulabox point conclusion)

  let render prooftree : action Ulmus.html =
    div ~attrs:[ A.class_ "worksheet" ]
      (PT.fold render_hole render_rule_application render_box prooftree)

  let update action prooftree =
    match action with
    | ResetTo point ->
       PT.set_hole Hole.void point
    | Update (point, user_input) ->
       (* FIXME: on-the-fly checking? *)
       PT.set_hole { user_input; message = None } point
    | SendRule (point, user_input) ->
       (* FIXME: combine parsing and checking *)
       (match parse_rule user_input with
        | Ok rule ->
           (match PT.apply rule point with
            | Ok prooftree -> prooftree
            | Error (`RuleError err) ->
               let message = Some (string_of_error err) in
               PT.set_hole { user_input; message } point)
        | Error msg ->
           PT.set_hole { user_input; message = Some msg} point)

  let initial =
    PT.init Goal.goal
end
