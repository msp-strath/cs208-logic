module Make
    (Html : Html_sig.S)
    (Proof : Proof_tree.PROOF_TREE) (Presentation : sig
      val string_of_sequent :
        (string * Proof.Calculus.assumption) list * Proof.Calculus.goal ->
        string

      val name_of_rule : Proof.Calculus.rule -> string
    end) : sig
  val render : Proof.t -> _ Html.t
end = struct
  open Html

  let proofbox elements = div ~attrs:[ A.class_ "proofbox" ] elements
  let premisebox elements = div ~attrs:[ A.class_ "premisebox" ] elements

  let formulabox sequent =
    div
      ~attrs:[ A.class_ "formulabox" ]
      (text (Presentation.string_of_sequent sequent))

  let render_hole point _focus _hole =
    let assumps = Proof.assumptions point in
    let formula = Proof.goal point in
    proofbox
      [%concat
        premisebox (text "???");
        formulabox (assumps, formula)]

  let render_box _assumptions rendered_subtree =
    (* Assumptions are draw in the sequents *)
    rendered_subtree

  let render_rule_application point rule rendered_premises =
    let name = Presentation.name_of_rule rule in
    proofbox
      [%concat
        premisebox
          [%concat
            concat_list rendered_premises;
            div ~attrs:[ A.class_ "rulename" ] (text name)];
        formulabox (Proof.assumptions point, Proof.goal point)]

  let render = Proof.fold render_hole render_rule_application render_box
end
