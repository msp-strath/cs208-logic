open Generalities

(* Plan:

  1. Load the coursework description to get all the questions' specifications.
     FIXME: annotate with mark value

  2. For each question, load from the submission and check the proof

  3. Render the proof into HTML document, with the mark total

  4. Output the marks and the html feedback in one go *)

(* Plan 2:

   1. Load the coursework description from the question sheet.
      Kinds of questions:
      a. formulaentry, with marks available
      b. comment, that goes with a formula-entry
      c.

   2. Load the answers file, and generate a marking sheet
      - for the formulaentry questions:
        Try to parse the answer; render parsed version if it works; otherwise the original
        Attach the
 *)

(* Plan 3:
   - Read in the coursework.md and the .answers.
   - Augment the coursework document with the given answers, to a new .md file
     - remove 'ids'
     - add feedback boxes
     - add marking boxes
   - Render
   - Accumulate all the marking results and feedback, and re-render to marks and feedback file
 *)

module Focused = struct
  open Natural_deduction
  open Sexplib.Conv

  module Hole = struct
    type t = string * string option [@@deriving sexp]

    let empty = ("", None)
  end

  module PT = Proof_tree.Make (Focused) (Hole)

  let num_holes prooftree =
    PT.fold
      (fun _ _ -> 1)
      (fun _ _ l -> List.fold_left ( + ) 0 l)
      (fun _ x -> x)
      prooftree

  module R = struct
    include Focused_proof_renderer.HTML_Bits (Html_static)
    include Focused_proof_renderer.Make (Html_static)

    let render_box assumps content =
      let open Html_static in
      match assumps with
      | [] -> content
      | assumps ->
          vertical
            [%concat
              concat_map render_assumption assumps;
              (* FIXME: put the goal here? *)
              content]

    let render =
      PT.fold
        (fun pt (content, msg) ->
          let open Html_static in
          let command_entry =
            input
              ~attrs:
                [
                  A.class_ "commandinput";
                  A.value content;
                  A.placeholder "<command>";
                ]
          in
          render_hole ~goal:(PT.goal pt) ~command_entry ~msg)
        (fun _pt rule children ->
          render_rule ~resetbutton:Html_static.empty ~rule ~children)
        render_box
  end

  let render ?name ?assumps_name prooftree =
    let open Html_static in
    let open R in
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
        indent_box (render prooftree);

        match num_holes prooftree with
        | 0 -> div (strong (text "Proof Complete."))
        | 1 -> div (em (strong (textf "Proof incomplete (1 subgoal open).")))
        | n ->
            div (em (strong (textf "Proof incomplete (%d subgoals open)." n)))]

  let qn ~marks:max config sexp =
    let open Natural_deduction.Focused_config in
    match
      PT.of_tree config.assumptions (Focused.Checking config.goal) (PT.tree_of_sexp sexp)
    with
    | Error (`LengthMismatch (s, rule)) ->
        Error (`Msg (Printf.sprintf "Natural Deduction decode error: Length mismatch: %s on %s" s (Sexplib.Sexp.to_string rule)))
    | Error (`RuleError e) ->
        Error (`Msg (Printf.sprintf "Natural Deduction decode error: %s" e))
    | Ok state ->
       (let name = config.name in
        let proof_tree = render ?name state in
        if num_holes state = 0 then
          Ok (max, proof_tree)
        else
          Ok (0, proof_tree))
end


