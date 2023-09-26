module type S = sig
  include Ulmus.S

  val initial : state
end

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
  (module Component : S)

let focusing ?name ?assumps_name ?(assumptions = []) formula =
  let assumptions =
    List.map
      (function
        | x, `V -> (x, Focused.A_Termvar) | x, `F f -> (x, Focused.A_Formula f))
      assumptions
  in
  let module Component = struct
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
  (module Component : S)
