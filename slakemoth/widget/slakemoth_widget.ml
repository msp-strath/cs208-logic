let component configuration =
  let module C =
    struct

      module Ast = Slakemoth.Ast
      open Slakemoth.Environment
      open Generalities

      type state = {
          input : string;
          parse_result : (command list, string) result;
          fresh : bool;
          output: [`Nothing | `String of string ];
          (* result_hidden : bool; *)
          resetting : bool;
        }

      type action =
        | Update of string
        | Run
        (* | HideResult *)
        | Reset
        | ConfirmReset
        | CancelReset

      let num_newlines =
        String.fold_left (fun i -> function '\n' -> i+1 | _ -> i) 0

      let render state =
        let open Ulmus.Html in
        div ~attrs:[ A.class_ "defnsat" ] @@
          concat_list [
              div ~attrs:[ A.class_ "defnsat-entry" ] @@
                concat_list [
                    textarea
                      ~attrs:[
                        E.oninput (fun v -> Update v);
                        A.spellcheck false;
                        A.rows (max (num_newlines state.input + 1) 4);
                      ]
                      state.input
                  ];
              div ~attrs:[ A.class_ "defnsat-parseresult" ] @@
                (match state.parse_result with
                 | Error msg -> div ~attrs:[ A.class_ "errormsg" ] (text msg)
                 | Ok commands ->
                    let num_commands = List.length commands in
                    let msg = Printf.sprintf "Input understood. %d command%s to run."
                                num_commands (if num_commands = 1 then "" else "s")
                    in
                    div ~attrs:[ A.class_ "successmessage" ]
                      (text msg));
              div ~attrs:[ A.class_ "defnsat-button" ] @@
                concat_list [
                    button
                      ~attrs:
                      [
                        E.onclick Run;
                        A.class_ "runbutton";
                        A.disabled
                          (match state.parse_result with
                           | Ok _ -> false
                           | Error _ -> true);
                      ]
                      (text "Run");
                    text " ";
                    button
                      ~attrs:[ E.onclick Reset; A.class_ "satresetbutton" ]
                      (text "Reset")
                  ];
              (match state.output with
               | `Nothing -> empty
               | `String s ->
                  div ~attrs:[ A.class_ "defnsat-results" ] @@
                    concat_list [
                        p @@ concat_list [
                                 text "Results";
                                 if (not state.fresh) && state.output <> `Nothing then
                                   concat_list [
                                       br ();
                                       text " (code edited: results may be stale)"
                                     ]
                                 else empty
                               ];
                        code (pre (text s))
              ]);
              if state.resetting then
                concat_list [
                    div ~attrs:[
                        A.style
                          "grid-column: 1/3;grid-row: 1/4;background-color: \
                           #fff;opacity: 0.7;z-index: 50;";
                      ]
                      empty;
                    div ~attrs:[
                        A.style
                          "background-color: #eee;grid-row: 1;grid-column: \
                           1/3;margin-left: 50px;margin-right: \
                           50px;margin-top: 50px;z-index: 100;border: 1px \
                           solid black;border-radius: 5px;padding: \
                           10px;text-align: center";
                      ]
                      (concat_list [
                           text "Are you sure you want to reset to the original state?";
                           br ();
                           button
                             ~attrs:
                             [
                               E.onclick ConfirmReset;
                               A.style "background-color: red; color: white";
                             ]
                             (text "Confirm Reset");
                           text " ";
                           button ~attrs:[ E.onclick CancelReset ] (text "Cancel")
                      ])
                  ]
              else
                empty
            ]

      let parse input =
        match Slakemoth.Reader.parse input with
        | Ok decls ->
           (match Slakemoth.Type_checker.check_declarations decls with
            | Ok commands ->
               Ok commands
            | Error (`Type_error (location, msg)) ->
               Error (Printf.sprintf "Problem at %a: %s"
                        Ast.Location.to_string location
                        msg))
        | Error (`Parse err) ->
           Error (Parser_util.Driver.string_of_error err)

      let initial_full input =
        {
          input;
          parse_result = parse input;
          fresh = true;
          output = `Nothing;
          resetting = false;
        }

      let initial = initial_full configuration

      let limit sequence =
        let limit = 50 in
        let rec take items n s =
          if n = limit then
            (List.rev items, `Limited)
          else match s () with
               | Seq.Nil -> List.rev items, `All
               | Seq.Cons (x, xs) -> take (x::items) (n+1) xs
        in
        take [] 0 sequence

      let update action state =
        match action with
        | Update input ->
           let parse_result = parse input in
           { state with input; parse_result; fresh = false }
        | Run ->
           (match state.parse_result with
            | Ok commands ->
               let b = Buffer.create 8192 in
               commands
               |> List.to_seq
               |> Seq.map Slakemoth.Evaluator.execute_command
               |> Seq.map limit
               |> Seq.iter (fun (jsons, limited) ->
                      jsons
                      |> List.iter (fun json ->
                             Pretty.to_buffer ~width:50 b
                               (Json.to_document json);
                             Buffer.add_string b "\n");
                      match limited with
                      | `Limited ->
                         Buffer.add_string b
                           "<more solutions exist, only showing first 50>\n"
                      | `All -> ());
               { state with fresh = true; output = `String (Buffer.contents b) }
            | Error _ ->
               (* Button should be disabled to prevent this *)
               state)
        | Reset -> { state with resetting = true }
        | ConfirmReset -> initial
        | CancelReset -> { state with resetting = false }

      let serialise { input; _ } = input

      let deserialise saved =
        Some (initial_full saved)
    end
  in (module C : Ulmus.PERSISTENT)
