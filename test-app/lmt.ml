open Widgets

let () =
  Ulmus.attach_all
    "lmt"
    Lmt_widget.initial
    (module Lmt_widget);

  Ulmus.attach_all
    "tickbox"
    Tickbox.initial
    (module Tickbox);

  Ulmus.attach_all
    "textbox"
    Textbox.initial
    (module Textbox)
