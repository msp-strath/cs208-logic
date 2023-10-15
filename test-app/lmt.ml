open Widgets

let () =
  Ulmus.attach_all "lmt" Lmt_widget.component;
  Ulmus.attach_all "tickbox" Tickbox.component;
  Ulmus.attach_all "textbox" Textbox.component;
  Ulmus.attach_all "rules" Natural_deduction.Rules.from_rules;
  Ulmus.attach_all "rules-display" Natural_deduction.Rules.display_rules;
  Ulmus.attach_all "focused-nd" Natural_deduction.Question.focusing_component
