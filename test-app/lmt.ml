
let () =
  Ulmus.attach_all
    "lmt"
    Lmt_widget.initial
    (module Lmt_widget)
