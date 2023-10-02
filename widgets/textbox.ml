type state =
  { label   : string
  ; content : string
  }

type action = Update of string

let render { label; content } =
  let module H = Ulmus.Html in
  let (^^) = H.(^^) in
  H.label
    (H.text label
     ^^ H.text " "
     ^^ H.textarea ~attrs:[H.E.onchange (fun str -> Update str)]
          content)

let update action state =
  match action with
  | Update content ->
     { state with content }

let initial label =
  { label; content = "" }
