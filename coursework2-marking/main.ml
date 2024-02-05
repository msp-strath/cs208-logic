(*
  Plan:

  1. Load the coursework description to get all the questions' specifications.
     FIXME: annotate with mark value

  2. For each question, load from the submission and check the proof

  3. Render the proof into HTML document, with the mark total

  4. Output the marks and the html feedback in one go

 *)

let read_answers_file filename =
  In_channel.with_open_text filename
    (fun ch ->
      Seq.of_dispenser (fun () -> In_channel.input_line ch)
      |> Seq.map
           (fun line ->
             Scanf.sscanf line "%s@:%S" (fun fieldname data -> fieldname, data))
      |> List.of_seq)

let rec questions_of_block = function
  | Omd.Paragraph _
  | Omd.Heading _
  | Omd.Thematic_break _
  | Omd.Html_block _
  | Omd.Table _
  | Omd.Definition_list _ ->
     []
  | Omd.List (_, _, _, items) ->
     List.concat_map questions_of_blocks items
  | Omd.Blockquote (_, doc) ->
     questions_of_blocks doc
  | Omd.Code_block (attrs, kind, content) ->
     (match kind, List.assoc_opt "id" attrs, List.assoc_opt "marks" attrs with
      (* FIXME: have a central registry of question types, and their
         configurations *)
      | "focused-nd", Some id, Some marks ->
         (let sexp = Sexplib.Sexp.of_string content in
          match Natural_deduction.Focused_config.config_p sexp with
          | Ok config ->
             [ id, (config, int_of_string marks) ]
          | Error err ->
             let msg = Generalities.Annotated.detail err in
             failwith ("QUESTION FILE ERROR: " ^ msg))
      | _ ->
         [])
and questions_of_blocks doc =
  List.concat_map questions_of_block doc

let read_question_spec filename =
  let doc = In_channel.with_open_text filename Omd.of_channel in
  questions_of_blocks doc

module Focused = struct
  open Natural_deduction
  open Sexplib.Conv

  module Hole = struct
    type t = string * string option [@@deriving sexp]
    type goal = Focused.goal

    let empty _ = ("", None)
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
    | Error `LengthMismatch ->
        Error (`Msg "Natural Deduction decode error: Length mismatch")
    | Error (`RuleError e) ->
        Error (`Msg (Printf.sprintf "Natural Deduction decode error: %s" e))
    | Ok state ->
       (let name = config.name in
        let assumps_name = config.assumptions_name in
        let proof_tree = render ?name ?assumps_name state in
        if num_holes state = 0 then
          Ok (max, proof_tree)
        else
          Ok (0, proof_tree))
end


let check_proof (config, max_marks) str_proof =
  let open Natural_deduction.Focused_config in
  let wrap given_marks html_proof =
    let open Html_static in
    (given_marks,
     h2 (text (Printf.sprintf
                 "%s (%d/%d)"
                 (Option.value ~default:"" config.name)
                 given_marks
                 max_marks))
     ^^
       html_proof)
  in
  match str_proof with
  | "" ->
     Ok (wrap 0 (Html_static.text "Not attempted"))
  | str_proof ->
     let proof_tree = Sexplib.Sexp.of_string str_proof in
     match Focused.qn ~marks:max_marks config proof_tree with
     | Error (`Msg msg) ->
        Error msg
     | Ok (given_marks, html_proof) ->
        Ok (wrap given_marks html_proof)

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
        title title_text
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

let do_submission css questions dirname outdir entry =
  let partnum = get_partnum entry in
  let entry_dir = Filename.concat dirname entry in
  let submission_filename = Filename.concat entry_dir (get_file_of_dir entry_dir) in
  try
    let answers = read_answers_file submission_filename in
    let given_marks, html_feedback =
      List.fold_left
        (fun (total_marks, html) (question_id, question_config) ->
          match List.assoc_opt question_id answers with
          | None ->
             Printf.eprintf "%s: missing\n" question_id;
             (total_marks, html)
          | Some answer ->
             match check_proof question_config answer with
             | Error msg ->
                Printf.eprintf "%s: ERROR: %s\n" question_id msg;
                (total_marks, html)
             | Ok (given_marks, qn_html) ->
                (total_marks+given_marks, Html_static.(^^) html qn_html))
        (0, Html_static.empty)
        questions
    in
    let html_feedback =
      let open Html_static in
      h1 (text (Printf.sprintf "Coursework 2 (%d/20)" given_marks)) ^^ html_feedback
    in
    let doc = template ~css ~title:"Coursework 2 Results" html_feedback in
    let outdir = Filename.concat outdir entry in
    if not (Sys.file_exists outdir) then
      Sys.mkdir outdir 0o700;
    let outfile = Filename.concat outdir "feedback.html" in
    Out_channel.with_open_text outfile
      (fun ch -> Html_static.Render.to_channel ~doctype:true ch doc);
    Printf.printf "Participant %s,%d\n" partnum given_marks
  with exn ->
    Printf.eprintf "PROBLEM: %s: %s\n" partnum (Printexc.to_string exn)


let () =
  let css =
    In_channel.with_open_text "assets/simple.min.css" In_channel.input_all
    ^ In_channel.with_open_text "assets/local.css" In_channel.input_all
  in
  match Sys.argv with
  | [| _prog_name; question_spec_filename; marking_dir |] ->
     let questions = read_question_spec question_spec_filename in
     let submission_dir = Filename.concat marking_dir "submissions" in
     let outdir         = Filename.concat marking_dir "feedback" in
     if not (Sys.file_exists outdir) then
       Sys.mkdir outdir 0o700;
     Sys.readdir submission_dir
     |> Array.to_seq
     |> Seq.filter (fun entry -> not (String.starts_with ~prefix:"." entry))
     |> Seq.iter (do_submission css questions submission_dir outdir)
  | _ ->
     Printf.eprintf "Usage: %s <question-spec-file> <submission-file>\n" Sys.argv.(0);
     exit 1
