open Generalities
open Result_ext.Syntax

let read_answers_file filename =
  try
    In_channel.with_open_text filename
      (fun ch ->
        Seq.of_dispenser (fun () -> In_channel.input_line ch)
        |> Seq.map
             (fun line ->
               Scanf.sscanf line "%s@:%S" (fun fieldname data -> fieldname, data))
        |> List.of_seq
        |> Result.ok)
  with
  | exn ->
     Error (Printf.sprintf "Read failure: %s" (Printexc.to_string exn))

let parse_and_typecheck string =
  let open Slakemoth in
  let* decls    = Reader.parse string in
  let* commands = Type_checker.check_declarations decls in
  Ok commands

let document_of_mismatch = let open Document in function
  | `Additional_atom name ->
     [para [textf "Additional defined atom '%s' in submitted script." name]]
  | `Atom_different_parameter_domains name ->
     [para [textf
       "The atom '%s' is declared with different parameter domains in \
        the submitted script."
       name]]
  | `Atom_missing name ->
     [para [textf "The atom '%s' is missing in the submitted script." name]]
  | `Domain_different_constructors name ->
     [para [textf
       "The domain '%s' has different constructors in the submitted script."
       name]]
  | `Domain_missing name ->
     [para [textf
       "The domain '%s' is missing in the submitted script."
       name]]
  | `Expecting_an_atom name ->
     [ para [ textf
       "The definition '%s' is not an atom in the submitted script."
       name]]
  | `Expecting_definition name ->
     [ para [ textf
       "Expecting a definition '%s' in the submitted script, but it \
        was either not present or was an atom or table."
       name ] ]
  | `Non_clause_definition name ->
     [ para [ textf
       "Definition '%s' is present in the submitted script, but is not \
        of the correct type."
       name
         ]
     ]
  | `Parse err ->
     [
       para [
           textf "I was unable to parse your submission: %s"
             (Parser_util.Driver.string_of_error_with_location err)
         ]
     ]
  | `Type_error (_loc, msg) ->
     [para [textf "There was an error trying to interpret your \
                   submission: %s" msg]
     ]

let basic_env =
  let open Slakemoth in
  Environment.
  { initial_global_env
  with defns = Ast.NameMap.singleton "fill_this_in"
                 (Defined { args = []
                          ; body = { detail = Ast.False
                                   ; location = Parser_util.Location.generated }
                          ; kind = Kinding.Constant })
  }

type selector =
  | OneCommand
  | Definition of string

type check =
  | And of check * check
  | GivenImpliesSpec
  | SpecImpliesGiven

type criteria =
  { name        : string
  ; marks_value : int
  ; selector    : selector
  ; specimen    : string
  ; json        : string
  ; checks      : check
  }

type expected_context =
  { domains : (string * string list) list
  (* ; tables  : (string * string list * string list list) list *)
  ; atoms   : (string * string list) list
  }

type question =
  { question_id    : string
  ; question_title : string
  ; description    : string option
  ; total_value    : int
  ; expected       : expected_context
  ; criteria       : criteria list
  }

let question1a =
  { question_id    = "cw1-2024-question1a"
  ; question_title = "Question 1(a)"
  ; description = None
  ; total_value    = 1
  ; expected       = { domains = []
                     (* ; tables  = [] *)
                     ; atoms   = [ "w", []; "x", []; "y", []; "z", [] ]
                     }
  ; criteria =
      [ { name        = "The specification is that at least one atom \
                         should be true."
        ; marks_value = 1
        ; selector    = OneCommand
        ; specimen    = "w | x | y | z"
        ; json        = {|{ "w": w, "x": x, "y": y, "z": z }|}
        ; checks      = And (GivenImpliesSpec, SpecImpliesGiven)
        }
      ]
  }

let question1b =
  { question_id    = "cw1-2024-question1b"
  ; question_title = "Question 1(b)"
  ; description = None
  ; total_value    = 1
  ; expected       = { domains = []
                     (* ; tables  = [] *)
                     ; atoms   = [ "w", []; "x", []; "y", []; "z", [] ]
                     }
  ; criteria =
      [ { name        = "The specification is that exactly one atom \
                         should be true."
        ; marks_value = 1
        ; selector    = OneCommand
        ; specimen    = "(w | x | y | z) & (~w | ~x) & (~w | ~y) & (~w | ~z) & (~x | ~y) & (~x | ~z) & (~y | ~z)"
        ; json        = {|{ "w": w, "x": x, "y": y, "z": z }|}
        ; checks      = And (GivenImpliesSpec, SpecImpliesGiven)
        }
      ]
  }

