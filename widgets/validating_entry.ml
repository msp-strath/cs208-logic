module type VALIDATOR = sig
  type config

  val read_config : string -> config option

  val validate : config -> string -> (string, string) result
end

module Make (V : VALIDATOR) = struct

  type state =
    { value  : string
    ; config : V.config
    ; result : (string, string) result
    }

  type action = Update of string

  let render { value; result; config = _ } =
    let module H = Ulmus.Html in
    let module A = H.A in
    let module E = H.E in
    H.div ~attrs:[ A.class_ "defnsat" ] @@
      H.concat_list [
          H.div ~attrs:[ A.class_ "defnsat-entry" ]
            (H.input
               ~attrs:[
                 A.value value;
                 E.onchange (fun str -> Update str)
               ]);
          H.div ~attrs: [ A.class_ "defnsat-parseresult" ]
            (match result with
             | Error msg ->
                H.div ~attrs:[ A.class_ "errormsg" ] (H.text msg)
             | Ok msg ->
                H.div ~attrs:[ A.class_ "successmsg" ] (H.text msg))
        ]

  let update action state =
    match action with
    | Update value ->
       let result = V.validate state.config value in
       {state with value; result}

end
