open Widgets

let () =
  Ulmus.attach_all "lmt" Lmt_widget.component;
  Ulmus.attach_all "tickbox" Tickbox.component;
  Ulmus.attach_all "textbox" Textbox.component
