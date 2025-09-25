open Generalities

let string_of_sequent (assumptions, goal) =
  let open Focused in
  let open Fol_formula in
  let assumptions =
    assumptions |> List.rev
    |> List.map (function
         | _nm, A_Formula assump -> Formula.to_string assump
         | nm,  A_Termvar -> nm)
    |> String.concat ", "
  in
  match goal with
  | Checking goal -> assumptions ^ " ⊢ " ^ Formula.to_string goal
  | Synthesis (focus, goal) ->
      assumptions ^ " [" ^ Formula.to_string focus ^ "] ⊢ "
      ^ Formula.to_string goal

let pretty_of_sequent (assumptions, goal) =
  let open Focused in
  let open Fol_formula in
  let open Pretty in
  let assumptions =
    assumptions
    |> List.rev
    |> List.to_seq
    |> Seq.map (function
           | (nm, A_Formula assump) ->
              text nm ^^ text " :" ^^ nest 4 (group (break ^^ Formula.to_doc assump))
           | (nm, A_Termvar) ->
              text nm)
    |> Seq_ext.intersperse (text "," ^^ break)
    |> concat
  in
  match goal with
  | Checking goal ->
     group (assumptions ^^ break ^^ text "⊢" ^^ break ^^ group (Formula.to_doc goal))
  | Synthesis (focus, goal) ->
     group (assumptions ^^ break ^^ text "[" ^^ Formula.to_doc focus ^^ text "] ⊢ " ^^ break ^^ Formula.to_doc goal)

module HTML_Bits (Html : Html_sig.S) = struct
  open Html

  let vertical content = div ~attrs:[ A.class_ "vertical" ] content
  let line content = div content

  let commentf fmt =
    Printf.ksprintf (fun s -> pre ~attrs:[ A.class_ "comment" ] (text s)) fmt

  let comment doc =
    let txt = Generalities.Pretty.to_string ~width:72 doc in
    pre ~attrs:[ A.class_ "comment" ] (text txt)

  let textf fmt = Printf.ksprintf text fmt
  let indent_box html = div ~attrs:[ A.class_ "indent" ] html
  let nbsp = "\xc2\xa0" (* NBSP in UTF-8 *)
end

