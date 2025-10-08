open Generalities

module type VALIDATOR = sig
  type config

  val name : string

  val read_config : string -> config option

  val placeholder : config -> string

  val validate : config -> string -> (Impossible.t Ulmus.html , string) result
end

module Null_Validator = struct
  type config = string
  let name = ""
  let read_config placeholder = Some placeholder
  let placeholder placeholder = placeholder
  let validate _ _ = Ok (Ulmus.Html.text "")
end

let component (type config)
      (module V : VALIDATOR with type config = config)
      configuration_data =
  match V.read_config configuration_data with
  | None ->
     Error_display.component "Bad configuration"
  | Some config ->
     let module C =
       struct
         type state =
           { value  : string
           ; result : (Impossible.t Ulmus.html, string) result
           }

         type action = Update of string

         let render { value; result } =
           let module H = Ulmus.Html in
           let module A = H.A in
           let module E = H.E in
           H.div ~attrs:[ A.class_ "defnsat" ] @@
             H.concat_list [
                 H.div (H.b (H.text V.name));
                 H.div ~attrs:[ A.class_ "defnsat-entry" ]
                   (H.input
                      ~attrs:[
                        A.value value;
                        A.placeholder (V.placeholder config);
                        E.oninput (fun str -> Update str)
                   ]);
                 H.div ~attrs: [ A.class_ "defnsat-parseresult" ]
                   (match result with
                    | Error msg ->
                       H.div ~attrs:[ A.class_ "errormsg" ] (H.text msg)
                    | Ok msg ->
                       H.map  Impossible.elim (H.div ~attrs:[ A.class_ "successmsg" ] msg))
               ]

         let update action _state =
           match action with
           | Update value ->
              let result = V.validate config value in
              {value; result}

         let initial =
           { value = ""; result = V.validate config "" }

         let serialise { value; _ } = value
         let deserialise value =
           Some { value; result = V.validate config value }
       end
     in (module C : Ulmus.PERSISTENT)
