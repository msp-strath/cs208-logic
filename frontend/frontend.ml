module Formula_validator = struct
  open Fol_formula

  type config = unit

  let read_config _ = Some ()
  let placeholder _ = "<formula>"
  let validate _ str =
    match Formula.of_string str with
    | Ok f ->
       Ok ("Formula is: " ^ Formula.to_string f)
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
  ]

let () =
  List.iter
    (fun (label, component) -> Ulmus.attach_all label component)
    components;
  Ulmus.attach_download_button "download"
