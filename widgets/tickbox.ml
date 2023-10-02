type state =
  { ticked : bool
  ; label  : string
  }

type action = Toggle

let render {ticked; label=label_text} =
  let open Ulmus.Html in
  let attrs = [ A.type_ "checkbox"; E.onchange (fun _ -> Toggle) ] in
  let attrs = if ticked then A.checked true :: attrs else attrs in
  label (input ~attrs ^^ text " " ^^ text label_text)

let update action state =
  match action with
  | Toggle ->
     { state with ticked = not state.ticked }

let initial label =
  { label; ticked = false }
