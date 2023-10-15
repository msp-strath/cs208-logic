(*
(* FIXME: make a general one for any Proof_tree_UI based instance *)
let opsem formula =
  let module Component = struct
    module OpSem = Operational_semantics

    module PTU =
      Proof_tree_UI.Make (OpSem.Calculus.Goal) (OpSem.Calculus.Assumption)
        (OpSem.Calculus)
        (OpSem.Partials)

    type state = PTU.state

    let state_of_sexp sexp = PTU.state_of_sexp formula sexp
    let sexp_of_state = PTU.sexp_of_state

    type action = PTU.action

    let initial = PTU.initial formula

    let render tree =
      let open Ulmus.Html in
      div
        ~attrs:[ A.style "display: flex; justify-content: center" ]
        (PTU.render tree)

    let update = PTU.update
  end in
  (module Component : Ulmus.COMPONENT)
 *)

let focusing ?name ?assumps_name ?(assumptions = []) formula =
  let assumptions =
    List.map
      (function
        | x, `V -> (x, Focused.A_Termvar) | x, `F f -> (x, Focused.A_Formula f))
      assumptions
  in
  let module Component =
    struct
      type state = { editor : Focused_UI.state; showtree : bool }
      type action = ToggleShowtree | Edit of Focused_UI.action

      let initial =
        {
          editor = Focused_UI.init ~assumptions (Checking formula);
          showtree = false;
        }

      let render { editor; showtree } =
        let open Ulmus.Html in
        div
          ~attrs:[ A.class_ "vertical" ]
          [%concat
              div
              ~attrs:[ A.class_ "horizontal" ]
              [%concat
                  button
                  ~attrs:[ E.onclick ToggleShowtree ]
                  (text "Show / Hide proof tree")];
           map
             (fun a -> Edit a)
             (Focused_UI.render ?name ?assumps_name ~showtree editor)]

      let update action ({ editor; showtree } as state) =
        match action with
        | ToggleShowtree -> { state with showtree = not showtree }
        | Edit action -> { state with editor = Focused_UI.update action editor }

      let sexp_of_state { editor; _ } = Focused_UI.sexp_of_state editor

      let state_of_sexp sexp =
        {
          editor = Focused_UI.state_of_sexp assumptions (Checking formula) sexp;
          showtree = false;
        }
    end in
  (module Component : Ulmus.COMPONENT)

let config_p =
  let open Generalities.Sexp_parser in
  let formula =
    let+? str = atom in
    Result.map_error
      (function `Parse e -> Parser_util.Driver.string_of_error e)
      (Fol_formula.Formula.of_string str)
  in
  let assumption_p =
    list
      (let* name       = consume_next atom in
       let* assumption = consume_next formula in
       let* ()         = assert_nothing_left in
       return (name, `F assumption))
  in

  tagged "config"
    (let* assumptions = consume_opt "assumptions" (many assumption_p) in
     let* goal        = consume_one "goal" (one formula) in
     let  assumptions = Option.value ~default:[] assumptions in
     return (assumptions, goal))

let focusing_component config =
  match config_p (Sexplib.Sexp.of_string config) with
  | Ok (assumptions, goal) ->
     focusing ~assumptions goal
  | Error err ->
     let detail = Generalities.Annotated.detail err in
     let message = "Configuration failure: " ^ detail in
     Widgets.Error_display.component message

let tree_component config =
  match config_p (Sexplib.Sexp.of_string config) with
  | Ok (_assumptions, goal) ->
     (module Proof_tree_UI2.Make
               (Focused_ui2)
               (struct let goal = Focused.Checking goal end)
             : Ulmus.COMPONENT)
  | Error err ->
     let detail = Generalities.Annotated.detail err in
     let message = "Configuration failure: " ^ detail in
     Widgets.Error_display.component message