let question1c =
  { question_id    = "cw1-2024-question1c"
  ; question_title = "Question 1(c)"
  ; description = None
  ; total_value    = 2
  ; expected       = { domains = []
                     (* ; tables  = [] *)
                     ; atoms   = [ "x", []; "y", []; "z", [] ]
                     }
  ; criteria =
      [ { name        = "The specification is that exactly two atoms \
                         should be true."
        ; marks_value = 2
        ; selector    = OneCommand
        ; specimen    = "(x | y | z) & (~x | y | z) & (~y | x | z) & (~z | x | y) & (~x | ~y | ~z)"
        ; json        = {|{ "x": x, "y": y, "z": z }|}
        ; checks      = And (GivenImpliesSpec, SpecImpliesGiven)
        }
      ]
  }

let question2 =
  { question_id = "cw1-2024-question2"
  ; question_title = "Question 2 : Register Allocation"
  ; description = Some "Each of the criteria of the question are listed below, with the total marks given capped at 5."
  ; total_value = 5
  ; expected = { domains =
                   [ "variable", [ "X"; "Y"; "Z"; "W"; "U"; "V" ]
                   ; "register", [ "R1"; "R2"; "R3" ]
                   ]
               ; atoms =
                   [ "allocated", [ "variable"; "register" ]
                   ]
               }
  ; criteria =
      let json = "{ for (v : variable) v : [ for (r : register) if (allocated(v, r)) r ] }" in
      let sep_term =
        Printf.sprintf "forall (r : register)
                        ~allocated(%s, r) | ~allocated(%s, r)"
      in
      let separate x y =
        { name = Printf.sprintf "Constraint: %s and %s are not in the same register." x y
        ; marks_value = 1
        ; selector = OneCommand
        ; specimen = sep_term x y
        ; json = Printf.sprintf "{ %s : [ for (r : register) if (allocated(%s, r)) r ]
                                 , %s : [ for (r : register) if (allocated(%s, r)) r ] }" x x y y
        ; checks = GivenImpliesSpec
        }
      in
      [
        { name = "Constraint: All variables are allocated a register"
        ; marks_value = 1
        ; selector = OneCommand
        ; specimen = "forall (v : variable) some (r : register) allocated(v, r)"
        ; json
        ; checks = GivenImpliesSpec
        }
      ; { name = "Constraint: All variables are in at most one \
                  register. This was not in the original \
                  specification, but some people included is anyway."
        ; marks_value = 1
        ; selector = OneCommand
        ; specimen = {|  forall (v : variable)
                      forall (r1 : register)
                      forall (r2 : register)
                      (r1 = r2 | ~allocated(v,r1) | ~allocated(v,r2))
                      |}
        ; json
        ; checks = GivenImpliesSpec
        }
      ; separate "X" "Y"
      ; separate "X" "W"
      ; separate "X" "U"
      ; separate "X" "Z"
      ; separate "Z" "W"
      ;
      ]
  }

