
let () =
  Ulmus.attach
    ~parent_id:"app"
    ~initial:(Lmt_widget.initial "")
    (module Lmt_widget)