module Make (Html : Html_sig.S) = struct
  open HTML_Bits (Html)
  open Fol_formula

  let render_hole ~goal ~command_entry ~msg =
    let open Html in
    let rendered_msg =
      match msg with
      | None -> empty
      | Some msg -> div ~attrs:[ A.class_ "errormsg" ] (text msg)
    in
    match goal with
    | Focused.Checking f ->
        div ~attrs:[ A.class_ "hole" ]
        @@ vertical
             [%concat
               comment
               Generalities.Pretty.(group
                                      (nest 4 (text "goal:"
                                               ^^ break
                                               ^^ group (Formula.to_doc f))));
               command_entry;
               rendered_msg]
    | Focused.Synthesis (got, want) ->
        div ~attrs:[ A.class_ "focushole hole" ]
        @@ vertical
             [%concat
                 (* FIXME: colour in the formulas? *)
                 comment (let open Generalities.Pretty in
                          group (text "focus:"
                                 ^^ nest 4 (break
                                            ^^ group (Formula.to_doc got))
                                 ^^ break
                                 ^^ text "goal:"
                                 ^^ nest 4 (break
                                            ^^ group (Formula.to_doc want))));
               command_entry;
               rendered_msg]

  let render_rule ~resetbutton ~rule ~children:boxes =
    let open Html in
    match rule with
    | Focused.Introduce x ->
        vertical
          [%concat
            div (resetbutton ^^ textf "introduce " ^^ em (text x) ^^ text ";");
            concat_list boxes]
    | Truth -> vertical [%concat div (resetbutton ^^ text "true")]
    | Split ->
        vertical
          [%concat
            div (resetbutton ^^ text "split:");
            ul
              ~attrs:[ A.class_ "casesplit" ]
              (concat_map (fun x -> li (indent_box x)) boxes)]
    | Left ->
        vertical
          [%concat
            div (resetbutton ^^ text "left;");
            concat_list boxes]
    | Right ->
        vertical
          [%concat
            div (resetbutton ^^ text "right;");
            concat_list boxes]
    | Exists term ->
        vertical
          [%concat
            (* FIXME: Term.to_html *)
            div (resetbutton ^^ textf "exists “%s”;" (Term.to_string term));
            concat_list boxes]
    | NotIntro h ->
        vertical
          [%concat
            div (resetbutton ^^ text "not-intro " ^^ em (text h) ^^ text ";");
            concat_list boxes]
    | Refl -> div (resetbutton ^^ text "reflexivity.")
    | Induction x ->
        vertical
          [%concat
            div
              [%concat
                resetbutton;
                text ("induction" ^ nbsp);
                em (text x);
                text ":"];
            ol ~attrs:[ A.class_ "casesplit" ] (concat_map li boxes)]
    | Use name ->
        vertical
          [%concat
            div
              ~attrs:[ A.class_ "focus" ]
              [%concat
                resetbutton;
                text "use ";
                em (text name);
                text ","];
            concat_list boxes]
    | Implies_elim -> (
        match boxes with
        | [ arg; elims ] ->
            vertical
              [%concat
                div (resetbutton ^^ text "apply");
                indent_box arg;
                elims]
        | _ -> text "SOMETHING WENT WRONG")
    | NotElim -> (
        match boxes with
        | [ arg ] ->
            vertical
              [%concat
                div (resetbutton ^^ text "not-elim");
                indent_box arg]
        | _ -> text "SOMETHING WENT WRONG")
    | Instantiate term ->
        vertical
          [%concat
            div
              [%concat
                resetbutton;
                text ("instantiate with “" ^ Term.to_string term ^ "”,")];
            concat_list boxes]
    | Conj_elim1 ->
        vertical
          [%concat
            div (resetbutton ^^ text "first,");
            concat_list boxes]
    | Conj_elim2 ->
        vertical
          [%concat
            div (resetbutton ^^ text "second,");
            concat_list boxes]
    | Cases (x, y) ->
        vertical
          [%concat
            div
              [%concat
                resetbutton;
                text ("cases" ^ nbsp ^ "(1)" ^ nbsp);
                em (text x);
                text (nbsp ^ "or" ^ nbsp ^ "(2)" ^ nbsp);
                em (text y);
                text ":"];
            ol ~attrs:[ A.class_ "casesplit" ] (concat_map li boxes)]
    | ExElim (a, b) ->
        vertical
          [%concat
            div
              [%concat
                resetbutton;
                text ("unpack" ^ nbsp ^ "as" ^ nbsp);
                em (text a);
                text (nbsp ^ "and" ^ nbsp);
                em (text b);
                text ":"];
            concat_list boxes]
    | Absurd -> text "false."
    | Subst (x, f) ->
        vertical
          [%concat
            div
              [%concat
                resetbutton;
                text ("subst" ^ nbsp);
                em (text x);
                text (nbsp ^ "in" ^ nbsp);
                text (Formula.to_string f);
                text ":"];
            concat_list boxes]
    | Rewrite dir ->
        vertical
          [%concat
            div
              (resetbutton
              ^^ text
                   ("rewrite"
                   ^ (match dir with `ltr -> "→" | `rtl -> "←")
                   ^ ";"));
            concat_list boxes]
    | Close -> div (resetbutton ^^ text "done.")

  let render_assumption = function
    | nm, Focused.A_Formula assump ->
       let open Generalities.Pretty in
       comment (group
                @@ (text "{ "
                    ^^ align (text "assuming"
                              ^^ nest 4 (break
                                         ^^ group (Formula.to_doc assump))
                              ^^ break
                              ^^ textf "with name ‘%s’ }" nm)));
    | nm, Focused.A_Termvar ->
       comment (Generalities.Pretty.textf "{ let ‘%s’ be an entity }" nm)
end

module type PROOF_TREE =
  Proof_tree.PROOF_TREE
    with type Calculus.goal = Focused.goal
     and type Calculus.assumption = Focused.assumption
     and type Calculus.rule = Focused.rule
     and type Hole.t = string * string option

module LaTeX (PT : PROOF_TREE) =
  Latex_of_prooftree.Make
    (PT)
    (struct
      open Fol_formula

      let latex_of_assumptions assumps =
        assumps |> List.rev
        |> List.map (function
             | _nm, Focused.A_Formula assump -> Formula.to_latex assump
             | nm, Focused.A_Termvar -> Printf.sprintf "\\mathit{%s}" nm)
        |> String.concat ", "

      let latex_of_sequent = function
        | assumptions, Focused.Checking goal ->
            Printf.sprintf "%s \\vdash %s"
              (latex_of_assumptions assumptions)
              (Formula.to_latex goal)
        | assumptions, Focused.Synthesis (focus, goal) ->
            Printf.sprintf "%s~[%s] \\vdash %s"
              (latex_of_assumptions assumptions)
              (Formula.to_latex focus) (Formula.to_latex goal)

      let name_of_rule = Focused.Rule.name
    end)
