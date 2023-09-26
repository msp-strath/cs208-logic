open Sexplib0.Sexp_conv

module type CALCULUS = sig
  type goal [@@deriving sexp]

  include
    Proof_tree.CALCULUS
      with type goal := goal
       and type update = unit
       and type error = string

  type statement [@@deriving sexp]

  val assumption_of_statement : statement -> assumption
  val goal_of_statement : statement -> goal
end

module type DOCUMENT = sig
  type t [@@deriving sexp]
end

module Make (C : CALCULUS) (D : DOCUMENT) = struct
  type update = unit

  let empty_update = ()
  let update_goal () f = f
  let update_assumption () a = a

  type goal = Doc | CommentDoc | Proof_goal of C.goal [@@deriving sexp]
  type assumption = C.assumption

  type rule =
    | Comment
    | Text of D.t
    (* | Definition of string * term (* to be used for bits of code? *) *)
    | Axiom of string * C.statement
    | Theorem of string * C.statement
    | Proof_rule of C.rule
  [@@deriving sexp]

  type error = [ `Inner of C.error | `Outer of string ]

  let apply context rule goal =
    match (rule, goal) with
    | Comment, Doc -> Ok ([ ([], CommentDoc); ([], Doc) ], ())
    | Comment, _ -> Error (`Outer "Comment not applicable here")
    | Text str, CommentDoc -> Ok ([], ())
    | Text str, _ -> Error (`Outer "Text not applicable here")
    | Theorem (name, statement), Doc ->
        (* FIXME: check freshness of 'name' *)
        Ok
          ( [
              ([], Proof_goal (C.goal_of_statement statement));
              ([ (name, C.assumption_of_statement statement) ], Doc);
            ],
            () )
    | Axiom (name, statement), Doc ->
        Ok ([ ([ (name, C.assumption_of_statement statement) ], Doc) ], ())
    | (Theorem _ | Axiom _), _ ->
        Error (`Outer "Theorem and Axiom not applicable here")
    | Proof_rule rule, Proof_goal goal -> (
        match C.apply context rule goal with
        | Ok (subgoals, ()) ->
            let subgoals =
              List.map
                (fun (assumps, subgoal) -> (assumps, Proof_goal subgoal))
                subgoals
            in
            Ok (subgoals, ())
        | Error err -> Error (`Inner err))
    | Proof_rule _, _ -> Error (`Outer "Proof rules not applicable here")

  (* Rules:

       G |- CommentDoc  G |- Doc
     ---------------------------- Comment
               G |- Doc

       G |- Checking P   G, H:P |- Doc
     ---------------------------------- Lemma (H:P)
              G |- Doc

           G, x = t |- Doc
     ------------------------------ Definition (x=t)
              G |- Doc


     ------------------------------ Text (str)
             G |- CommentDoc


      Problem is that we can't edit the statements in previous parts of the document without removing everything after it.

      Need a way of allowing non-destructive invalidation of bits of proof

      And insertion of elements into the tree

      Also useful: a way of searching of models of previously stated axioms?

      Need an editor and proof representation that allows unchecked abstract syntax trees to be left in. And faulty proofs to remain.
  *)
end

module DocumentTree
    (Calculus : CALCULUS)
    (Document : DOCUMENT)
    (Hole : Proof_tree.HOLE with type goal = Make(Calculus)(Document).goal) =
struct
  module BC = Make (Calculus) (Document)
  module PT = Proof_tree.Make (BC) (Hole)

  (* Some derived rules *)

  (* Development updates (all admissible rules; can be implemented by rechecking parts of the tree)

     Deletion:
        G, B, G'  ==> G, G'   if nm(B) \not\in fv(G')

     Insertion:
        G, G' ==> G, B, G'    if nm(B) \not\in fv(G')

     Renaming:
        G, X:P:=p, G'  ==> G, Y:P:=p, G'[Y/X]   if Y \not\in fv(G')

     Reordering:
        G, B1, B2, G'   ==>  G, B2, B1, G'   if bindings(B2) `intersect` bindings(B1) = {}
  *)

  let move_down pt =
    let match_item = function
      | PT.Rule ((BC.Comment as rule), [ p; rest ]) ->
          Some ((fun rest -> PT.Rule (rule, [ p; rest ])), rest)
      | PT.Rule ((BC.Theorem _ as rule), [ p; rest ]) ->
          Some ((fun rest -> PT.Rule (rule, [ p; rest ])), rest)
      | PT.Rule ((BC.Axiom _ as rule), [ rest ]) ->
          Some ((fun rest -> PT.Rule (rule, [ rest ])), rest)
      | _ -> None
    in
    match match_item (PT.subtree_of_point pt) with
    | Some (rule1, rest) -> (
        match match_item rest with
        | Some (rule2, rest) -> PT.insert_tree (rule2 (rule1 rest)) pt
        | None -> Error `CannotSwap)
    | None -> Error `CannotSwap

  (* FIXME: need to know more about the holes here
     let insert_comment pt =
       let t = PT.subtree_of_point pt in
       PT.insert_tree (PT.Rule (BC.Comment, [PT.Hole (CommentEntry ""); t])) pt
  *)
  let delete_block pt =
    match PT.subtree_of_point pt with
    | PT.Rule ((BC.Comment | BC.Theorem _), [ _; rest ]) ->
        PT.insert_tree rest pt
    | PT.Rule (BC.Axiom _, [ rest ]) -> PT.insert_tree rest pt
    | _ -> Error `CannotDelete

  let rename_theorem new_name pt =
    match PT.subtree_of_point pt with
    | PT.Rule (BC.Theorem (_old_name, statement), [ proof; rest ]) ->
        (* FIXME: this really ought to rename old_name -> new_name everywhere in rest *)
        PT.insert_tree
          (PT.Rule (BC.Theorem (new_name, statement), [ proof; rest ]))
          pt
    | _ -> Error `CannotRename
end

module type R = sig
  module Calculus : CALCULUS

  val rule_of_string : string -> (Calculus.rule, string) result
  val statement_of_string : string -> (Calculus.statement, string) result
  val string_of_statement : Calculus.statement -> string

  val render_hole :
    goal:Calculus.goal ->
    command_txt:string ->
    msg:string option ->
    update:(string -> 'action) ->
    submit:(string -> 'action) ->
    'action Ulmus.html

  val render_assumption : string * Calculus.assumption -> _ Ulmus.html

  val render_rule :
    resetbutton:'action Ulmus.html ->
    rule:Calculus.rule ->
    children:'action Ulmus.html list ->
    'action Ulmus.html
end

module type DOCUMENT2 = sig
  include DOCUMENT

  val of_string : string -> t
  val to_text : t -> string
  val to_html : t -> _ Ulmus.html
end

module UI
    (Calculus : CALCULUS)
    (Document : DOCUMENT2)
    (R : R with module Calculus = Calculus) =
struct
  module BC = Make (Calculus) (Document)

  module Hole = struct
    type goal = BC.goal

    type t =
      | TextCmd of { command_txt : string; msg : string option }
      | CommentEntry of string
      | DocExtn
      | NewTheorem of { name : string; statement : string }
    [@@deriving sexp]

    let empty = function
      | BC.Doc -> DocExtn
      | BC.CommentDoc -> CommentEntry ""
      | BC.Proof_goal _ -> TextCmd { command_txt = ""; msg = None }
  end

  module T = DocumentTree (Calculus) (Document) (Hole)
  module PT = T.PT

  type state = PT.t

  (* FIXME: rendering to Markdown:
     - A document will be sequence of blocks, either commentary or theorems
     -
  *)

  type action =
    | Update of PT.point * Hole.t
    | InsertComment of PT.point
    | SaveText of PT.point * string
    | InsertTheorem of PT.point * string * string * [ `Axiom | `Theorem ]
    | SendCommand of PT.point * string
    | MoveDown of PT.point
    | Delete of PT.point
    | ResetTo of PT.point

  let update action prooftree =
    match action with
    | Update (pt, hole) -> PT.set_hole hole pt
    | InsertComment pt -> (
        match PT.apply Comment pt with
        | Ok prooftree -> prooftree
        | Error msg -> prooftree (* FIXME: generic response mechanism *))
    | SaveText (pt, text) -> (
        (* FIXME: error feedback *)
        let doc = Document.of_string text in
        match PT.apply (Text doc) pt with
        | Ok prooftree -> prooftree
        | Error msg -> prooftree)
    | InsertTheorem (pt, name, statement, `Theorem) -> (
        (* FIXME: error feedback *)
        match R.statement_of_string statement with
        | Ok statement -> (
            match PT.apply (Theorem (name, statement)) pt with
            | Ok prooftree -> prooftree
            | Error msg -> prooftree)
        | Error msg -> prooftree)
    | InsertTheorem (pt, name, statement, `Axiom) -> (
        (* FIXME: error feedback *)
        match R.statement_of_string statement with
        | Ok statement -> (
            match PT.apply (Axiom (name, statement)) pt with
            | Ok prooftree -> prooftree
            | Error msg -> prooftree)
        | Error msg -> prooftree)
    | SendCommand (pt, command_txt) -> (
        match R.rule_of_string command_txt with
        | Ok rule -> (
            match PT.apply (Proof_rule rule) pt with
            | Ok prooftree -> prooftree
            | Error (`RuleError (`Inner msg)) | Error (`RuleError (`Outer msg))
              ->
                PT.set_hole (TextCmd { command_txt; msg = Some msg }) pt)
        | Error msg -> PT.set_hole (TextCmd { command_txt; msg = Some msg }) pt)
    | ResetTo pt -> PT.set_hole (Hole.empty (PT.goal pt)) pt
    | MoveDown pt -> (
        match T.move_down pt with
        | Ok prooftree -> prooftree
        | Error _ -> prooftree (* FIXME: display an error? *))
    | Delete pt -> (
        match T.delete_block pt with
        | Ok prooftree -> prooftree
        | Error _ -> prooftree (* FIXME: display an error? *))

  module H = Focused_proof_renderer.HTML_Bits (Ulmus.Html)

  let render_hole pt _focus hole =
    let open Ulmus.Html in
    match (PT.goal pt, hole) with
    | Doc, Hole.DocExtn ->
        ( div
            [%concat
              button ~attrs:[ E.onclick (InsertComment pt) ] (text "Add text");
              button
                ~attrs:
                  [
                    E.onclick
                      (Update (pt, Hole.NewTheorem { name = ""; statement = "" }));
                  ]
                (text "Add theorem")],
          `Document )
    | Doc, Hole.NewTheorem { name; statement } ->
        ( div
            [%concat
              text "Theorem ";
              input
                ~attrs:
                  [
                    A.value name;
                    A.placeholder "<name>";
                    E.oninput (fun value ->
                        Update (pt, Hole.NewTheorem { name = value; statement }));
                  ];
              text " : ";
              input
                ~attrs:
                  [
                    A.value statement;
                    A.placeholder "<statement>";
                    E.oninput (fun value ->
                        Update (pt, Hole.NewTheorem { name; statement = value }));
                  ];
              button
                ~attrs:
                  [ E.onclick (InsertTheorem (pt, name, statement, `Theorem)) ]
                (text "Add");
              button
                ~attrs:
                  [ E.onclick (InsertTheorem (pt, name, statement, `Axiom)) ]
                (text "Add as axiom");
              button
                ~attrs:[ E.onclick (Update (pt, Hole.DocExtn)) ]
                (text "Cancel")],
          `Document )
    | CommentDoc, Hole.CommentEntry comment ->
        ( [%concat
            (*
        button ~attrs:[ A.class_ "resetbutton"
                      ; E.onclick (SaveText (pt, comment)) ]
          (text "save");
*)
            H.vertical
              [%concat
                let rows =
                  let rec count_newlines n i =
                    if i = String.length comment then n
                    else
                      let n = if comment.[i] = '\n' then n + 1 else n in
                      count_newlines n (i + 1)
                  in
                  count_newlines 0 0
                in
                textarea
                  ~attrs:
                    [
                      E.oninput (fun value ->
                          Update (pt, Hole.CommentEntry value));
                      E.onkeydown (fun mods key ->
                          if
                            key = Js_of_ocaml.Dom_html.Keyboard_code.Enter
                            && mods.ctrl
                          then Some (SaveText (pt, comment))
                          else None);
                      A.rows (max 5 (rows + 1));
                    ]
                  comment]],
          `Document )
    | Proof_goal goal, Hole.TextCmd { command_txt; msg } ->
        ( R.render_hole ~goal ~command_txt ~msg
            ~update:(fun command_txt ->
              Update (pt, Hole.TextCmd { command_txt; msg }))
            ~submit:(fun value -> SendCommand (pt, value)),
          `Proof )
    | _ -> (strong (text "INTERNAL ERROR"), `Document)

  let render_rule point rule children =
    let open Ulmus.Html in
    let block_actions =
      [%concat
        button
          ~attrs:[ A.class_ "resetbutton"; E.onclick (Delete point) ]
          (text "delete");
        button
          ~attrs:[ A.class_ "resetbutton"; E.onclick (MoveDown point) ]
          (text "↓ move down");
        match PT.up point with
        | None -> empty
        | Some parent_point ->
            button
              ~attrs:
                [ A.class_ "resetbutton"; E.onclick (MoveDown parent_point) ]
              (text "↓ move up")]
    in
    match (rule, children) with
    | BC.Comment, [ comment; doc ] ->
        ( H.vertical
            [%concat
              div
                ~attrs:[ A.class_ "docblock" ]
                [%concat
                  block_actions;
                  comment];
              doc],
          `Document )
    | BC.Text commentary, [] ->
        ( [%concat
            (*
        button ~attrs:[ A.class_ "resetbutton"
                      ; E.onclick (Update (point, Hole.CommentEntry (Document.to_text commentary))) ]
          (text "edit");
        br (); *)
            div
              ~attrs:
                [
                  E.ondoubleclick
                    (Update
                       (point, Hole.CommentEntry (Document.to_text commentary)));
                ]
              (Document.to_html commentary)],
          `Document )
    | BC.Theorem (name, statement), [ proof; doc ] ->
        ( H.vertical
            [%concat
              div
                ~attrs:[ A.class_ "docblock" ]
                [%concat
                  div
                    [%concat
                      block_actions;
                      div
                        [%concat
                          strong (text "Theorem ");
                          em (text name);
                          strong (text " : ");
                          text (R.string_of_statement statement)]];
                  div (strong (text "Proof"));
                  H.indent_box proof;
                  div (strong (text "End of Proof."))
                  (* FIXME: count the number of open holes *)];
              doc],
          `Document )
    | BC.Axiom (name, statement), [ doc ] ->
        ( H.vertical
            [%concat
              div
                ~attrs:[ A.class_ "docblock" ]
                [%concat
                  block_actions;
                  div
                    [%concat
                      strong (text "Axiom ");
                      em (text name);
                      strong (text " : ");
                      text (R.string_of_statement statement)]];
              doc],
          `Document )
    | BC.Proof_rule rule, children ->
        (* FIXME: allow for different proof renderers *)
        let resetbutton =
          button
            ~attrs:[ E.onclick (ResetTo point); A.class_ "resetbutton" ]
            (text "reset")
        in
        (R.render_rule ~resetbutton ~rule ~children, `Proof)
    | _ ->
        (* FIXME: render something *)
        failwith "misshapen proof tree"

  let render_box assumps (content, kind) =
    match kind with
    | `Proof -> (
        let open Ulmus.Html in
        match assumps with
        | [] -> content
        | assumps ->
            H.vertical
              [%concat
                concat_map (fun (x, _) -> R.render_assumption x) assumps;
                (* FIXME: put the goal here? *)
                content])
    | `Document -> content

  let render = PT.fold render_hole render_rule render_box
  let to_tree = PT.to_tree
end

(* # This is a document

   ## This is a section

   ```
   Theorem thm1 : all x. x = x
   introduce x; reflexivity
   ```

   ## A proof using stuff

   ```
   Theorem thm2 : ((A -> B) \/ (A -> C)) -> A -> (B \/ C)
   introduce p a;
   use p; cases {
     left p: left; use p; apply (use a; done); done
     right p: right; use p; apply (use a; done); done
   }
   ```
*)
