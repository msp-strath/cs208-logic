module Formula_validator = struct
  open Fol_formula

  module Html_of_formula = Formula.Make_HTML_Formatter (Ulmus.Html)

  type config = unit

  let name = "Enter a formula"
  let read_config _ = Some ()
  let placeholder _ = "<formula>"
  let validate _ str =
    match Formula.of_string str with
    | Ok f ->
       let module H = Ulmus.Html in
       let module A = H.A in
       Ok (H.concat_list
             [ H.text "Formula syntax understood:";
               H.div ~attrs:[ A.class_ "displayedformula"]
                 (Html_of_formula.html_of_formula f)
             ])
    | Error (`Parse err) ->
       Error (Parser_util.Driver.string_of_error err)
end

open Widgets

let components =
  [ "lmt", Slakemoth_widget.component
  ; "tickbox", Tickbox.component
  ; "textbox", Textbox.component
  ; "selection", Selection.component
  ; "entrybox", Validating_entry.component (module Validating_entry.Null_Validator)
  ; "formulaentry", Validating_entry.component (module Formula_validator)
  ; "rules", Natural_deduction.Rules.from_rules
  ; "rules-display", Natural_deduction.Rules.display_rules
  ; "focused-nd", Natural_deduction.Question.focusing_component
  ; "focused-tree", Natural_deduction.Question.tree_component
  ; "focused-freeentry", Nd_focusing_widget.component
  ; "model-checker", Model_checker_widget.component

  ; "ask", Natural_deduction.Ask.component
  ; "hoare", Natural_deduction.Hoare.component
  ]

let () =
  List.iter
    (fun (label, component) -> Ulmus.attach_all label component)
    components;
  Ulmus.attach_download_button "download"
