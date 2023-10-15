let component configuration =
  let module C =
    struct

      module Ast = Slakemoth.Ast
      open Slakemoth.Environment

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

      let update action state =
        match action with
        | Update input ->
           let parse_result = parse input in
           { state with input; parse_result; fresh = false }
        | Run ->
           (match state.parse_result with
            | Ok commands ->
               let b = Buffer.create 8192 in
               let fmt = Format.formatter_of_buffer b in
               List.iter (Slakemoth.Evaluator.execute_command fmt) commands;
               Format.pp_print_flush fmt ();
               { state with fresh = true; output = `String (Buffer.contents b) }
            | Error _ ->
               (* Button should be disabled to prevent this *)
               state)
        | Reset -> { state with resetting = true }
        | ConfirmReset -> initial
        | CancelReset -> { state with resetting = false }
(*
      let sexp_of_state { input; _ } =
        Sexplib0.Sexp.Atom input

      let state_of_sexp = function
        | Sexplib0.Sexp.Atom input -> initial_full input
        | sexp ->
           raise
             (Sexplib0.Sexp_conv.Of_sexp_error
             (Failure "defnsat_widget: expecting a single atom", sexp))
 *)
    end
  in (module C : Ulmus.COMPONENT)
