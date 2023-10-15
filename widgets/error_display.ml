let component errormsg =
  let module C =
    struct
      type state = unit
      type action = |

      let render () =
        let module H = Ulmus.Html in
        let module A = H.A in
        H.p ~attrs:[ A.class_ "errormsg" ] (H.text errormsg)

      let update (action : action) _ = match action with _ -> .

      let initial = ()

      let serialise _ = ""
      let deserialise _ = Some ()
    end
  in (module C : Ulmus.PERSISTENT)
