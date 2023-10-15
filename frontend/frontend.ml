open Widgets

let () =
  Ulmus.attach_all "lmt" Slakemoth_widget.component;
  Ulmus.attach_all "tickbox" Tickbox.component;
  Ulmus.attach_all "textbox" Textbox.component;
  Ulmus.attach_all "entrybox" (Validating_entry.component (module Validating_entry.Null_Validator));

  Ulmus.attach_all "rules" Natural_deduction.Rules.from_rules;
  Ulmus.attach_all "rules-display" Natural_deduction.Rules.display_rules;
  Ulmus.attach_all "focused-nd" Natural_deduction.Question.focusing_component;
  Ulmus.attach_all "focused-tree" Natural_deduction.Question.tree_component;
  Ulmus.attach_download_button "download"
