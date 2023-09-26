module Make
    (Html : Html_sig.S)
    (Goal : Proof_tree_UI.FORMULA)
    (Assumption : Proof_tree_UI.FORMULA)
    (P : Proof_tree_UI.PARTIALS
           with type Calculus.goal = Goal.t
            and type Calculus.assumption = Assumption.t)
    (PT : Proof_tree.PROOF_TREE
            with module Calculus = P.Calculus
             and type Hole.t = P.partial option) =
struct
  open Html

  let rule_selector assumps point formula = text "???"
  (*let open Ulmus.DropDown in
    let options =
      P.rule_selection assumps formula |> List.map
        (fun {P.group_name; P.rules} ->
           group ~label:group_name
             (rules |> List.map
                (function
                  | P.Immediate rule ->
                     option ~action:(ApplyRule (point, rule))
                       (text (P.name_of_rule rule))
                  | P.Disabled name ->
                     option ~enabled:false ~action:DoNothing
                       (text name)
                  | P.Partial partial ->
                     option ~action:(Update (point, partial))
                       (text (P.name_of_partial partial)))))
    in
    Ulmus.DropDown.make
      ~attrs:[ A.title "Select a rule to apply"
             ; A.class_ "ruleselector"
             ]
      (  option ~action:DoNothing ~selected:true ~enabled:false ~hidden:true
           (text "Select rule...")
      ::options)*)

  let render_active_assumption assumption idx point =
    text (Assumption.to_string assumption ^ ", ")
  (*
    let conclusion = PT.formula point in
    let open Ulmus.DropDown in
    let options =
      P.elim_assumption ~conclusion ~assumption ~idx |>
      List.map begin function
        | label, `ByAssumption ->
           option ~action:(ApplyAssumption (point, idx)) (text label)
        | label, `Rule rule ->
           option ~action:(ApplyRule (point, rule)) (text label)
        | label, `Partial partial ->
           option ~action:(Update (point, partial)) (text label)
      end
    in
    match options with
      | [] ->
         text (Assumption.to_string assumption)
      | options ->
         make
           ~attrs:[ A.title ("Options for " ^ Assumption.to_string assumption) ]
           (option ~action:DoNothing ~selected:true ~enabled:false ~hidden:true
              (text (Assumption.to_string assumption))
            ::options)
    *)

  let proofbox elements = div ~attrs:[ A.class_ "proofbox" ] elements
  let premisebox elements = div ~attrs:[ A.class_ "premisebox" ] elements

  let formulabox point formula =
    div
      ~attrs:
        [
          A.class_ "formulabox" (* ; E.onclick (ResetTo point) *);
          A.title "Click to reset proof to this formula";
        ]
      (text (Goal.to_string formula))

  let formulabox_inactive content = div ~attrs:[ A.class_ "formulabox" ] content

  let disabled_rule_button label =
    button ~attrs:[ A.disabled true ] (text ("apply " ^ label))

  let enabled_rule_button label path rule = disabled_rule_button label
  (* button ~attrs:[E.onclick (ApplyRule (path, rule))]
     (text ("apply " ^ label))*)

  let assumption_box ~assumptions content =
    div
      ~attrs:[ A.class_ "assumptionbox" ]
      [%concat
        div
          ~attrs:[ A.class_ "assumption" ]
          [%concat
            text "with ";
            assumptions];
        content]

  let formula_input point value typ update =
    input
      ~attrs:
        [
          A.class_ (P.Part_type.class_ typ);
          A.value value;
          A.placeholder (P.Part_type.placeholder typ);
          A.disabled true
          (* ; E.oninput (fun value -> Update (point, update value)) *);
        ]

  let render_partial_formula point parts =
    formulabox_inactive
      (parts
      |> concat_map (function
           | P.T str -> text str
           | P.I { value; typ; update } -> formula_input point value typ update
           | P.F formula -> text (Goal.to_string formula)))

  let render_partial point focus = function
    | None when focus ->
        let assumptions = PT.assumptions point and formula = PT.goal point in
        proofbox
          [%concat
            premisebox (rule_selector assumptions point formula);
            formulabox point formula]
    | None ->
        let formula = PT.goal point in
        proofbox
          [%concat
            premisebox
              ((*button ~attrs:[ E.onclick (Focus point)
                             ; A.class_ "unfocusedgoal"]
                 (text "click to focus")*)
               text "???");
            formulabox point formula]
    | Some partial ->
        let name = P.name_of_partial partial in
        let conclusion = PT.goal point in
        let { P.premises; P.apply } = P.present_partial conclusion partial in
        proofbox
          [%concat
            premisebox
              [%concat
                premises
                |> concat_map
                     (fun { P.premise_formula; P.premise_assumption } ->
                       match premise_assumption with
                       | None ->
                           proofbox
                             (render_partial_formula point premise_formula)
                       | Some assump ->
                           assumption_box
                             ~assumptions:
                               (text
                                  (if assump = "" then "<assump>" else assump))
                             (proofbox
                                (render_partial_formula point premise_formula)));
                match apply with
                | None -> disabled_rule_button name
                | Some rule -> enabled_rule_button name point rule];
            formulabox point conclusion]

  let render_rule_application point rule rendered_premises =
    let name = P.name_of_rule rule in
    proofbox
      [%concat
        premisebox
          [%concat
            (match P.left_label_of_rule rule with
            | None -> empty
            | Some label -> div ~attrs:[ A.class_ "leftrulelabel" ] (text label));
            concat_list rendered_premises;
            div ~attrs:[ A.class_ "rulename" ] (text name)];
        formulabox point (PT.goal point)]

  let render_leaf point =
    proofbox
      [%concat
        premisebox
          [%concat div ~attrs:[ A.class_ "rulename" ] (text "assumption")];
        formulabox point (PT.goal point)]

  let render_box assumptions rendered_subtree =
    match assumptions with
    | [] -> rendered_subtree
    | assumptions ->
        let assumptions =
          concat_map
            (function
              | (_, f), None -> text (Assumption.to_string f ^ ", ")
              | (_, f), Some (idx, point) ->
                  render_active_assumption f idx point ^^ text ", ")
            assumptions
        in
        assumption_box ~assumptions rendered_subtree

  let render prooftree =
    PT.fold render_partial (*       render_leaf *)
      render_rule_application render_box prooftree
end
