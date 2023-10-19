open Generalities

let config_p =
  let open Sexp_parser in
  tagged "config"
    (consume_one "options" (one (list atom)))


let component config =
  match config_p (Sexplib.Sexp.of_string config) with
  | Error err ->
     Error_display.component (Annotated.detail err)
  | Ok options ->
     let module C =
       struct
         type state = { selected : string option }

         type action = Select of string

         let render { selected } =
           let open Ulmus.Html in
           p (concat_map
                (fun option ->
                  let attrs =
                    [ E.oninput (fun _ -> Select option);
                      A.type_ "radio";
                    ] in
                  let attrs =
                    if Option.equal String.equal (Some option) selected then
                      A.checked true :: attrs
                    else
                      attrs
                  in
                  label (input ~attrs ^^ text " " ^^ text option))
                options)

         let update (Select selected) _ = {selected = Some selected}

         let initial = { selected = None }

         let to_sexp = function
           | { selected = None } -> Sexplib.Sexp.(List [ Atom "None" ])
           | { selected = Some selected } -> List [ Atom "Some"; Atom selected ]

         let of_sexp =
           let open Sexp_parser in
           match_tag
             (function
              | "None" ->
                 let* () = assert_nothing_left in
                 return { selected = None }
              | "Some" ->
                 let* selected = consume_next atom in
                 let* () = assert_nothing_left in
                 return { selected = Some selected }
              | _ ->
                 fail "unexpected tag")

         let serialise state = Sexplib.Sexp.to_string (to_sexp state)
         let deserialise str = Result.to_option (of_sexp (Sexplib.Sexp.of_string str))
       end
     in (module C : Ulmus.PERSISTENT)
