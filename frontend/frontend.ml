open Widgets

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

let () =
  Ulmus.attach_all "lmt" Slakemoth_widget.component;
  Ulmus.attach_all "tickbox" Tickbox.component;
  Ulmus.attach_all "textbox" Textbox.component;
  Ulmus.attach_all "selection" Selection.component;
  Ulmus.attach_all "entrybox"
    (Validating_entry.component (module Validating_entry.Null_Validator));
  Ulmus.attach_all "formulaentry"
    (Validating_entry.component (module Formula_validator));

  Ulmus.attach_all "rules" Natural_deduction.Rules.from_rules;
  Ulmus.attach_all "rules-display" Natural_deduction.Rules.display_rules;
  Ulmus.attach_all "focused-nd" Natural_deduction.Question.focusing_component;
  Ulmus.attach_all "focused-tree" Natural_deduction.Question.tree_component;
  Ulmus.attach_all "focused-freeentry" Nd_focusing_widget.component;
  Ulmus.attach_download_button "download"
