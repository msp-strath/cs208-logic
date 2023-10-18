open Sexplib.Conv
open Fol_formula
open Generalities

module App = struct
  open Natural_deduction

  type state =
    | Entering of { string : string }
    | Proving of {
        goal : formula;
        present : Focused_UI.state;
        instructions : bool;
      }

  let sexp_of_state = function
    | Entering { string } ->
       Sexplib.Type.(List [ Atom "Entering"; Atom string ])
    | Proving { present; goal; instructions } ->
       Sexplib.Type.(
        List
          [ Atom "Proving"
          ; Formula.sexp_of_t goal
          ; Focused_UI.sexp_of_state present
          ; sexp_of_bool instructions
       ])

  let serialise state =
    Sexplib.Sexp.to_string (sexp_of_state state)

  let state_of_sexp =
    let open Sexp_parser in
    match_tag @@
      function
      | "Entering" ->
         let* string = consume_next atom in
         let* ()     = assert_nothing_left in
         return (Entering { string })
      | "Proving" ->
         let* goal    = consume_next (of_conv Formula.t_of_sexp) in
         let* present =
           consume_next (of_conv (Focused_UI.state_of_sexp [] (Focused.Checking goal))) in
         let* instructions = consume_next (of_conv bool_of_sexp) in
         let* () = assert_nothing_left in
         return (Proving { goal; present; instructions })
      | _ ->
         fail "Unknown tag"

  let deserialise string =
    Result.to_option (state_of_sexp (Sexplib.Sexp.of_string string))

  type action =
    | UpdateFormula of string
    | Start of formula
    | StartAgain
    | ProofAction of Focused_UI.action
    | ToggleInstructions

  let render = function
    | Entering { string } ->
        let open Ulmus.Html in
        div
          ~attrs:[ A.style "align-self: flex-start" ]
          [%concat
            div
              [%concat
                p
                  (text
                     "Enter a formula and press <Enter> or click the button to \
                      start building a proof.")];
            let parsed = Formula.of_string string in
            div
              [%concat
                input
                  ~attrs:
                    [
                      A.value string;
                      A.class_ "initialformulaentry";
                      E.oninput (fun value -> UpdateFormula value);
                      E.onkeydown (fun mods key ->
                          match key with
                          | Js_of_ocaml.Dom_html.Keyboard_code.Enter -> (
                              match parsed with
                              | Ok f -> Some (Start f)
                              | Error _ -> None)
                          | _ -> None);
                    ];
                match parsed with
                | Error err ->
                    [%concat
                      (match err with
                      | `Parse (_, e, "") ->
                          text
                            (Printf.sprintf
                               "Problem: At the end of the input, %s" e)
                          ^^ br ()
                      | `Parse (_, e, l) ->
                          text
                            (Printf.sprintf "Problem: On the input '%s', %s" l e)
                          ^^ br ());
                      button
                        ~attrs:[ A.disabled true ]
                        (text "Start Proving...")]
                | Ok f ->
                    button
                      ~attrs:[ E.onclick (Start f) ]
                      (text "Start Proving...")];
            h3 (text "Instructions on entering formulas:")
            ^^ ul
                 [%concat
                   li
                     (text
                        "Predicate symbols are any sequence of letters and \
                         numbers, where the first character is a letter, \
                         followed by their arguments in parentheses. This is \
                         similar to the rules for variable names in Java.");
                   li
                     [%concat
                       text
                         "Connectives and Quantifiers are represented by ASCII \
                          versions:";
                       ul
                         [%concat
                           li
                             (text
                                "And (“∧”) is represented by “/\\” (forward \
                                 slash, backward slash).");
                           li
                             (text
                                "Or (“∨”) is represented by “\\/” (backward \
                                 slash, forward slash).");
                           li
                             (text
                                "Implies (“→”) is represented by “->” (dash, \
                                 greater than).");
                           li
                             (text
                                "Not “¬” is represented by “¬” (top left of \
                                 your keyboard). Alternatively, you can use \
                                 “~” (tilde) or “!” (exclamation mark).");
                           li (text "For all “∀x.” is represented by “all x.”.");
                           li (text "Exists “∃x.” is represented by “ex x.”.");
                           li
                             (text
                                "Use parentheses “(” and “)” to disambiguate \
                                 mixtures of connectives.")];
                       li
                         (text
                            "As an example of the use of ASCII for entering \
                             formulas, the formula“"
                         ^^ text
                              (Formula.to_string
                                 (Forall ("d",
                                          Or (Atom ("Sunny", [Var "d"]),
                                              Atom ("Rainy", [Var "d"])))))
                         ^^ text "” is entered as “"
                         ^^ code (text "all d. Sunny(d) \\/ Rainy(d)")
                         ^^ text
                              "”, where I have used a monospace font to make \
                               the individual characters clearer.");
                       li
                         (text
                            "The rules for mixing connectives and parentheses \
                             are as in Lecture 01.")]]]
    | Proving { present; instructions = false } ->
        let open Ulmus.Html in
        div
          ~attrs:
            [ A.style "display: flex; flex-direction: column; width: 100%" ]
          [%concat
            div
              ~attrs:
                [
                  A.style
                    "align-self: flex-start; width:100%; margin-bottom: 20px";
                ]
              (div
                 ~attrs:
                   [
                     A.style
                       "display: flex; justify-content: center; align-items: \
                        flex-start; width:100%";
                   ]
                 [%concat
                   div
                     ~attrs:[ A.style "flex: none" ]
                     [%concat
                       button
                         ~attrs:[ E.onclick StartAgain ]
                         (text "Enter a different formula");
                      text " ";
                       button
                         ~attrs:[ E.onclick ToggleInstructions ]
                         (text "Show Instructions")]]);
            div
              (map
                 (fun a -> ProofAction a)
                 (Focused_UI.render ~showtree:true ~showlatex:false present))]
    | Proving { present = _; instructions = true } ->
        let open Ulmus.Html in
        div
          ~attrs:[ A.style "display: flex; flex-direction: column" ]
          [%concat
            div
              ~attrs:[ A.style "align-self: flex-start; width:100%" ]
              (div
                 ~attrs:
                   [
                     A.style
                       "display: flex; justify-content: center; align-items: \
                        flex-start; width:100%";
                   ]
                 [%concat
                   div
                     ~attrs:[ A.style "flex: none" ]
                     [%concat
                       button
                         ~attrs:[ E.onclick ToggleInstructions ]
                         (text "Hide Instructions")]]);
            Focused_UI.instructions ~implication:true ~conjunction:true
              ~disjunction:true ~negation:true ~quantifiers:true ()]

  let rec name_assumptions i = function
    | [] -> []
    | f :: fs ->
        let name = if i = 0 then "H" else Printf.sprintf "H%d" i in
        (name, Focused.A_Formula f) :: name_assumptions (i + 1) fs

  let update action state =
    match (state, action) with
    | Entering _, UpdateFormula string -> Entering { string }
    | Entering _, Start f ->
        Proving
          {
            present = Focused_UI.init (Checking f);
            goal = f;
            instructions = false;
          }
    | Proving ({ present } as state), ProofAction a ->
        Proving
          { state with
            present = Focused_UI.update a present;
            instructions = false;
          }
    | Proving _, StartAgain -> Entering { string = "" }
    | Proving x, ToggleInstructions ->
        Proving { x with instructions = not x.instructions }
    | _, _ -> state

  let initial = Entering { string = "" }
end

let component _ = (module App : Ulmus.PERSISTENT)
