let component label_text =
  let module C =
    struct
      type state = bool

      type action = Toggle

      let render ticked =
        let open Ulmus.Html in
        let attrs = [ A.type_ "checkbox"; E.onchange (fun _ -> Toggle) ] in
        let attrs = if ticked then A.checked true :: attrs else attrs in
        label (input ~attrs ^^ text " " ^^ text label_text)

      let update action state =
        match action with
        | Toggle -> not state

      let initial = false

      let serialise = function
        | true -> "1"
        | false -> "0"

      let deserialise = function
        | "1" -> Some true
        | "0" -> Some false
        | _   -> None
    end
  in (module C : Ulmus.PERSISTENT)
