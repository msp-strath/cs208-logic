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
        let (@|) e es = e (concat_list es) in
        div ~attrs:[ A.class_ "vertical" ] @| [
            map
              (fun a -> Edit a)
              (Focused_UI.render ?name ?assumps_name ~showtree editor);
            div
              ~attrs:[ A.class_ "horizontal" ] @| [
              button ~attrs:[ E.onclick ToggleShowtree ]
                (text (if showtree then "Hide proof tree" else "Show proof tree"))
            ]
          ]

      let update action ({ editor; showtree } as state) =
        match action with
        | ToggleShowtree -> { state with showtree = not showtree }
        | Edit action -> { state with editor = Focused_UI.update action editor }

      let serialise { editor; _ } =
        Sexplib.Sexp.to_string (Focused_UI.sexp_of_state editor)

      let deserialise str =
        let sexp = Sexplib.Sexp.of_string str in
        match Focused_UI.state_of_sexp assumptions (Checking formula) sexp with
        | None -> None
        | Some editor ->
           Some { editor; showtree = false }
    end in
  (module Component : Ulmus.PERSISTENT)

let config_p =
  let open Generalities.Sexp_parser in
  let formula =
    let+? str = atom in
    Result.map_error
      (function `Parse e -> Parser_util.Driver.string_of_error e)
      (Fol_formula.Formula.of_string str)
  in
  let assumption_p =
    sequence
      (let* name       = consume_next atom in
       let* assumption = consume_next formula in
       let* ()         = assert_nothing_left in
       return (name, `F assumption))
  in

  tagged "config"
    (let* assumptions = consume_opt "assumptions" (many assumption_p) in
     let* assumps_nm  = consume_opt "assumptions-name" (one atom) in
     let* goal        = consume_one "goal" (one formula) in
     let  assumptions = Option.value ~default:[] assumptions in
     return (assumptions, assumps_nm, goal))

let focusing_component config =
  match config_p (Sexplib.Sexp.of_string config) with
  | Ok (assumptions, assumps_name, goal) ->
     focusing ~assumptions ?assumps_name goal
  | Error err ->
     let detail = Generalities.Annotated.detail err in
     let message = "Configuration failure: " ^ detail in
     Widgets.Error_display.component message

let tree_component config =
  match config_p (Sexplib.Sexp.of_string config) with
  | Ok (_assumptions, _, goal) ->
     (* FIXME: assumptions? *)
     (module Proof_tree_UI2.Make
               (Focused_ui2)
               (struct let goal = Focused.Checking goal end)
             : Ulmus.PERSISTENT)
  | Error err ->
     let detail = Generalities.Annotated.detail err in
     let message = "Configuration failure: " ^ detail in
     Widgets.Error_display.component message
