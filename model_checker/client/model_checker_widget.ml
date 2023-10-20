let component initial =
  let module C =
    struct

      open Model_checker
      open Fol_formula

      type state = {
          input : string;
          parse_result : (Structure.t, string) result;
          fresh : bool;
          output :
            [ `Nothing
            | `Output of
                (Exec_structure.res list, Exec_structure.res list * string) result ];
          reseting : bool;
        }

      type action =
        | Update of string
        | RunChecker
        | Reset
        | ConfirmReset
        | CancelReset

      module R = struct
        open Checker
        open Ulmus.Html

        let textf fmt = Printf.ksprintf text fmt

        let rec render_refutation = function
          | IsFalse -> text "false"
          | NotEqual (x1, e1, x2, e2) ->
             textf "%s = %s refuted : %s = %s, but %s = %s" (Term.to_string x1)
               (Term.to_string x2) (Term.to_string x1)
               (Model.Entity.to_string e1)
               (Term.to_string x2)
               (Model.Entity.to_string e2)
          | Equal (x1, e, x2) ->
             textf "%s != %s refuted : both equal to %s" (Term.to_string x1)
               (Term.to_string x2) (Model.Entity.to_string e)
          | NotInRelation (r, tms, entities) ->
             textf "%s(%s) refuted : %s not in %s" r
               (String.concat "," (List.map Term.to_string tms))
               (Model.Tuple.to_string entities)
               r
          | ConclFalse (verification, reason) ->
             [%concat
                 text "Hypothesis verified: ";
              render_verification verification;
              br ();
              text "but conclusion refuted: ";
              render_refutation reason]
          | OrFail (reason1, reason2) ->
             [%concat
                 text "Both branches of 'or' refuted:";
              ol
                [%concat
                    li (render_refutation reason1);
                 li (render_refutation reason2)]]
          | AndLeft (reason, _) ->
             [%concat
                 text "First branch of 'and' refuted:";
              br ();
              render_refutation reason]
          | AndRight (_, reason) ->
             [%concat
                 text "Second branch of 'and' refuted:";
              br ();
              render_refutation reason]
          | NotTrue verification ->
             [%concat
                 text "Negation refuted, subformula was verified:";
              br ();
              render_verification verification]
          | ForallFail (x, entity, refutation) ->
             [%concat
                 textf "when %s = %s," x (Model.Entity.to_string entity);
              br ();
              render_refutation refutation]
          | ExistsFail (x, _f, refutations) ->
             [%concat
                 text "exists refuted by exhaustive checking:";
              match refutations with
              | [] -> br () ^^ em (text "Nothing exists in the universe!")
              | _ ->
                 ul
                   [%concat
                       refutations
                    |> concat_map (fun (e, refutation) ->
                           li
                             [%concat
                                 textf "when %s = %s," x (Model.Entity.to_string e);
                              br ();
                              render_refutation refutation])]]

        and render_verification = function
          | IsTrue -> text "true"
          | Equal (x1, e, x2) ->
             textf "%s = %s verified : both equal to %s" (Term.to_string x1)
               (Term.to_string x2) (Model.Entity.to_string e)
          | NotEqual (x1, e1, x2, e2) ->
             textf "%s != %s verified : %s = %s, but %s = %s" (Term.to_string x1)
               (Term.to_string x2) (Term.to_string x1)
               (Model.Entity.to_string e1)
               (Term.to_string x2)
               (Model.Entity.to_string e2)
          | InRelation (r, tms, entities) ->
             textf "%s(%s) verified : %s in %s" r
               (String.concat "," (List.map Term.to_string tms))
               (Model.Tuple.to_string entities)
               r
          | HypFalse (reason, _) ->
             [%concat
                 text "Hypothesis refuted";
              br ();
              render_refutation reason]
          | ConclTrue (_, reason) ->
             [%concat
                 text "Conclusion verified";
              br ();
              render_verification reason]
          | OrLeft (reason, _) ->
             [%concat
                 text "left branch verified:";
              br ();
              render_verification reason]
          | OrRight (_, reason) ->
             [%concat
                 text "right branch verified:";
              br ();
              render_verification reason]
          | And (reason1, reason2) ->
             [%concat
                 text "both branches of 'and' verified:";
              ol
                [%concat
                    li (render_verification reason1);
                 li (render_verification reason2)]]
          | NotFalse refutation ->
             [%concat
                 text "Negation verified, subformula was refuted:";
              br ();
              render_refutation refutation]
          | ForallSuc (x, _f, verifications) ->
             [%concat
                 text "“for all” verified by exhaustive checking:";
              match verifications with
              | [] ->
                 br ()
                 ^^ em (text "Nothing exists in the universe: nothing to check!")
              | _ ->
                 ul
                   [%concat
                       verifications
                    |> concat_map (fun (e, v) ->
                           li
                             [%concat
                                 textf "when %s = %s," x (Model.Entity.to_string e);
                              br ();
                              render_verification v])]]
          | ExistsSuc (x, e, verification) ->
             [%concat
                 textf "when %s = %s," x (Model.Entity.to_string e);
              br ();
              render_verification verification]

        let render_outcome = function
          | Verified v ->
             [%concat
                 text "Verified:";
              br ();
              render_verification v]
          | Refuted v ->
             [%concat
                 text "Refuted:";
              br ();
              render_refutation v]
      end

      let render_output =
        let open Ulmus.Html in
        function
        | Exec_structure.Message msg -> text msg
        | Exec_structure.Outcome (model_name, formula, outcome) ->
           [%concat
               text
               (Printf.sprintf "checking %s |= \"%s\"" model_name
                  (Formula.to_string formula));
            br ();
            R.render_outcome outcome]

      let num_newlines =
        String.fold_left (fun i -> function '\n' -> i+1 | _ -> i) 0

      let render state =
        let open Ulmus.Html in
        div
          ~attrs:[ A.class_ "defnsat" ]
          [%concat
              div
              ~attrs:[ A.class_ "defnsat-entry" ]
              (textarea
                 ~attrs:[ E.oninput (fun v -> Update v);
                          A.spellcheck false;
                          A.rows (max (num_newlines state.input + 1) 4) ]
                 state.input);
           div
             ~attrs:[ A.class_ "defnsat-parseresult" ]
             (match state.parse_result with
              | Error msg -> div ~attrs:[ A.class_ "errormsg" ] (text msg)
              | Ok _ ->
                 div ~attrs:[ A.class_ "successmessage" ] (text "Input understood."));
           div
             ~attrs:[ A.class_ "defnsat-button" ]
             [%concat
                 button
                 ~attrs:
                 [
                   E.onclick RunChecker;
                   A.class_ "runbutton";
                   A.enabled
                     (match state.parse_result with
                      | Ok _ -> true
                      | Error _ -> false);
                 ]
                 (text "Run");
              text " ";
              button
                ~attrs:[ E.onclick Reset; A.class_ "satresetbutton" ]
                (text "Reset")];
           div
             ~attrs:[ A.class_ "defnsat-results" ]
             (concat_list [
                  p (concat_list [
                         text "Results";
                         if (not state.fresh) && state.output <> `Nothing then
                           (br () ^^ text " (spec edited: results may be stale)")
                         else empty
                    ]);
                  div (match state.output with
                  | `Nothing -> empty
                  | `Output (Error (outputs, msg)) ->
                     ol (outputs |> concat_map (fun o -> li (render_output o))) ^^
                     div ~attrs:[ A.class_ "errormsg" ] (text msg)
                  | `Output (Ok outputs) ->
                     ol (outputs |> concat_map (fun o -> li (render_output o))))
             ]);
           if state.reseting then
             [%concat
                 div
                 ~attrs:
                 [
                   A.style
                     "grid-column: 1/3;grid-row: 1/4;background-color: \
                      #fff;opacity: 0.7;z-index: 50;";
                 ]
                 empty;
              div
                ~attrs:
                [
                  A.style
                    "background-color: #eee;grid-row: 1;grid-column: \
                     1/3;margin-left: 50px;margin-right: 50px;margin-top: \
                     50px;z-index: 100;border: 1px solid black;border-radius: \
                     5px;padding: 10px;text-align: center";
                ]
                [%concat
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
                 button ~attrs:[ E.onclick CancelReset ] (text "Cancel")]]]

      let parse input =
        match Reader.parse (Lexing.from_string input) with
        | Ok structure -> Ok structure
        | Error f ->
           let b = Buffer.create 100 in
           let fmt = Format.formatter_of_buffer b in
           f fmt;
           Format.pp_print_flush fmt ();
           Error (Buffer.contents b)

      let initial_full input =
        {
          input;
          parse_result = parse input;
          fresh = true;
          output = `Nothing;
          reseting = false;
        }

      let initial = initial_full initial

      let update action state =
        match action with
        | Update input ->
           let parse_result = parse input in
           { state with input; parse_result; fresh = false }
        | RunChecker -> (
          match state.parse_result with
          | Ok defns ->
             {
               state with
               fresh = true;
               output = `Output (Exec_structure.exec defns);
             }
          | Error _ -> state)
        | Reset -> { state with reseting = true }
        | ConfirmReset -> initial
        | CancelReset -> { state with reseting = false }

      let serialise { input; _ } =
        input

      let deserialise str =
        Some (initial_full str)
    end
  in (module C : Ulmus.PERSISTENT)
