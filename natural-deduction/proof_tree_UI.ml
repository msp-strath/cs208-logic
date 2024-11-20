open Sexplib0.Sexp_conv

module type PARTIALS = sig
  module Calculus : Proof_tree.CALCULUS

  val name_of_rule : Calculus.rule -> string
  val left_label_of_rule : Calculus.rule -> string option

  type partial [@@deriving sexp]

  val name_of_partial : partial -> string

  (* Rule selection *)
  type rule_selector =
    | Immediate of Calculus.rule
    | Disabled of string
    | Partial of partial

  type selector_group = { group_name : string; rules : rule_selector list }

  val rule_selection :
    (string * Calculus.assumption) list -> Calculus.goal -> selector_group list

  val elim_assumption :
    conclusion:Calculus.goal ->
    assumption:Calculus.assumption ->
    idx:int ->
    (string * [ `ByAssumption | `Rule of Calculus.rule | `Partial of partial ])
    list

  module Part_type : sig
    type t

    val placeholder : t -> string
    val class_ : t -> string
  end

  (* Partial proof presentation *)
  type partial_formula_part =
    | T of string
    | I of { value : string; typ : Part_type.t; update : string -> partial }
    | F of Calculus.goal

  type partial_premise = {
    premise_formula : partial_formula_part list;
    premise_assumption : string option;
  }

  type partial_presentation = {
    premises : partial_premise list;
    apply : Calculus.rule option;
  }

  val present_partial : Calculus.goal -> partial -> partial_presentation
end

module type FORMULA = sig
  type t

  val to_string : t -> string
end

module Make
    (Goal : FORMULA)
    (Assumption : FORMULA) (Calculus : sig
      include
        Proof_tree.CALCULUS
          with type goal = Goal.t
           and type assumption = Assumption.t
           and type error = [ `Msg of string ]
    end)
    (P : PARTIALS with module Calculus = Calculus) =
struct
  module Hole = struct
    type goal = Goal.t
    type t = P.partial option [@@deriving sexp]

    let empty _ = None
  end

  module PT = Proof_tree.Make (Calculus) (Hole)

  type state = PT.t

  let sexp_of_state state = PT.sexp_of_tree (PT.to_tree state)

  let state_of_sexp goal sexp =
    match PT.of_tree [] goal (PT.tree_of_sexp sexp) with
    | Ok state -> state
    | Error _ -> failwith "invalid tree"

  type action =
    | ApplyRule of PT.point * Calculus.rule
    | Update of PT.point * P.partial
    | ResetTo of PT.point
    | DoNothing

  open Ulmus.Html

  let rule_selector assumps point formula =
    let open Drop_down in
    let options =
      P.rule_selection assumps formula
      |> List.map (fun { P.group_name; P.rules } ->
             group ~label:group_name
               (rules
               |> List.map (function
                    | P.Immediate rule ->
                        option
                          ~action:(ApplyRule (point, rule))
                          (text (P.name_of_rule rule))
                    | P.Disabled name ->
                        option ~enabled:false ~action:DoNothing (text name)
                    | P.Partial partial ->
                        option
                          ~action:(Update (point, partial))
                          (text (P.name_of_partial partial)))))
    in
    Drop_down.make
      ~attrs:[ A.title "Select a rule to apply"; A.class_ "ruleselector" ]
      (option ~action:DoNothing ~selected:true ~enabled:false ~hidden:true
         (text "Select rule...")
      :: options)

  let proofbox elements = div ~attrs:[ A.class_ "proofbox" ] elements
  let premisebox elements = div ~attrs:[ A.class_ "premisebox" ] elements

  let formulabox point formula =
    div
      ~attrs:
        [
          A.class_ "formulabox";
          E.onclick (ResetTo point);
          A.title "Click to reset proof to this formula";
        ]
      (text (Goal.to_string formula))

  let formulabox_inactive content = div ~attrs:[ A.class_ "formulabox" ] content

  let disabled_rule_button label =
    button ~attrs:[ A.disabled true ] (text ("apply " ^ label))

  let enabled_rule_button label path rule =
    button
      ~attrs:[ E.onclick (ApplyRule (path, rule)) ]
      (text ("apply " ^ label))

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
          E.oninput (fun value -> Update (point, update value));
        ]

  let render_partial_formula point parts =
    formulabox_inactive
      (parts
      |> concat_map (function
           | P.T str -> text str
           | P.I { value; typ; update } -> formula_input point value typ update
           | P.F formula -> text (Goal.to_string formula)))

  let render_partial point = function
    | None ->
        let assumptions = PT.assumptions point and formula = PT.goal point in
        proofbox
          [%concat
            premisebox (rule_selector assumptions point formula);
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

  let render_box assumptions rendered_subtree =
    match assumptions with
    | [] -> rendered_subtree
    | assumptions ->
        let assumptions =
          concat_map
            (fun (_, f) -> text (Assumption.to_string f ^ ", "))
            assumptions
        in
        assumption_box ~assumptions rendered_subtree

  let render prooftree =
    PT.fold render_partial render_rule_application render_box prooftree

  let initial formula = PT.init formula

  let update action prooftree =
    match action with
    | DoNothing -> prooftree
    | ApplyRule (path, rule) -> (
        match PT.apply rule path with
        | Ok prooftree -> prooftree (* FIXME: clear the error state *)
        | Error (`RuleError (`Msg _msg)) ->
            (* FIXME: use the message *)
            prooftree)
    | ResetTo path -> PT.set_hole None path
    | Update (path, partial) -> PT.set_hole (Some partial) path
end
