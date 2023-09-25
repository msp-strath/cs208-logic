module Ast = Traintor.Ast

type state = {
    input : string;
    parse_result : (Ast.declaration list, string) result;
    fresh : bool;
    output: [`Nothing | `String of string ];
    initial : string;
    resetting : bool;
  }

type action =
  | Update of string
  | Run
  | Reset
  | ConfirmReset
  | CancelReset

(*
let render_output =
  let open Ulmus.Dynamic_HTML in
  function
  | Exec_structure.Message msg -> text msg
  | Exec_structure.Outcome (model_name, formula, outcome) ->
      [%concat
        text
          (Printf.sprintf "checking %s |= \"%s\"" model_name
             (Formula.to_string formula));
        br ();
        R.render_outcome outcome]
 *)

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
           | Ok _ ->
              div ~attrs:[ A.class_ "successmessage" ] (text "Input understood."));
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
                  (text s)
                ]);
(*                   match state.output with *)
(*               | `Nothing -> empty *)
(* (\*              | `Output (Error (outputs, msg)) -> *)
(*                  concat_list [ *)
(*                      ol (outputs |> concat_map (fun o -> li (render_output o))); *)
(*                      div ~attrs:[ A.class_ "errormsg" ] (text msg) *)
(*                    ] *)
(*               | `Output (Ok outputs) -> *)
(*                  ol (outputs |> concat_map (fun o -> li (render_output o))) *\) *)
(*             ]; *)
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
  (* FIXME: type check as well *)
  match Traintor.Reader.parse input with
  | Ok decls ->
     (match Traintor.Type_checker.check_declarations decls with
      | Ok _commands ->
         Ok decls
      | Error (`Type_error (location, msg)) ->
         Error (Printf.sprintf "Problem at %a: %s"
                 Ast.Location.to_string location
                 msg))
  | Error (`Parse err) ->
     Error (Parser_util.Driver.string_of_error err)

let initial_full initial input =
  {
    input;
    parse_result = parse input;
    fresh = true;
    output = `Nothing;
    initial;
    resetting = false;
  }

let initial input = initial_full input input

let update action state =
  match action with
  | Update input ->
      let parse_result = parse input in
      { state with input; parse_result; fresh = false }
  | Run ->
     state
 (*    (
      match state.parse_result with
      | Ok defns ->
          {
            state with
            fresh = true;
            output = `Output (Exec_structure.exec defns);
          }
      | Error _ -> state) *)
  | Reset -> { state with resetting = true }
  | ConfirmReset -> initial state.initial
  | CancelReset -> { state with resetting = false }

let sexp_of_state { input; _ } = Sexplib0.Sexp.Atom input

let state_of_sexp init = function
  | Sexplib0.Sexp.Atom input -> initial_full init input
  | sexp ->
      raise
        (Sexplib0.Sexp_conv.Of_sexp_error
           (Failure "defnsat_widget: expecting a pair", sexp))
