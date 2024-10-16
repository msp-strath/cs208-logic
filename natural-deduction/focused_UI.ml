open Sexplib0.Sexp_conv

module Hole = struct
  type goal = Focused.goal
  type t = string * string option [@@deriving sexp]

  let empty _ = ("", None)
end

module PT = Proof_tree.Make (Focused) (Hole)

type state = PT.t

let sexp_of_state state = PT.sexp_of_tree (PT.to_tree state)

let state_of_sexp assumptions goal sexp =
  match PT.of_tree assumptions goal (PT.tree_of_sexp sexp) with
  | Ok state -> Some state
  | Error _ -> None

let init ?assumptions goal = PT.init ?assumptions goal

type action =
  | UpdateHole of PT.point * Hole.t
  | SendHole of PT.point * string
  | ResetTo of PT.point

module SequentTreeRenderer =
  Proof_tree_sequents.Make (Ulmus.Html) (PT)
    (struct
      let string_of_sequent = Focused_proof_renderer.string_of_sequent
      let name_of_rule = Focused.Rule.name
    end)

module H = Focused_proof_renderer.HTML_Bits (Ulmus.Html)

module Renderer = struct
  open Focused_proof_renderer.HTML_Bits (Ulmus.Html)
  include Focused_proof_renderer.Make (Ulmus.Html)

  let resetbutton pt =
    let open Ulmus.Html in
    button
      ~attrs:[ E.onclick (ResetTo pt); A.class_ "resetbutton" ]
      (text "reset")

  let render_box assumps content =
    let open Ulmus.Html in
    match assumps with
    | [] ->
       content
    | assumps ->
       vertical (concat_map render_assumption assumps ^^ content)

  let render =
    PT.fold
      (fun pt (content, msg) ->
        let open Ulmus.Html in
        let command_entry =
          input
            ~attrs:[
              A.class_ "commandinput";
              A.value content;
              A.placeholder "<command>";
              E.oninput (fun value -> UpdateHole (pt, (value, msg)));
              E.onkeydown (fun mods key ->
                  match key with
                  | Js_of_ocaml.Dom_html.Keyboard_code.Enter ->
                     Some (SendHole (pt, content))
                  | _ -> None);
            ]
        in
        render_hole ~goal:(PT.goal pt) ~command_entry ~msg)
      (fun pt rule children ->
        render_rule ~resetbutton:(resetbutton pt) ~rule ~children)
      render_box

  let render_solution =
    PT.fold
      (fun _ _ -> Ulmus.Html.empty)
      (fun _pt rule children ->
        render_rule ~resetbutton:Ulmus.Html.empty ~rule ~children)
      render_box
end

let num_holes prooftree =
  PT.fold
    (fun _ _ -> 1)
    (fun _ _ l -> List.fold_left ( + ) 0 l)
    (fun _ x -> x)
    prooftree

let (@|) e es = Ulmus.Html.(e (concat_list es))

let render_heading name assumps goal =
  let open Ulmus.Html in
  div @| [
      (match name with
       | None ->
          strong (text "Theorem: ")
       | Some name ->
          concat_list
            [
              strong (text "Theorem ");
              text name;
              strong (text " : ")
            ]
      );
      (match assumps with
       | Either.Left formulas ->
          text (Focused_proof_renderer.string_of_sequent (formulas, goal))
       | Right name ->
          let open Fol_formula in
          text
            (match goal with
             | Checking goal -> name ^ " ⊢ " ^ Formula.to_string goal
             | Synthesis (focus, goal) ->
                name ^ " [" ^ Formula.to_string focus ^ "] ⊢ "
                ^ Formula.to_string goal))
    ]

let render renderer ~showtree ?name ?assumps_name prooftree =
  let open Ulmus.Html in
  let open H in
  let assumps = match assumps_name with
    | None -> Either.Left (PT.root_assumptions prooftree)
    | Some name -> Either.Right name
  in
  let goal = PT.root_goal prooftree in
  vertical @| [
      render_heading name assumps goal;

      div (strong (text "Proof"));
      indent_box (renderer prooftree);
      (match num_holes prooftree with
       | 0 -> div (strong (text "Proof Complete."))
       | 1 -> div (em (strong (textf "Proof incomplete (1 subgoal open).")))
       | n -> div (em (strong (textf "Proof incomplete (%d subgoals open)." n))));

      if showtree then
        concat_list [
            text "Proof tree:";
            div
              ~attrs:[ A.style "display: flex; overflow-x: auto" ]
              (SequentTreeRenderer.render prooftree)
          ]
      else empty;
    ]

let render_solution ~showtree =
  render Renderer.render_solution ~showtree

let render ~showtree =
  render Renderer.render ~showtree

let update action _prooftree =
  match action with
  | UpdateHole (pt, hole_data) ->
     PT.set_hole hole_data pt
  | SendHole (pt, command) ->
     (match Focused_command.of_string command with
      | Ok rule ->
         (match PT.apply rule pt with
          | Ok prooftree -> prooftree
          | Error (`RuleError msg) -> PT.set_hole (command, Some msg) pt)
      | Error msg ->
         PT.set_hole (command, Some msg) pt)
  | ResetTo pt ->
      (* let tree = PT.subtree_of_point pt in *)
      PT.set_hole ("" (*string_of_tree tree*), None) pt