module Hoare_qn = struct
  open Natural_deduction
  open Sexplib0.Sexp_conv

  module Hole = struct
    type t =
      { command : string
      ; message : string option
      } [@@deriving sexp]

    let empty = { command = ""; message = None }
  end

  module PT = Proof_tree.Make (Hoare_calculus) (Hole)

  let num_holes prooftree =
    PT.fold
      (fun _ _ -> 1)
      (fun _ _ l -> List.fold_left ( + ) 0 l)
      (fun _ x -> x)
      prooftree

  (* FIXME: a renderer *)
  module H = Focused_proof_renderer.HTML_Bits (Html_static)
  open Natural_deduction.Hoare_renderer.Make (Html_static)

  let render_box assumps content position =
    match assumps, position with
    | [], _ | _, `Top ->
       (* Do not render top-level assumptions *)
       content `Inner
    | assumps, _ ->
       H.vertical Html_static.(concat_map render_assumption assumps ^^ content `Inner)

  let render_solution t =
    let assumptions = PT.root_assumptions t in
    let goal = PT.root_goal t in
    H.vertical @| [
        prologue assumptions goal;
        PT.fold
          (fun _ hole _ -> Html_static.(div (text "{ command: " ^^ em (text hole.command) ^^ text " }")))
          (fun _pt rule children _ ->
            let children = List.map (fun c -> c `Inner) children in
            render_rule ~resetbutton:Html_static.empty ~rule ~children)
          render_box
          t
          `Top;
        epilogue goal
      ]

  open Hoare_calculus

  let rec extract_program = function
    | PT.Hole _ -> `Hole
    | PT.Rule (Program_rule End, _) ->
       `End
    | PT.Rule (Program_rule (Assign (var, term)), [cont]) ->
       `Assign (var, term, extract_program cont)
    | PT.Rule (Program_rule (Assert f), [_prf; cont]) ->
       `Assert (f, extract_program cont)
    | PT.Rule (Program_rule (If cond), [iftrue; iffalse; cont]) ->
       `If (cond, extract_program iftrue, extract_program iffalse, extract_program cont)
    | PT.Rule (Program_rule (While cond), [body; cont]) ->
       `While (cond, extract_program body, extract_program cont)
    | _ ->
       assert false

  let rec pretty_program =
    let open Pretty in
    function
    | `Hole -> text "???"
    | `End -> text "end"
    | `Assign (x, term, cont) ->
       text x ^^ text " := " ^^ Fol_formula.Term.to_doc_prec 100 term ^^ break ^^ pretty_program cont
    | `Assert (f, cont) ->
       text "assert (" ^^ Fol_formula.Formula.to_doc f ^^ text ")" ^^ break ^^ pretty_program cont
    | `If (cond, iftrue, iffalse, cont) ->
       text ("if (" ^ string_of_boolean_expr cond ^ ") {")
       ^^ nest 2 (break ^^ pretty_program iftrue)
       ^^ break ^^ text "} else {"
       ^^ nest 2 (break ^^ pretty_program iffalse)
       ^^ break ^^ text "}"
       ^^ break ^^ pretty_program cont
    | `While (cond, body, cont) ->
       text ("while (" ^ string_of_boolean_expr cond ^ ") {")
       ^^ nest 2 (break ^^ pretty_program body)
       ^^ break ^^ text "}"
       ^^ break ^^ pretty_program cont

  let qn ~marks:max config submitted =
    let open Hoare_calculus.Config_parser in
    let assumptions, goal = assumptions_and_goal config in
    let tree = PT.tree_of_sexp submitted in
    match PT.of_tree assumptions goal tree with
    | Error (`LengthMismatch (s, rule)) ->
        Error (`Msg (Printf.sprintf "Natural Deduction decode error: Length mismatch: %s on %s" s (Sexplib.Sexp.to_string rule)))
    | Error (`RuleError e) ->
        Error (`Msg (Printf.sprintf "Proof decode error: %s" e))
    | Ok state ->
       (let _name = config.name in
        let proof_tree = pretty_program (extract_program tree) in
        if num_holes state = 0 then
          Ok (max, proof_tree)
        else
          Ok (0, proof_tree))
end

let read_answers_file ~filename =
  In_channel.with_open_text filename
    (fun ch ->
      Seq.of_dispenser (fun () -> In_channel.input_line ch)
      |> Seq.map
           (fun line -> Scanf.sscanf line "%s@:%S" Tuple2.make)
      |> List.of_seq)

(******************************************************************************)
let qn2a =
  "2a",
  "cw2025-2a",
  Result.get_ok @@
  Natural_deduction.Focused_config.config_p @@ Sexplib.Sexp.of_string
{|(config
 (name "Question 2(a)")
 (assumptions
  (add-zero "∀x. add(x, 0) = x")
  (add-comm "∀x. ∀y. add(x, y) = add(y, x)")
  (add-assoc "∀x. ∀y. ∀z. add(x, add(y, z)) = add(add(x, y), z)"))
 (goal "∀x. ∃k. add(x, k) = x"))|}
let qn2b =
  "2b",
  "cw2025-2b",
  Result.get_ok @@
  Natural_deduction.Focused_config.config_p @@ Sexplib.Sexp.of_string
{|(config
 (name "Question 2(b)")
 (assumptions
  (add-zero "∀x. add(x, 0) = x")
  (add-comm "∀x. ∀y. add(x, y) = add(y, x)")
  (add-assoc "∀x. ∀y. ∀z. add(x, add(y, z)) = add(add(x, y), z)"))
                (goal "∀x. ∃k. add(0, k) = x"))|}
let qn2c =
  "2c",
  "cw2025-2c",
  Result.get_ok @@
  Natural_deduction.Focused_config.config_p @@ Sexplib.Sexp.of_string
{|(config
 (name "Question 2(c)")
 (assumptions
  (add-zero "∀x. add(x, 0) = x")
  (add-comm "∀x. ∀y. add(x, y) = add(y, x)")
  (add-assoc "∀x. ∀y. ∀z. add(x, add(y, z)) = add(add(x, y), z)"))
                (goal "∀x. ∀y. ∀z. (∃k. add(x, k) = y) → (∃k. add(y, k) = z) → (∃k. add(x, k) = z)"))|}

(******************************************************************************)
let qn3a =
  "3a",
  "cw2025-q3a",
  Result.get_ok @@
  Natural_deduction.Focused_config.config_p @@ Sexplib.Sexp.of_string
{|(config
 (name "Question 3(a): Consequence")
 (assumptions
  (pre "all s. P'(s) -> P(s)")
  (post "all s. Q(s) -> Q'(s)")
  (prog var)
  (prog-spec "all s1. all s2. P(s1) -> exec(prog, s1, s2) -> Q(s2)"))
 (goal "all s1. all s2. P'(s1) -> exec(prog, s1, s2) -> Q'(s2)"))
 |}

let qn3b =
  "3b",
  "cw2025-q3b",
  Result.get_ok @@
  Natural_deduction.Focused_config.config_p @@ Sexplib.Sexp.of_string
{|(config
 (name "Question (b): Doing Nothing")
 (assumptions
  (exec-skip "all s1. all s2. exec(skip(), s1, s2) -> s1 = s2"))
 (goal "all s1. all s2. P(s1) -> exec(skip(), s1, s2) -> P(s2)"))
 |}

let qn3c =
  "3c",
  "cw2025-q3c",
  Result.get_ok @@
  Natural_deduction.Focused_config.config_p @@ Sexplib.Sexp.of_string
{|(config
 (name "Question 3(c): Sequencing")
 (assumptions
  (exec-seq   "all p1. all p2. all s1. all s2. exec(seq(p1, p2), s1, s2) -> (ex s. exec(p1, s1, s) /\ exec(p2, s, s2))")
  (prog1 var)
  (prog2 var)
  (prog1-spec "all s1. all s2. P(s1) -> exec(prog1,s1,s2) -> R(s2)")
  (prog2-spec "all s1. all s2. R(s1) -> exec(prog2,s1,s2) -> Q(s2)")
 )
 (goal "all s1. all s2. P(s1) -> exec(seq(prog1, prog2), s1, s2) -> Q(s2)"))
 |}
let qn3d =
  "3d",
  "cw2025-q3d",
  Result.get_ok @@
  Natural_deduction.Focused_config.config_p @@ Sexplib.Sexp.of_string
{|(config
 (name "Question 3(d): Assignment (backward)")
 (assumptions
  (exec-update "all s1. all s2. exec(update(), s1, s2) -> s2 = doUpdate(s1)"))
 (goal "all s1. all s2. P(doUpdate(s1)) -> exec(update(), s1, s2) -> P(s2)"))
 |}

let qn3e =
  "3e",
  "cw2025-q3e",
  Result.get_ok @@
  Natural_deduction.Focused_config.config_p @@ Sexplib.Sexp.of_string
{|(config
 (name "Question 3(e): Assignment (forward)")
 (assumptions
  (exec-update "all s1. all s2. exec(update(), s1, s2) -> s2 = doUpdate(s1)"))
 (goal "all s1. all s2. P(s1) -> exec(update(), s1, s2) -> (ex oldstate. s2 = doUpdate(oldstate) /\ P(oldstate))"))
 |}

let qn3f =
  "3f",
  "cw2025-q3f",
  Result.get_ok @@
  Natural_deduction.Focused_config.config_p @@ Sexplib.Sexp.of_string
{|(config
 (name "Question 3(e): If-then-else")
 (assumptions
  (exec-if "all p1. all p2. all s1. all s2. exec(ifC(p1, p2), s1, s2) -> ((C(s1) /\ exec(p1,s1,s2)) \/ (!C(s1) /\ exec(p2,s1,s2)))")
  (prog1 var)
	(prog2 var)
  (prog1-spec "all s1. all s2. (C(s1) /\ P(s1)) -> exec(prog1, s1, s2) -> Q(s2)")
  (prog2-spec "all s1. all s2. (¬C(s1) /\ P(s1)) -> exec(prog2, s1, s2) -> Q(s2)"))
 (goal "all s1. all s2. P(s1) -> exec(ifC(prog1, prog2), s1, s2) -> Q(s2)"))
 |}

(******************************************************************************)
let qn4a =
  "4a",
  "cw2025-q4a",
  1,
  Result.get_ok @@
  Natural_deduction.Hoare_calculus.Config_parser.config_p @@ Sexplib.Sexp.of_string
{|(hoare
 (name "Question 4(a) : Add and Subtract")
 (program_vars X Y)
 (logic_vars x y)
 (assumptions
  (add-sub "all x. all y. sub(add(x,y),y) = x"))
 (precond "X = x /\ Y = y")
 (postcond "Y = x /\ X = add(x,y)"))|}

let qn4b =
  "4b",
  "cw2025-q4b",
  2,
  Result.get_ok @@
  Natural_deduction.Hoare_calculus.Config_parser.config_p @@ Sexplib.Sexp.of_string
{|(hoare
 (name "Question 4(b): XOR swap")
 (program_vars X Y)
 (logic_vars x y)
 (assumptions
   (xor-cancel "all x. all y. xor(xor(x,y),y) = x")
   (xor-comm "all x. all y. xor(x,y) = xor(y,x)"))
 (precond "X = x /\ Y = y")
 (postcond "X = y /\ Y = x"))
 |}

let qn4c =
  "4c",
  "cw2025-q4c",
  2,
  Result.get_ok @@
  Natural_deduction.Hoare_calculus.Config_parser.config_p @@ Sexplib.Sexp.of_string
{|(hoare
 (name "Question 4(c): Counting Zeros")
 (program_vars COUNT I LEN)
 (assumptions
  (count-zero "countTo(0) = 0")
  (count-yes  "all i. lookup(i) = 0 -> countTo(add(i,1)) = add(countTo(i),1)")
  (count-no   "all i. ¬lookup(i) = 0 -> countTo(add(i,1)) = countTo(i)"))
 (precond "T")
 (postcond "COUNT = countTo(LEN)"))|}

(******************************************************************************)

(* Generate a marking based on the answers given *)
let marking_sheet participant_id answers =
  let open Document in
  let from_answers fieldname = List.assoc fieldname answers in
  let sexp_from_answers fieldname =
    match Sexplib.Sexp.of_string (from_answers fieldname) with
    | exception _ -> None
    | sexp -> Some sexp
  in
  let proof_question (label, key, config) =
    match sexp_from_answers key with
    | None ->
       [ para [text "Question "; text label; text ": no answer"];
         para [textf "@Mark%s=0" label]
       ]
    | Some submission ->
       match Focused.qn ~marks:1 config submission with
       | Ok (0, _) ->
          [ para [text "Question "; text label; text ": incomplete proof"];
            para [textf "@Mark%s=0" label]
          ]
       | Ok (marks, _) ->
          [ para [text "Question "; text label; text ": complete proof"];
            para [textf "@Mark%s=%d" label marks]
          ]
       | Error (`Msg msg) ->
          [ para [text "Question "; text label; textf ": malformed proof: %s" msg];
            para [textf "@Mark%s=%d" label 0]
          ]
  in
  let hoare_question (label, key, marks, config) =
    match sexp_from_answers key with
    | None ->
       [ para [strong [text "Question "; text label]; text ": no answer"];
         para [textf "@Mark%s=0" label]
       ]
    | Some submission ->
       match Hoare_qn.qn ~marks config submission with
       | Ok (marks, program) ->
          [ para [ textf "Question %s" label];
            monospace program;
            para [ textf "@Mark%s=%d" label marks ]
          ]
       | Error (`Msg msg) ->
          [ para [ textf "Question %s" label];
            para [ textf "Problem: %s" msg];
            para [ textf "@Mark%s=%d" label 0 ]
          ]
  in
  document ~title:(Printf.sprintf "Participant %s" participant_id)
    ~sections:[
      section ~title:"Information"
        ~content:[
          para [text "Name: "; strong [text (from_answers "cw2025-name")]];
          para [text "RegNo: "; strong [text (from_answers "cw2025-regnum")]];
        ]
        ();

      (let open Fol_formula in
       let formula_answer key =
         let submitted = from_answers key in
         match Formula.of_string submitted with
         | Ok fmla -> monospace (Formula.to_doc fmla)
         | Error _ -> preformatted (submitted ^ " (PARSE FAIL)")
       in
       section ~title:"Logical Modelling"
         ~content:[
           para [text "(1) Every student is enrolled on some course."];
           formula_answer "cw2025-q1b";
           para [strong [text "Submitted comment: "]; text (from_answers "cw2025-q1b-comment")];

           para [text "(2) Every staff member is employed on some course"];
           formula_answer "cw2025-q1c";
           para [strong [text "Submitted comment: "]; text (from_answers "cw2025-q1c-comment")];

           para [text "(3) Every assessment is part of some course."];
           formula_answer "cw2025-q1d";
           para [strong [text "Submitted comment: "]; text (from_answers "cw2025-q1d-comment")];

           para [text "(4) No assessment is attached to multiple courses."];
           formula_answer "cw2025-q1e";
           para [strong [text "Submitted comment: "]; text (from_answers "cw2025-q1e-comment")];

           para [text "(5) Every attempt by a student is for an \
                       assessment on a course that the student is \
                       enrolled on."];
           formula_answer "cw2025-q1f";
           para [strong [text "Submitted comment: "]; text (from_answers "cw2025-q1f-comment")];

           para [text "(6) Every marked attempt is of an assessment \
                       that is attached to a course and is marked by a \
                       staff member for that course."];
           formula_answer "cw2025-q1g";
           para [strong [text "Submitted comment: "]; text (from_answers "cw2025-q1g-comment")];

           para [text "(7) There can only be one attempt by a student \
                       for a particular assessment."];
           formula_answer "cw2025-q1h";
           para [strong [text "Submitted comment: "]; text (from_answers "cw2025-q1h-comment")];

           para [text "@Mark1=?"];
         ]
         ());

      section
        ~title:"Proofs about Monoids"
        ~content:(
          proof_question qn2a
          @ proof_question qn2b
          @ proof_question qn2c;
        )
        ();

      section
        ~title:"Hoare Logic Soundness Proofs"
        ~content:(
          proof_question qn3a
          @ proof_question qn3b
          @ proof_question qn3c
          @ proof_question qn3d
          @ proof_question qn3e
          @ proof_question qn3f)
        ();

      section
        ~title:"Using Hoare Logic"
        ~content:(
          hoare_question qn4a
          @ hoare_question qn4b
          @ hoare_question qn4c)
        ()
    ]

  (* 4. Three questions using Hoare Logic
        - Automark, except ought to show the program given *)
  ()


(*
let marking_sheet participant_id answers coursework_spec =
  let module Custom = struct
      module Html = Html_static

      let raw_html _ = failwith "RAW HTML"

      let link_href s = s

      let img_href s = s

      open Result_ext.Syntax

      module Html_of_formula = Fol_formula.Formula.Make_HTML_Formatter (Html_static)

      let mark_confirm id options default =
        let options = String.concat " " (List.map string_of_int options) in
        let config =
          Printf.sprintf "(config (options (%s)) (default %d))" options default
        in
        let open Html_static in
        let attrs = [ raw_attr "data-widget" "selection"; raw_attr "data-key" id ] in
        div ~attrs (text config)

      let code ~self ~attributes ~kind content =
        Result.fold
          ~ok:Fun.id
          ~error:(fun (`Msg err) -> Html.p ~attrs:[ Html.A.class_ "errormsg" ] (Html.text err))
          (match kind, List.assoc_opt "id" attributes, List.assoc_opt "marks" attributes with
          | "focused-nd", Some id, Some marks ->
             let marking_id = participant_id ^ "-" ^ id in
             let* config = Result.map_error (fun _ -> `Msg "bad config")
                              (Natural_deduction.Focused_config.config_p (Sexplib.Sexp.of_string content)) in
             let* marks = Result_ext.of_option ~on_error:(`Msg "non-integer marks") (int_of_string_opt marks) in
             (match List.assoc_opt id answers with
             | None | Some "" ->
                Ok (Html.(text "<no submission>"
                          ^^ p (strong (text "Marks:") ^^ mark_confirm marking_id [0;1] 0)))
             | Some sexp_txt ->
                let answer = Sexplib.Sexp.of_string sexp_txt in
                let* given_marks, doc = Focused.qn ~marks config answer in
                Ok Html.(doc
                         ^^ p (strong (text "Marks:") ^^ mark_confirm marking_id [0;1] given_marks)))
          | "hoare", Some id, Some marks ->
             let marking_id = participant_id ^ "-" ^ id in
             let* config = Result.map_error (fun _ -> `Msg "bad config")
                             (Natural_deduction.Hoare_calculus.Config_parser.config_p
                                (Sexplib.Sexp.of_string content)) in
             let* marks = Result_ext.of_option ~on_error:(`Msg "non-integer marks") (int_of_string_opt marks) in
             let options = if marks = 2 then [0;1;2] else [0;1] in
             (match List.assoc_opt id answers with
             | Some "" | None ->
                Ok (Html.(text "<no submission>"
                    ^^ p (strong (text "Marks:") ^^ mark_confirm marking_id options 0)))
             | Some sexp_txt ->
                let answer = Sexplib.Sexp.of_string sexp_txt in
                let* given_marks, doc = Hoare_qn.qn ~marks config answer in
                Ok Html.(doc ^^ p (strong (text "Marks:") ^^ mark_confirm marking_id options given_marks)))
          | "formulaentry", Some id, None ->
             let marking_id = participant_id ^ "-" ^ id in
             (match List.assoc_opt id answers with
             | None ->
                Ok (Html.(em (text "<no answer>")
                          ^^ p (strong (text "Marks:") ^^ mark_confirm marking_id [0;1] 0)))
             | Some answer ->
                let open Fol_formula in
                (match Formula.of_string answer with
                | Ok fmla ->
                   Ok Html_static.(
                    p (strong (text "Submitted answer: ")
                         ^^ div ~attrs:[ A.class_ "displayedformula" ]
                              (Html_of_formula.html_of_formula fmla)
                         ^^ p (strong (text "Marks:") ^^ mark_confirm marking_id [0;1] 0)))
                | Error _ ->
                   Ok Html_static.(
                    p (strong (text "Submitted answer (did not parse as a formula): ")
                       ^^ text answer
                       ^^ p (strong (text "Marks:") ^^ mark_confirm marking_id [0;1] 0)))))
          | ("textbox" | "entrybox"), Some id, None ->
             (* Render the text as commentary *)
             (match List.assoc_opt id answers with
             | None ->
                Ok (Html.(p (em (text "<no answer>"))))
             | Some answer ->
                Ok (Html.(p (strong (text "Submitted answer: ") ^^ text answer))))
          | "download", _, _ ->
             Ok Html.empty
          | "formula", _, _ ->
             let open Fol_formula in
             (match Formula.of_string content with
             | Ok fmla ->
                let open Html_static in
                Ok (div ~attrs:[ A.class_ "displayedformula" ]
                      (Html_of_formula.html_of_formula fmla))
             | Error (`Parse err) ->
                (* FIXME: just log the error? *)
                failwith (Parser_util.Driver.string_of_error err))
          | "rules-display", _, _ ->
             let open Html_static in
             let attrs = [ raw_attr "data-widget" kind ] in
             Ok (div ~attrs (text content))
          | "", _, _ ->
             Ok (Html_static.(pre (code (text content))))
          | kind, _, _  ->
             failwith ("UNKNOWN CODE BLOCK: " ^ kind))
    end
  in
  let module Gen = Html_of_omd.Make (Html_static) (Custom) in
  Gen.of_doc coursework_spec

let ids =
  [ "cw2025-q1b", "1a", 1
  ; "cw2025-q1c", "1b", 1
  ; "cw2025-q1d", "1c", 1
  ; "cw2025-q1e", "1d", 1
  ; "cw2025-q1f", "1e", 1
  ; "cw2025-q1g", "1f", 1
  ; "cw2025-q1h", "1g", 1
  ; "cw2025-2a", "2a", 1
  ; "cw2025-2b", "2b", 1
  ; "cw2025-2c", "2c", 1
  ; "cw2025-q3a", "3a", 1
  ; "cw2025-q3b", "3b", 1
  ; "cw2025-q3c", "3c", 1
  ; "cw2025-q3d", "3d", 1
  ; "cw2025-q3e", "3e", 1
  ; "cw2025-q3f", "3f", 1
  ; "cw2025-q4a", "4a", 1
  ; "cw2025-q4b", "4b", 2
  ; "cw2025-q4c", "4c", 2
  ]

let template ~css ~title:title_text ?(sub_title="") body_html =
  let open Html_static in
  let (@|) elem elems = elem (concat_list elems) in
  html @| [
      head @| [
        meta ~attrs:[A.charset "utf8"];
        meta ~attrs:[
            A.name "viewport";
            A.content "width=device-width, initial-scale=1.0"
          ];
        style (text css);
        title title_text;
        script ~attrs:[A.src "../frontend.bc.js"; raw_attr "defer" "yes"] "";
      ];
      body @| [
          header @| [
            h1 (text title_text);
            p (text sub_title);
          ];
          main body_html;
          footer @| [
              text "Styling provided by ";
              a ~attrs:[A.href "https://simplecss.org/"]
                (text "SimpleCSS");
              text "."
            ]
        ]
    ]
 *)

let seq_head seq = match seq () with
  | Seq.Cons (x, _) -> x
  | Seq.Nil -> failwith "empty sequence"

let get_file_of_dir dirname =
  Sys.readdir dirname
  |> Array.to_seq
  |> Seq.filter (fun entry -> not (String.starts_with ~prefix:"." entry))
  |> seq_head

let get_partnum string =
  let idx = String.index string '_' in
  String.sub string (idx+1) 7

let do_submission css coursework_spec dirname outdir entry =
  let partnum = get_partnum entry in
  let entry_dir = Filename.concat dirname entry in
  let submission_filename = Filename.concat entry_dir (get_file_of_dir entry_dir) in
  try
    let answers = read_answers_file ~filename:submission_filename in
    let marking_sheet = Document.ToPretty.pretty_of_document (marking_sheet partnum answers) in
    (* let marking_sheet_html = *)
    (*   marking_sheet partnum answers coursework_spec *)
    (* in *)
    let name = List.assoc "cw2025-name" answers in
    let regnum = List.assoc "cw2025-regnum" answers in
    (*
    let given_marks, html_feedback =
      List.fold_left
        (fun (total_marks, html) { question_id; question_detail; question_marks } ->
          match List.assoc_opt question_id answers with
          | None ->
             Printf.eprintf "%s: missing\n" question_id;
             (total_marks, html)
          | Some answer ->
             (match question_detail with
             | Proof question_config ->
                (match check_proof question_config question_marks answer with
                | Error msg ->
                   Printf.eprintf "%s: %s: ERROR: %s\n" partnum question_id msg;
                   (total_marks, html)
                | Ok (given_marks, qn_html) ->
                   (total_marks+given_marks, Html_static.(^^) html qn_html))
             | Program question_config ->
                (match check_program question_config question_marks answer with
                | Error msg ->
                   Printf.eprintf "%s: %s: ERROR: %s\n" partnum question_id msg;
                   (total_marks, html)
                | Ok (given_marks, qn_html) ->
                   (total_marks+given_marks, Html_static.(^^) html qn_html))
             | Formula ->
                let doc = let open Html_static in
                          h2 (text question_id) ^^ p (text answer)
                in
                (total_marks, Html_static.(^^) html doc)
             | Comment ->
                let doc = let open Html_static in
                          h2 (text question_id) ^^ p (text answer)
                in
                (total_marks, Html_static.(^^) html doc)
        ))
        (0, Html_static.empty)
        questions
    in
    let html_feedback =
      let open Html_static in
      h1 (text (Printf.sprintf "Coursework (%d/20)" given_marks)) ^^ html_feedback
      in
     *)

    (* let doc = template ~css ~title:"Coursework" marking_sheet_html in *)
    let outdir = Filename.concat outdir entry in
    if not (Sys.file_exists outdir) then
      Sys.mkdir outdir 0o700;
    let outfile = Filename.concat outdir "marking-sheet.md" in
    Out_channel.with_open_text outfile
      (fun ch ->
        Pretty.output_to_channel ch ~width:100 marking_sheet);
        (* Html_static.Render.to_channel ~doctype:true ch doc); *)
    Printf.printf "%s,%s,Participant %s\n" regnum name partnum
  with exn ->
    Printf.eprintf "PROBLEM: %s: %s\n" partnum (Printexc.to_string exn)


let () =
  let css =
    In_channel.with_open_text "assets/simple.min.css" In_channel.input_all
    ^ In_channel.with_open_text "assets/local.css" In_channel.input_all
  in
  match Sys.argv with
  | [| _prog_name; question_spec_filename; marking_dir |] ->
     let questions = In_channel.with_open_bin question_spec_filename Omd.of_channel in
     let submission_dir = Filename.concat marking_dir "submissions" in
     let outdir         = Filename.concat marking_dir "premarked" in
     if not (Sys.file_exists outdir) then
       Sys.mkdir outdir 0o700;
     Sys.readdir submission_dir
     |> (fun a -> Array.sort String.compare a; a)
     |> Array.to_seq
     |> Seq.filter (fun entry -> not (String.starts_with ~prefix:"." entry))
     |> Seq.iter (do_submission css questions submission_dir outdir)
  | _ ->
     Printf.eprintf "Usage: %s <question-spec-file> <submission-file>\n" Sys.argv.(0);
     exit 1