let question3 =
  { question_id = "cw1-2024-question3"
  ; question_title = "Question 3 : Robot World"
  ; description = Some "The individual constraints are given one mark each."
  ; total_value = 5
  ; expected = { domains =
                   [ "location", [ "Store"; "Factory"; "LoadingBay" ]
                   ; "object",   [ "Putty"; "Widget" ]
                   ];
                 atoms = [ "robotIn", [ "location" ]
                         ; "objectIn", [ "location"; "object" ]
                         ; "robotHolding", [ "object" ]
                         ]
               }
  ; criteria =
      [ { name = "Specification: the robot is somewhere"
        ; marks_value = 1
        ; selector = Definition "robot_is_somewhere"
        ; specimen = "some (l : location) robotIn(l)"
        ; json = {|{ "robotIn": [ for (l : location) if (robotIn(l)) l ] }|}
        ; checks = And (GivenImpliesSpec, SpecImpliesGiven)
        }
      ; { name = "Specification: the robot is never in multiple places"
        ; marks_value = 1
        ; selector = Definition "robot_never_in_multiple_places"
        ; specimen =
            "forall (l1 : location) forall (l2 : location) l1 = l2 | ~robotIn(l1) | ~robotIn(l2)"
        ; json = {|{ "robotIn": [ for (l : location) if (robotIn(l)) l ] }|}
        ; checks = And (GivenImpliesSpec, SpecImpliesGiven)
        }
      ; { name = "Specification: every object is somewhere"
        ; marks_value = 1
        ; selector = Definition "every_object_is_somewhere"
        ; specimen = "forall (o : object) \
                        robotHolding(o) | (some (l : location) objectIn(l, o))"
        ; json = {|{    "objectIn":
       { for (obj : object)
           obj : [ for (l : location)
             if(objectIn(l, obj)) l ] },
    "robotHolding":
       [ for (o : object)
       if (robotHolding(o)) o ]
                  }|}
        ; checks = And (GivenImpliesSpec, SpecImpliesGiven)
        }
      ; { name = "Constraint: objects are never in multiple places"
        ; marks_value = 1
        ; selector = Definition "objects_never_in_multiple_places"
        ; specimen = {|  forall (o : object)
    forall (l1 : location)
      forall (l2 : location)
        l1 = l2 | ~objectIn(l1, o) | ~objectIn(l2, o)|}
        ; json = {|{    "objectIn":
       { for (obj : object)
           obj : [ for (l : location)
                  if(objectIn(l, obj)) l ] } }|}
        ; checks = And (GivenImpliesSpec, SpecImpliesGiven)
        }
      ; { name = "Constraint: objects are never with the robot and in a location"
        ; marks_value = 1
        ; selector = Definition "objects_never_held_and_not_held"
        ; specimen = {|  forall (o : object)
    forall (l : location)
      ~robotHolding(o) | ~objectIn(l, o)
                      |}
        ; json = {|{    "objectIn":
       { for (obj : object)
           obj : [ for (l : location)
             if(objectIn(l, obj)) l ] },
    "robotHolding":
       [ for (o : object)
       if (robotHolding(o)) o ]
                  }|}
        ; checks = And (GivenImpliesSpec, SpecImpliesGiven)
        }
      ]
  }

let question4 =
  { question_id = "cw1-2024-question4"
  ; question_title = "Question 4 : Finding Paths"
  ; description = Some "The individual constraints are given one mark each."
  ; total_value = 6
  ; expected = { domains =
                   [ "location", [ "Store"; "Factory"; "LoadingBay";
                                   "Road"; "Yard"; "WasteHeap" ]
                   ; "timestep", [ "T1"; "T2"; "T3"; "T4"; "T5"; "Tend" ]
                   ];
                 atoms = [ "robotIn", [ "timestep"; "location" ]
                         ]
               }
  ; criteria =
      let json = {|[ for (t : timestep) [for (loc : location) if (robotIn(t, loc)) loc ] ]|} in
      [
        { name = "Constraint: The robot is always somewhere"
        ; marks_value = 1
        ; selector = Definition "always_somewhere"
        ; specimen = "forall (t : timestep) some (l : location) robotIn(t, l)"
        ; json
        ; checks = And (GivenImpliesSpec, SpecImpliesGiven)
        }
      ; { name = "Constraint: The robot is never in more than one place"
        ; marks_value = 1
        ; selector = Definition "never_in_more_than_one_place"
        ; specimen = {|forall (t : timestep)
    forall (l1 : location)
      forall (l2 : location)
        l1 = l2 | ~robotIn(t, l1) | ~robotIn(t, l2)
                      |}
        ; json
        ; checks = And (GivenImpliesSpec, SpecImpliesGiven)
        }
      ; { name = "Constraint: sequential timesteps' locations are linked in the map."
        ; marks_value = 1
        ; selector = Definition "good_steps"
        ; specimen = {|
  forall (t1 : timestep)
    forall (t2 : timestep)
      forall (src : location)
        forall (tgt : location)
           ~next(t1, t2)
         | ~robotIn(t1, src)
         | ~robotIn(t2, tgt)
         | linked(src,tgt)
                      |}
        ; json
        ; checks = And (GivenImpliesSpec, SpecImpliesGiven)
        }
      ; { name = "Constraint: the robot is initially in the store."
        ; marks_value = 1
        ; selector = Definition "initialState"
        ; specimen = "robotIn(T1, Store)"
        ; json
        ; checks = And (GivenImpliesSpec, SpecImpliesGiven)
        }
      ; { name = "Constraint: The robot is on the Road at 'Tend'."
        ; marks_value = 1
        ; selector = Definition "targetState"
        ; specimen = "robotIn(Tend, Road)"
        ; json
        ; checks = And (GivenImpliesSpec, SpecImpliesGiven)
        }
      ; { name = "Constraint: The robot never visits the same place twice."
        ; marks_value = 1
        ; selector = Definition "never_visit_same_place_twice"
        ; specimen = "forall (t1 : timestep)
    forall (t2 : timestep)
      forall (l : location)
        t1 = t2 | ~robotIn(t1, l) | ~robotIn(t2, l)"
        ; json
        ; checks = And (GivenImpliesSpec, SpecImpliesGiven)
        }
      ]
  }



