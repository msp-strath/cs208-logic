open Generalities

module Make (Html : Html_sig.S) = struct
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
          (* FIXME: hiding proofs? *)
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
