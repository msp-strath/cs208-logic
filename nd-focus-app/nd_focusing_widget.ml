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
           consume_next (of_opt (Focused_UI.state_of_sexp [] (Focused.Checking goal))) in
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

let instructions ?(implication = true) ?(conjunction = true)
    ?(disjunction = false) ?(negation = false) ?(quantifiers = false)
    ?(equality = false) ?(induction = false) () =
  let open Ulmus.Html in
  div
    [%concat
      h2 (text "Proof commands");
      p
        (text
           "The blue boxes represent parts of the proof that are unfinished. \
            The comment (in green) tells you what the current goal is: either \
            the goal is unfocused: "
        ^^ span ~attrs:[ A.class_ "comment" ] (text "{ goal: <some formula> }")
        ^^ text ", or it has a focus: "
        ^^ span
             ~attrs:[ A.class_ "comment" ]
             (text "{ focus: <formula1>; goal: <formula2> }")
        ^^ text ". "
        ^^ text
             "The commands that you can use differ according to which mode you \
              are in. The commands correspond directly to the proof rules \
              given in the Week 04 videos.");
      h3 (text "Unfocused mode");
      p
        (text
           "These rules can be used when the comment in the blue part looks \
            like "
        ^^ span ~attrs:[ A.class_ "comment" ] (text "{ goal: <formula> }")
        ^^ text
             ". These rules either act on the conclusion, or switch to focused \
              mode ("
        ^^ code (text "use")
        ^^ text ").");
      ul
        [%concat
          if implication then
            li
              [%concat
                code (text "introduce " ^^ em (text "H"));
                text
                  " : can be used when the goal is an implication ‘P → Q’. The \
                   name ";
                code (em (text "H"));
                text
                  " is used to give a name to the new assumption P. The proof \
                   then continues proving Q with this new assumption. A green \
                   comment is inserted to say what the new named assumption \
                   is."];
          if quantifiers then
            li
              [%concat
                code (text "introduce " ^^ em (text "y"));
                text " : can be used when the goal is ‘∀x. Q’. The name ";
                code (em (text "y"));
                text
                  " is used for the assumption of an arbitrary individual that \
                   we have to prove ‘Q’ for. The proof then continues proving \
                   ‘Q’. A green comment is inserted to say that the rest of \
                   this branch of the proof is under the assumption that there \
                   is a named entity."];
          if conjunction then
            li
              [%concat
                code (text "split");
                text
                  " : can be used when the goal is a conjunction ‘P ∧ Q’. The \
                   proof will split into two sub-proofs, one to prove the \
                   first half of the conjunction P, and one to prove the other \
                   half Q."];
          if conjunction then
            li
              [%concat
                code (text "true");
                text
                  " : can be used when the goal to prove is ‘T’ (true). This \
                   will finish this branch of the proof."];
          if disjunction then
            li
              [%concat
                code (text "left");
                text
                  " : can be used when the goal to prove is a disjunction ‘P ∨ \
                   Q’. A new sub goal will be created to prove ‘P’."];
          if disjunction then
            li
              [%concat
                code (text "right");
                text
                  " : can be used when the goal to prove is a disjunction ‘P ∨ \
                   Q’. A new sub goal will be created to prove ‘Q’."];
          if negation then
            li
              [%concat
                code (text "not-intro " ^^ em (text "H"));
                text
                  " : can be used when the goal is a negation ‘¬P’. The name ";
                code (em (text "H"));
                text
                  " is used to give a name to the new assumption P. The proof \
                   then continues proving F (i.e. False) with this new \
                   assumption. A green comment is inserted to say what the new \
                   named assumption is."];
          if quantifiers then
            li
              [%concat
                code (text "exists \"t\"");
                text " : can be used when the goal is ‘∃x. Q’. The term ";
                code (text "t");
                text
                  " which must be in quotes, is used as the existential \
                   witness and substituted for ";
                code (text "x");
                text " in Q. The proof then continues proving ‘Q[x:=t]’."];
          if equality then
            li
              [%concat
                code (text "refl");
                text
                  " : can be used when the goal is ‘t = t’ to prove that every \
                   term is equal to itself. If this command is applicable, \
                   this branch of the proof is complete."];
          if induction then
            li
              [%concat
                code (text "induction x");
                text
                  " : can be used when the variable ‘x’ is in scope. This will \
                   start a proof by induction on ‘x’. The proof will split \
                   into two branches, one to prove the case when ‘x = 0’, and \
                   one to prove the case when ‘x = S(x1)’. In the latter case, \
                   you get to assume the ";
                em (text "induction hypothesis ");
                text
                  "which states that the property being proved is true for \
                   ‘x1’."];
          li
            [%concat
              code (text "use " ^^ em (text "H"));
              text " : can be used whenever there is no current focus. ";
              em (text "H");
              text
                " is the name of some assumption that is available on this \
                 branch of the proof. Named assumptions come from uses of ";
              code (text "introduce H");
              text ", ";
              code (text "cases H1 H2");
              text ", ";
              code (text "not-intro H");
              text ", and ";
              code (text "unpack y H");
              text "."]];
      h3 (text "Focused mode");
      p
        (text
           "These rules apply when there is a formula in focus. In this case, \
            the comment in the blue part looks like: "
        ^^ span
             ~attrs:[ A.class_ "comment" ]
             (text "{ focus: <formula1>; goal: <formula2> }")
        ^^ text
             ". These rules either act upon the formula in focus, or finish \
              the proof when the focused formula is the same as the goal.");
      ul
        [%concat
          li
            [%concat
              code (text "done");
              text
                " : can be used when the formula in focus is exactly the same \
                 as the goal formula."];
          if implication then
            li
              [%concat
                code (text "apply");
                text
                  " : can be used when the formula in focus is an implication \
                   ‘P → Q’. A new subgoal to prove ‘P’ is generated, and the \
                   focus becomes ‘Q’ to continue the proof."];
          if conjunction then (
            li
              [%concat
                code (text "first");
                text
                  " : can be used when the formula in focus is a conjunction \
                   ‘P ∧ Q’. The focus then becomes ‘P’, the first part of the \
                   conjunction, and the proof continues."];
            li
              [%concat
                code (text "second");
                text
                  " : can be used when the formula in focus is a conjunction \
                   ‘P ∧ Q’. The focus then becomes ‘Q’, the second part of the \
                   conjunction, and the proof continues."]);
          if disjunction then (
            li
              [%concat
                code (text "cases " ^^ em (text "H1 H2"));
                text
                  " : can be used then the formula in focus is a disjunction \
                   ‘P ∨ Q’. The proof will split into two halves, one for ‘P’ \
                   and one for ‘Q’. The two names ";
                em (text "H1");
                text " and ";
                em (text "H2");
                text
                  " are used to name the new assumption on the two branches. \
                   Green comments are inserted to say what the new named \
                   assumptions are."];
            li
              [%concat
                code (text "false");
                text
                  " : can be used when the formula in focus is ‘F’ (false). \
                   The proof finishes at this point."]);
          if negation then
            li
              [%concat
                code (text "not-elim");
                text
                  " : can be used when the formula in focus is a negation \
                   ‘¬P’. A new subgoal is generated to prove ‘P’."];
          if quantifiers then
            li
              [%concat
                code (text "inst \"t\"");
                text
                  " : can be used when the formula in focus is a “∀x. ...”. \
                   The term t is substituted in the place of x in the formula \
                   after the quantifier. Note that quote marks (\") are \
                   required around the term. This applies the Instantiate rule \
                   from the lectures."];
          if quantifiers then
            li
              [%concat
                code
                  (text "unpack " ^^ em (text "y") ^^ text " " ^^ em (text "H"));
                text
                  " : can be used when the formula in focus is a “∃x. ...”. \
                   The existential is “unpacked” into the assumption of an \
                   entity ‘y’ and its property ‘H’. Green comments are \
                   inserted to say what the assumption ‘H’ refers to."];
          if equality then
            [%concat
              li
                [%concat
                  code (text "rewrite->");
                  text
                    " : can be used when the formula in focus is an equality \
                     ‘t1 = t2’. Every occurrence of ‘t1’ in the goal is \
                     rewritten to ‘t2’. (The rewrite goes left to right.)"];
              li
                [%concat
                  code (text "rewrite<-");
                  text
                    " : can be used when the formula in focus is an equality \
                     ‘t1 = t2’. Every occurrence of ‘t2’ in the goal is \
                     rewritten to ‘t1’. (The rewrite goes right to left.)"]]]]


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
                 (Focused_UI.render ~showtree:true present))]
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
            instructions ~implication:true ~conjunction:true
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