let questions =
  [ question1a;
    question1b;
    question1c;
    question2;
    question3;
    question4
  ]



let sprintf = Printf.sprintf

let select_defn commands env =
  let open Slakemoth in
  let open Slakemoth.Environment in
  function
  | OneCommand ->
     (match commands with
      | [ AllSat (_, term, _) | IfSat (_, term, _) ] ->
         Ok term
      | _ ->
         Error `Missing_command)
  | Definition name ->
     (match Ast.NameMap.find_opt name env.defns with
      | Some (Defined { args = []; body; kind = _ }) ->
         Ok body
      | Some (Defined _ | Table _ | Atom _) ->
         Error (`Definition_not_as_expected name)
      | None ->
         Error (`Definition_missing name))


let check_criteria commands env { name; marks_value; selector; specimen; json; checks } =
  let specimen_tm = Result.get_ok (Slakemoth.Reader.parse_term specimen) in
  let json = Result.get_ok (Slakemoth.Reader.parse_term json) in
  match select_defn commands env selector with
  | Error `Missing_command ->
     name, 0,
     Document.[ para [ text "Expected exactly one 'ifsat' or 'allsat'." ] ]
  | Error (`Definition_not_as_expected defn_name) ->
     name, 0,
     Document.[
         para [
             textf "Expecting a definition of %s with no arguments, \
                    but the definition in the submission was different."
               defn_name
           ]
     ]
  | Error (`Definition_missing defn_name) ->
     name, 0,
     Document.[
         para [
             textf "Expecting a definition of %s, but there was no \
                    such definition in the submission."
               defn_name
           ]
     ]
  | Ok submitted ->
     let rec check = function
       | And (phi1, phi2) ->
          let ok1, message1 = check phi1 in
          let ok2, message2 = check phi2 in
          ok1 && ok2,
          message1 @ message2
       | GivenImpliesSpec ->
          (match Slakemoth.Compare.implies env submitted specimen_tm json with
           | `Contained ->
              true,
              Document.[ para [ text "The solutions generated by your \
                                      solution are included in the \
                                      specification." ] ]
           | `Extra json ->
              false,
              Document.[ para [ text "Your submission does not satisfy \
                                      this part of the \
                                      specification. It allows the \
                                      extra solution:" ];
                                monospace (Json.to_document json)])
       | SpecImpliesGiven ->
          (match Slakemoth.Compare.implies env specimen_tm submitted json with
           | `Contained ->
              true, Document.[ para [ text "Every solution from the \
                                            specification is contained \
                                            within your submission." ] ]
           | `Extra json ->
              false, Document.[ para [ text "The specification says \
                                             that the following \
                                             solution ought to be \
                                             allowed, but it is not \
                                             allowed by your \
                                             definition." ];
                                monospace (Json.to_document json)])
     in
     let ok, feedback = check checks in
     name, (if ok then marks_value else 0),
     feedback @ Document.[ (if ok then
                              para [ textf "%d mark%s given" marks_value
                                       (if marks_value = 1 then "" else "s") ]
                            else
                              para [ textf "No marks given" ]);
                           para [ text "The specimen solution is:" ];
                           preformatted specimen
                ]

open Slakemoth

let check_domain (env : Environment.environment) (name, expected_constructors) =
  let open Environment in
  let open Ast in
  match NameMap.find_opt name env.domains with
  | None ->
     Error (`Domain_missing name)
  | Some { constructors } ->
     let expected_constructors = List.sort String.compare expected_constructors in
     let constructors          = List.sort String.compare constructors in
     if List.equal String.equal expected_constructors constructors then
       Ok ()
     else
       Error (`Domain_different_constructors name)

let check_atom env (name, expected_domains) =
  let open Environment in
  let open Ast in
  match NameMap.find_opt name env.defns with
  | None ->
     Error (`Atom_missing name)
  | Some (Defined _ | Table _) ->
     Error (`Expecting_an_atom name)
  | Some (Atom { args }) ->
     if List.length args = List.length expected_domains &&
          List.for_all2 (fun domain (_, domain') -> String.equal domain domain')
            expected_domains
            args
     then
       Ok ()
     else
       Error (`Atom_different_parameter_domains name)

let check_atom_expected expected_atoms = function
  | (_, (Environment.Defined _ | Table _)) ->
     Ok ()
  | (name, Atom _) ->
     match List.assoc_opt name expected_atoms with
     | None ->
        Error (`Additional_atom name)
     | Some _ ->
        Ok ()


let mark_question submission q =
  match List.assoc_opt q.question_id submission with
  | None | Some "" ->
     0, q.total_value,
     Document.[ para [ text "Nothing submitted!" ] ]
  | Some submission ->
     let result =
       let open Slakemoth in
       let* parsed = Reader.parse submission
       in
       let* env, commands =
         Type_checker.check_declarations_open basic_env parsed
       in
       let* () =
         Result_ext.traverse_ (check_domain env) q.expected.domains
       in
       let* () =
         Result_ext.traverse_ (check_atom env) q.expected.atoms
       in
       let* () =
         Result_ext.traverse_ (check_atom_expected q.expected.atoms)
           (Ast.NameMap.bindings env.defns)
       in
       let results =
         List.map (check_criteria commands env) q.criteria
       in
       Ok results
     in
     (match result with
      | Error problem ->
         0, q.total_value,
         Document.[
             para [ text "Your submission:" ];
             preformatted submission;
             para [ text "There was a problem trying to understand your submission:" ]] @
             document_of_mismatch problem
      | Ok results ->
         let open Document in
         let process_result (total_given, feedback) (description, given, message) =
           (total_given + given,
            feedback @ [ [ para [text description] ] @ message ])
         in
         let mark, feedback_items =
           List.fold_left process_result (0, []) results
         in
         min mark q.total_value,
         q.total_value,
         Document.[
             para [ text "Your submission:" ];
             preformatted submission;
             enumerate feedback_items
         ])

let mark_question submission q =
  let mark, max_mark, feedback = mark_question submission q in
  mark,
  max_mark,
  Document.section
    ~title:(sprintf "%s (%d/%d)" q.question_title mark max_mark)
    ~content:(match q.description with
              | None -> feedback
              | Some desc -> Document.(para [ text desc ] :: feedback))
    ()


(*

let questions =
  let open Document in
  [ "cw1-2024-question1a", "Question 1(a)", 1,
    `Match (1, text "",
{|atom w atom x atom y atom z allsat (w | x | y | z) { "w": w, "x": x, "y": y, "z": z }|})
  ; "cw1-2024-question1b", "Question 1(b)", 1,
    `Match (1, text "",
{|atom w atom x atom y atom z
 allsat ((w | x | y | z) & (~w | ~x) & (~w | ~y) & (~w | ~z) & (~x | ~y) & (~x | ~z) & (~y | ~z))
 { "w": w, "x": x, "y": y, "z": z }|})
  ; "cw1-2024-question1c", "Question 1(c)", 2,
    `Match (2, text "",
{|atom x atom y atom z
 allsat ((x | y | z) & (~x | y | z) & (~y | x | z) & (~z | x | y) & (~x | ~y | ~z))
 { "x": x, "y": y, "z": z }|})
  ; "cw1-2024-question2",  "Question 2: Register Allocation", 5,
    `Or(
        `Match (5, text "This is a complete solution that makes sure that every variable has at most one register.",
                {|domain variable { X, Y, Z, W, U, V }

domain register { R1, R2, R3 }

atom allocated(v : variable, r : register)

// Every variable goes in a register
define all_variables_allocated {
  forall (v : variable) some (r : register) allocated(v, r)
}

define all_variables_at_most_one_register {
  forall (v : variable)
    forall (r1 : register)
      forall (r2 : register)
        (r1 = r2 | ~allocated(v,r1) | ~allocated(v,r2))
}

define overlapping_live_ranges(v1 : variable, v2 : variable) {
   forall (r : register)
     ~allocated(v1, r) | ~allocated(v2, r)
}

define constraints {
  overlapping_live_ranges(X, Y) &
  overlapping_live_ranges(X, W) &
  overlapping_live_ranges(X, U) &
  overlapping_live_ranges(X, Z) &
  overlapping_live_ranges(Z, W)
}

ifsat (all_variables_allocated &
       all_variables_at_most_one_register &
       constraints)
  { for (v : variable)
      v : [ for (r : register) if (allocated(v, r)) r ] }
                 |}),
        `Or (`Match (5, text "This is a mostly complete solution that does \
                         not make sure that every variable has at most \
                         one register.",
                {|domain variable { X, Y, Z, W, U, V }

domain register { R1, R2, R3 }

atom allocated(v : variable, r : register)

// Every variable goes in a register
define all_variables_allocated {
  forall (v : variable) some (r : register) allocated(v, r)
}

define overlapping_live_ranges(v1 : variable, v2 : variable) {
   forall (r : register)
     ~allocated(v1, r) | ~allocated(v2, r)
}

define constraints {
  overlapping_live_ranges(X, Y) &
  overlapping_live_ranges(X, W) &
  overlapping_live_ranges(X, U) &
  overlapping_live_ranges(X, Z) &
  overlapping_live_ranges(Z, W)
}

ifsat (all_variables_allocated &
       constraints)
  { for (v : variable)
      v : [ for (r : register) if (allocated(v, r)) r ] }
                 |}),
             `Match (4, text "This solution uses 'is_register' instead of 'allocated'?",
                     {|domain variable { X, Y, Z, W, U, V }

domain register { R1, R2, R3 }

atom is_register(v : variable, r : register)

// Every variable goes in a register
define all_variables_allocated {
  forall (v : variable) some (r : register) is_register(v, r)
}

define overlapping_live_ranges(v1 : variable, v2 : variable) {
   forall (r : register)
     ~is_register(v1, r) | ~is_register(v2, r)
}

define constraints {
  overlapping_live_ranges(X, Y) &
  overlapping_live_ranges(X, W) &
  overlapping_live_ranges(X, U) &
  overlapping_live_ranges(X, Z) &
  overlapping_live_ranges(Z, W)
}

ifsat (all_variables_allocated &
       constraints)
  { for (v : variable)
      v : [ for (r : register) if (is_register(v, r)) r ] }
                 |}))

      )

  ; "cw1-2024-question3",  "Question 3: Robot World", 5,
    `MarkerScript {|domain location { Store, Factory, LoadingBay }

domain object { Putty, Widget }

atom robotIn(l : location)
atom objectIn(l : location, o : object)
atom robotHolding(o : object)

for // FIXME POINTLESS

define robot_is_somewhere {
  some (l : location) robotIn(l)
}
{ "robotIn":
       [ for (l : location) if (robotIn(l)) l ] }

define robot_never_in_multiple_places {
  forall (l1 : location)
    forall (l2 : location)
      l1 = l2 | ~robotIn(l1) | ~robotIn(l2)
}
{ "robotIn":
       [ for (l : location) if (robotIn(l)) l ] }

define every_object_is_somewhere {
  forall (o : object)
    robotHolding(o) | (some (l : location) objectIn(l, o))
}
{    "objectIn":
       { for (obj : object)
           obj : [ for (l : location)
             if(objectIn(l, obj)) l ] },
    "robotHolding":
       [ for (o : object)
       if (robotHolding(o)) o ]
  }

define objects_never_in_multiple_places {
  forall (o : object)
    forall (l1 : location)
      forall (l2 : location)
        l1 = l2 | ~objectIn(l1, o) | ~objectIn(l2, o)
}
{    "objectIn":
       { for (obj : object)
           obj : [ for (l : location)
             if(objectIn(l, obj)) l ] } }

define objects_never_held_and_not_held {
  forall (o : object)
    forall (l : location)
      ~robotHolding(o) | ~objectIn(l, o)
}
{    "objectIn":
       { for (obj : object)
           obj : [ for (l : location)
             if(objectIn(l, obj)) l ] },
    "robotHolding":
       [ for (o : object)
       if (robotHolding(o)) o ]
  }

|}

  ; "cw1-2024-question4",  "Question 4: Finding paths", 6,
    `MarkerScript
{|domain location { Store, Factory, LoadingBay, Road, Yard, WasteHeap }

// The possible timesteps
domain timestep { T1, T2, T3, T4, T5, Tend }

// This defines the map
define linked(l1 : location, l2 : location)
  table {
    (Store, Factory)
    (Store, Yard)
    (Factory, Store)
    (Factory, LoadingBay)
    (Yard, Factory)
    (Yard, Store)
    (Yard, WasteHeap)
    (WasteHeap, Road)
    (WasteHeap, Yard)
    (LoadingBay, WasteHeap)
    (LoadingBay, Factory)
    (LoadingBay, Road)
  }

// The atoms describing where the robot is
atom robotIn(t : timestep, l : location)

for

// Constraint 1 : the robot is always somewhere
define always_somewhere {
  forall (t : timestep) some (l : location) robotIn(t, l)
}
  [ for (t : timestep)
       [for (loc : location) if (robotIn(t, loc)) loc ] ]

// Constraint 2 : the robot is never in more than one palce
define never_in_more_than_one_place {
  forall (t : timestep)
    forall (l1 : location)
      forall (l2 : location)
        l1 = l2 | ~robotIn(t, l1) | ~robotIn(t, l2)
}
  [ for (t : timestep)
       [for (loc : location) if (robotIn(t, loc)) loc ] ]

// Constraint 3 : sequential timesteps' locations are
// linked in the map
define good_steps {
  forall (t1 : timestep)
    forall (t2 : timestep)
      forall (src : location)
        forall (tgt : location)
           ~next(t1, t2)
         | ~robotIn(t1, src)
         | ~robotIn(t2, tgt)
         | linked(src,tgt)
}
  [ for (t : timestep)
       [for (loc : location) if (robotIn(t, loc)) loc ] ]

// Constraint 4 : the robot is initially in the Store
define initialState {
  robotIn(T1, Store)
}
  [ for (t : timestep)
       [for (loc : location) if (robotIn(t, loc)) loc ] ]

// Constraint 5 : the robot is on the Road at 'Tend'
define targetState {
  robotIn(Tend, Road)
}
  [ for (t : timestep)
       [for (loc : location) if (robotIn(t, loc)) loc ] ]

// Constraint 6 : the robot never visits the same place twice
define never_visit_same_place_twice {
  forall (t1 : timestep)
    forall (t2 : timestep)
      forall (l : location)
        t1 = t2 | ~robotIn(t1, l) | ~robotIn(t2, l)
}
  [ for (t : timestep)
       [for (loc : location) if (robotIn(t, loc)) loc ] ]

 |}
  ]

let document_of_error =
  let open Document in
  function
  | `Parse err ->
     [
       para [
           textf "I was unable to parse your submission: %s"
             (Parser_util.Driver.string_of_error_with_location err)
         ]
     ]
  | `Type_error (_loc, msg) ->
     [para [textf "There was an error trying to interpret your \
                   submission: %s" msg]
     ]
  | `Unexpected_commands ->
     [para [text "Your submission had unexpected commands in it."]]
  | `Domain_mismatch ->
     [para [text
              "There was a mismatch in the domain definitions, so I \
               was unable to mark this submission automatically."]]
  | `Not_enough_solutions expected_json ->
     [ para [
           text "Your code does not produce enough solutions. The \
                 following solution is not generated by your \
                 constraints:"
         ];
       monospace (Json.to_document expected_json)
     ]
  | `Too_many_solutions unwanted_json ->
     [
       para [
           text "Your code produces too many solutions. The following \
                 solution is generated by your constraints, but is not \
                 required by the solution:"
         ];
       monospace (Json.to_document unwanted_json)
     ]
  | `Solution_mismatch (expected, submitted) ->
     [
       para [
           text "Your code produces solutions that are not required, \
                 and misses solutions that are required. The following \
                 is an example of a solution that your code should \
                 produce but does not:"
         ];
       monospace (Json.to_document expected);
       para [text "This is an example of a solution that you code \
                   produces but should not:"];
       monospace (Json.to_document submitted)
     ]

  | `Expecting_definition name ->
      [ para [ textf
                 "Expecting a definition '%s' in the submitted script, but it \
                  was either not present or was an atom or table."
       name]]
  | `Non_clause_definition name ->
     [ para [
           textf
             "Definition '%s' is present in the submitted script, but \
              is not of the correct type."
             name
         ]
     ]
  | `Atom_become_defn name | `Changed_atom (name, _, _) ->
     [ para [
           textf "You changed the definition of atom '%s' to a definition, which \
                  means that the submission could not be marked \
                  automatically"
             name]
     ]
  | `Missing_atom name ->
     [ para [
           textf "The atom '%s' was expected to be in your submission, \
                  but it wasn't there. This means that it is not \
                  possible to evaluate your submission for marks."
             name]
     ]




let do_question marks comment specimen submission =
  match
    let* expected  = parse_and_typecheck specimen in
    let* submitted = parse_and_typecheck submission in
    Slakemoth.Compare.do_question expected submitted
  with
  | Ok () ->
     let open Document in
     marks, [para [text "This solution is correct!"; comment]]
  | Error err ->
     0, document_of_error err

let marker_question marker_script submitted_script =
  let open Slakemoth in
  match
    let* marking_script = Reader.parse_marking_script marker_script in
    let* submitted_script = Reader.parse submitted_script in
    Marker.check marking_script submitted_script
  with
  | Ok results ->
     let open Document in
     let process_result (total_given, feedback) = function
       | name, Ok () ->
          (total_given + 1,
           feedback @ [ [ para [textf "%s: correct" name] ] ])
       | name, Error msg ->
          (total_given + 0,
           feedback @ [ [ para [textf "%s :" name] ] @ document_of_error msg ])
     in
     let mark, feedback_items =
       List.fold_left process_result (0, []) results
     in
     mark,
     [enumerate feedback_items]
  | Error err ->
     0,
     document_of_mismatch err

let mark_question submission (question_id, question_title, mark_value, solution) =
  match List.assoc_opt question_id submission with
  | None | Some "" ->
     let open Document in
     question_id,
     0,
     mark_value,
     section ~title:(Printf.sprintf "%s (0/%d)" question_title mark_value)
       ~content:[ para [ text "No solution submitted!" ] ]
       ()
  | Some submitted ->
     let rec attempt_solution = function
       | `Match (mark_value, comment, solution) ->
          do_question mark_value comment solution submitted
       | `MarkerScript marker_script ->
          marker_question marker_script submitted
       | `Or (sol1, sol2) ->
          let marks1, message1 = attempt_solution sol1 in
          let marks2, message2 = attempt_solution sol2 in
          if marks1 > marks2 then
            marks1, message1
          else
            marks2, message2
     in
     let mark, message = attempt_solution solution in
     let open Document in
     question_id,
     mark,
     mark_value,
     section ~title:(Printf.sprintf "%s (%d/%d)" question_title mark mark_value)
       ~content:([ para [ text "Your answer:" ];
                   preformatted submitted] @ message)
                   ()
 *)


let get_file_of_dir dirname =
  Sys.readdir dirname
  |> Array.to_seq
  |> Seq.filter (fun entry -> not (String.starts_with ~prefix:"." entry))
  |> Seq_ext.head
  |> Option.to_result ~none:"No file found"

let do_submission dirname outdir entry =
  let partnum = String.sub entry 12 7 in
  let subdir = Filename.concat dirname entry in
  let outdir = Filename.concat outdir entry in
  try
    let* filename = get_file_of_dir subdir in
    let* submission = read_answers_file (Filename.concat subdir filename) in
    (* for each question, *)
    let do_question (total_mark, question_marks, feedback) question =
      let qmark, _qmax, qfeedback =
        mark_question submission question
      in
      (total_mark + qmark,
       qmark::question_marks,
       qfeedback :: feedback)
    in
    let total_mark, rev_question_marks, rev_feedbacks =
      List.fold_left do_question (0, [], []) questions
    in
    let feedback =
      Document.document
        ~title:(Printf.sprintf "CS208 Coursework 1 (%d/%d)" total_mark 20)
        ~sections:(List.rev rev_feedbacks)
        ()
    in
    let question_marks = List.rev rev_question_marks in
    if not (Sys.file_exists outdir) then
      Sys.mkdir outdir 0o700;
    Out_channel.with_open_bin
      Filename.(concat outdir "feedback.txt")
      (fun ch ->
        Pretty.output_to_channel ch
          (Document.ToPretty.pretty_of_document feedback));
    Printf.printf "%s,Participant %s,%s,%s,%d,%s\n"
      entry
      partnum
      (List.assoc "cw1-2024-name" submission)
      (List.assoc "cw1-2024-regnum" submission)
      total_mark
      (String.concat "," (List.map string_of_int question_marks));
    Result.ok ()
  with exn ->
    Error ("EXCEPTION: " ^ (Printexc.to_string exn))

let () =
  let dir = Sys.argv.(1) in
  let dirname = Filename.concat dir "submissions" in
  let outdir  = Filename.(concat dir "feedback") in
  if not (Sys.file_exists outdir) then
    Sys.mkdir outdir 0o700;
  let partnum = if Array.length Sys.argv = 3 then Some Sys.argv.(2) else None in
  let partnums =
    match partnum with
    | None ->
       (* do all of them *)
       Sys.readdir dirname
       |> Array.to_seq
       |> Seq.filter (fun entry -> not (String.starts_with ~prefix:"." entry))
    | Some partnum ->
       let entry = "Participant_" ^ partnum ^ "_assignsubmission_file" in
       Seq.return entry
  in
  partnums
  |> Seq_ext.Iter.gather_errors (do_submission dirname outdir)
  |> (function
      | [] -> ()
      | errors ->
         errors |>
           List.iter (fun (entry, error) ->
               Printf.eprintf "%s: %s\n" entry error))
