open Sexplib0.Sexp_conv

module Hole = struct
  type goal = Focused.goal
  type t = string * string option [@@deriving sexp]

  let empty _ = ("", None)
end

module PT = Proof_tree.Make (Focused) (Hole)

type state = PT.t

let sexp_of_state state = PT.sexp_of_tree (PT.to_tree state)

let state_of_sexp assumptions goal sexp =
  match PT.of_tree assumptions goal (PT.tree_of_sexp sexp) with
  | Ok state -> state
  | Error _ -> failwith "invalid tree"

let init ?assumptions goal = PT.init ?assumptions goal

type action =
  | UpdateHole of PT.point * Hole.t
  | SendHole of PT.point * string
  | ResetTo of PT.point

module SequentTreeRenderer =
  Proof_tree_sequents.Make (Ulmus.Html) (PT)
    (struct
      let string_of_sequent = Focused_proof_renderer.string_of_sequent
      let name_of_rule = Focused.Rule.name
    end)

module LaTeXRenderer = Focused_proof_renderer.LaTeX (PT)
module H = Focused_proof_renderer.HTML_Bits (Ulmus.Html)

module Renderer = struct
  open Focused_proof_renderer.HTML_Bits (Ulmus.Html)
  include Focused_proof_renderer.Make (Ulmus.Html)

  let resetbutton pt =
    let open Ulmus.Html in
    button
      ~attrs:[ E.onclick (ResetTo pt); A.class_ "resetbutton" ]
      (text "reset")

  let render_box assumps content =
    let open Ulmus.Html in
    match assumps with
    | [] -> content
    | assumps ->
        vertical
          [%concat
            concat_map (fun (x, _) -> render_assumption x) assumps;
            (* FIXME: put the goal here? *)
            content]

  let render =
    PT.fold
      (fun pt focus (content, msg) ->
        let open Ulmus.Html in
        let command_entry =
          input
            ~attrs:
              [
                A.class_ "commandinput";
                A.value content;
                A.placeholder "<command>";
                E.oninput (fun value -> UpdateHole (pt, (value, msg)));
                E.onkeydown (fun mods key ->
                    match key with
                    | Js_of_ocaml.Dom_html.Keyboard_code.Enter ->
                        Some (SendHole (pt, content))
                    | _ -> None);
              ]
        in
        render_hole ~goal:(PT.goal pt) ~command_entry ~msg)
      (fun pt rule children ->
        render_rule ~resetbutton:(resetbutton pt) ~rule ~children)
      render_box
end

let num_holes prooftree =
  PT.fold
    (fun _ _ _ -> 1)
    (fun _ _ l -> List.fold_left ( + ) 0 l)
    (fun _ x -> x)
    prooftree

let render ~showtree ?name ?assumps_name ?(showlatex = false) prooftree =
  let open Ulmus.Html in
  let open H in
  vertical
    [%concat
      div
        [%concat
          (match name with
          | None -> strong (text "Theorem: ")
          | Some name ->
              strong (text "Theorem ");
              text name;
              strong (text " : "));
          match assumps_name with
          | None ->
              text
                (Focused_proof_renderer.string_of_sequent
                   (PT.root_assumptions prooftree, PT.root_goal prooftree))
          | Some name ->
              let open Fol_formula in
              text
                (match PT.root_goal prooftree with
                | Checking goal -> name ^ " ⊢ " ^ Formula.to_string goal
                | Synthesis (focus, goal) ->
                    name ^ " [" ^ Formula.to_string focus ^ "] ⊢ "
                    ^ Formula.to_string goal)];

      div (strong (text "Proof"));
      indent_box (Renderer.render prooftree);

      (match num_holes prooftree with
      | 0 -> div (strong (text "Proof Complete."))
      | 1 -> div (em (strong (textf "Proof incomplete (1 subgoal open).")))
      | n -> div (em (strong (textf "Proof incomplete (%d subgoals open)." n))));

      if showtree then
        [%concat
          text "Proof tree:";
          div
            ~attrs:[ A.style "display: flex; overflow-x: auto" ]
            (SequentTreeRenderer.render prooftree)];

      if showlatex then
        div
          (pre
             (let buffer = Buffer.create 100 in
              let fmt = Format.formatter_of_buffer buffer in
              LaTeXRenderer.render fmt prooftree;
              Format.pp_print_flush fmt ();
              text (Buffer.contents buffer)))]

let update action _prooftree =
  match action with
  | UpdateHole (pt, hole_data) -> PT.set_hole hole_data pt
  | SendHole (pt, command) -> (
      match Focused_command.of_string command with
      | Ok rule -> (
          match PT.apply rule pt with
          | Ok prooftree -> prooftree
          | Error (`RuleError msg) -> PT.set_hole (command, Some msg) pt)
      | Error msg -> PT.set_hole (command, Some msg) pt)
  | ResetTo pt ->
      (* let tree = PT.subtree_of_point pt in *)
      PT.set_hole ("" (*string_of_tree tree*), None) pt

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
