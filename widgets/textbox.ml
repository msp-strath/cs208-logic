let component label =
  let module C =
    struct
      type state = string

      type action = Update of string

      let render content =
        let module H = Ulmus.Html in
        let (^^) = H.(^^) in
        H.label
          (H.text label
           ^^ H.text " "
           ^^ H.textarea ~attrs:[H.E.onchange (fun str -> Update str)]
          content)

      let update action _ =
        match action with
        | Update content -> content

      let initial = ""

    end
  in (module C : Ulmus.COMPONENT)
