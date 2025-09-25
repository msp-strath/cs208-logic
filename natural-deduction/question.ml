open Focused_config

let focusing { name; assumptions; goal; solution } =
  let solution =
    match solution with
    | None -> None
    | Some sexp ->
       Focused_UI.state_of_sexp assumptions (Checking goal) sexp
  in
  let module Component =
    struct
      type state = {
          editor : Focused_UI.state;
          showtree : bool;
          showsolution : bool
        }

      type action =
        | ToggleShowtree
        | ToggleShowsolution
        | Edit of Focused_UI.action

      let initial =
        {
          editor = Focused_UI.init ~assumptions (Checking goal);
          showtree = false;
          showsolution = false
        }

      let render { editor; showtree; showsolution } =
        let open Ulmus.Html in
        let (@|) e es = e (concat_list es) in
        div ~attrs:[ A.class_ "vertical" ] @| [
            (match showsolution, solution with
             | true, Some solutiontree ->
                Focused_UI.render_solution ?name ~showtree solutiontree
             | _ ->
                map
                  (fun a -> Edit a)
                  (Focused_UI.render ?name ~showtree editor));
            div
              ~attrs:[ A.class_ "horizontal" ] @| [
                button ~attrs:[ E.onclick ToggleShowtree ]
                  (text (if showtree then "Hide proof tree" else "Show proof tree"));
                (match solution with
                 | None -> empty
                 | Some _ ->
                    concat_list [
                        text " ";
                        button ~attrs:[ E.onclick ToggleShowsolution ]
                          (text (if showsolution then "Hide solution" else "Show solution"))
                ])
              ]
          ]

      let update action ({ editor; showtree; showsolution } as state) =
        match action with
        | ToggleShowtree ->
           { state with showtree = not showtree }
        | ToggleShowsolution ->
           { state with showsolution = not showsolution }
        | Edit action ->
           { state with editor = Focused_UI.update action editor }

      let serialise { editor; _ } =
        Sexplib.Sexp.to_string (Focused_UI.sexp_of_state editor)

      let deserialise str =
        let sexp = Sexplib.Sexp.of_string str in
        match Focused_UI.state_of_sexp assumptions (Checking goal) sexp with
        | None -> None
        | Some editor ->
           Some { editor; showtree = false; showsolution = false }
    end in
  (module Component : Ulmus.PERSISTENT)

let focusing_component config =
  match Focused_config.config_p (Sexplib.Sexp.of_string config) with
  | Ok config ->
     focusing config
  | Error err ->
     let detail = Generalities.Annotated.detail err in
     let message = "Configuration failure: " ^ detail in
     Widgets.Error_display.component message

let tree_component config =
  match Focused_config.config_p (Sexplib.Sexp.of_string config) with
  | Ok config ->
     (* FIXME: assumptions? *)
     (module Proof_tree_UI2.Make_no_box
               (Focused_ui2)
               (struct let assumptions = config.assumptions
                       let goal = Focused.Checking config.goal end)
             : Ulmus.PERSISTENT)
  | Error err ->
     let detail = Generalities.Annotated.detail err in
     let message = "Configuration failure: " ^ detail in
     Widgets.Error_display.component message
