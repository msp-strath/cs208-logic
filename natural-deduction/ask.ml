(* The context consists of type definitions and term definitions. *)

open Sexplib0.Sexp_conv

module Calculus = struct

  type varname = string [@@deriving sexp]
  type typename = string [@@deriving sexp]
  type conname = string [@@deriving sexp]

  (*
  type typ =
    | Datatype of typename
    | Fun of typ * typ
   *)

  type pattern =
    | PVar of varname * typename
    | PCon of conname * pattern list

  type pattern_context =
    | CtxtPoint
    | CtxtCon of conname * patterns_context

  and patterns_context =
    { before : pattern list
    ; point  : pattern_context
    ; after  : pattern list
    }

  let rec plug_in_pattern pat = function
    | CtxtPoint ->
       pat
    | CtxtCon (conname, ctxt) ->
       PCon (conname, plug_in_patterns pat ctxt)
  and plug_in_patterns pat { before; point; after } =
    List.rev_append before (plug_in_pattern pat point :: after)

  let rec lookup_in_pattern var = function
    | PVar (var', typename) ->
       if String.equal var var' then
         Some (typename, CtxtPoint)
       else
         None
    | PCon (conname, patterns) ->
       (match lookup_in_patterns var patterns with
       | None ->
          None
       | Some (typename, ctxt) ->
          Some (typename, CtxtCon (conname, ctxt)))

  and lookup_in_patterns var patterns =
    let rec search before = function
      | [] ->
         None
      | pat::after ->
         (match lookup_in_pattern var pat with
         | None ->
            search (pat::before) after
         | Some (typename, point) ->
            Some (typename, { before; point; after }))
    in
    search [] patterns

  type goal =
    { pats : pattern list
    ; goal : typename
    ; construct : bool (* true when we are working on the goal *)
    }

  type rule =
    | Elim of varname (* * (conname * varname list) list *)
    (** Eliminate a variable in the elmination context, with the given
        shallow patterns *)
    | Switch (* switch to construct mode, '=' *)
    | Con of conname (* use a constructor *)
    | Var of varname (* use a variable. If it is a function then make more subgoals *)
    [@@deriving sexp]

  type error = string

  type assumption =
    | Datatype of (conname * typename list) list

  let types =
    [ "Nat",  Datatype [ "Z", []; "S", ["Nat"] ]
    ; "Expr", Datatype [ "X", []; "Add", ["Expr"; "Expr"]; "Mul", ["Expr"; "Expr"] ]
    ]

  type update = unit

  let empty_update = ()
  let update_goal () g = g
  let update_assumption () a = a
  let combine_update () () = ()

  let gensym =
    let next = ref 0 in
    fun base ->
    let id = !next in
    incr next;
    base ^ string_of_int id

  let apply context rule task =
    match rule, task with
    | Elim _var, { construct = true; _ } ->
       Error "Pattern matching not allowed on the right-hand side."
    | Elim var, ({ pats; _ } as task) ->
       (match lookup_in_patterns var pats with
       | None ->
          Error ("Variable '" ^ var ^ "' not known at this point.")
       | Some (typename, ctxt) ->
          (match List.assoc_opt typename context with
          | None ->
             Error "INTERNAL ERROR: variable of undeclared type found in context!"
          | Some (Datatype constructors) ->
             (* For each constructor, make a new pattern and corresponding subgoal *)
             let subgoals =
               List.map
                 (fun (con, typenames) ->
                   let vars =
                     List.map (fun typename -> PVar (gensym var, typename)) typenames in
                   let pat =
                     PCon (con, vars)
                   in
                   [], { task with pats = plug_in_patterns pat ctxt })
                 constructors
             in
             Ok (subgoals, ())))
    | Switch, ({ construct = false; _ } as task) ->
       Ok ([ [], { task with construct = true } ], ())
    | Switch, ({ construct = true; _ } as _task) ->
       Error "Already in construct mode"
    | Con _con, { construct = false; _} ->
       Error "Construction not permitted in the left-hand side pattern matching mode."
    | Con con, ({ goal; _ } as task) ->
       (match List.assoc_opt goal context with
       | None ->
          Error "INTERNAL ERROR: undeclared datatype found in goal."
       | Some (Datatype constructors) ->
          (match List.assoc_opt con constructors with
          | None ->
             Error ("Constructor '" ^ con ^ "' not valid for type '" ^ goal ^ "'")
          | Some typenames ->
             let subgoals =
               List.map (fun goal -> [], { task with goal }) typenames
             in
             Ok (subgoals, ())))
    | Var _var, { construct = false; _ } ->
       Error "Use of variables not permitted in the left-hand side pattern matching mode."
    | Var var, { goal; pats; _ } ->
       (match lookup_in_patterns var pats with
       | None ->
          Error ("Variable '" ^ var ^ "' not declared.")
       | Some (typename, _) ->
          if String.equal typename goal then
            Ok ([], ())
          else
            Error ("Variable '" ^ var ^ "' has type '" ^ typename ^ "', but goal is '" ^ goal ^ "'"))
end

module UI = struct
  module Calculus = Calculus

  open Calculus

  let rec string_of_pattern = function
    | PVar (x, _) -> x
    | PCon (con, []) ->
       con
    | PCon (con, pats) ->
       "(" ^ con ^ " " ^ string_of_patterns pats ^ ")"
  and string_of_patterns pats =
    String.concat " " (List.map string_of_pattern pats)


  let string_of_goal { pats; goal; construct = _ } =
    string_of_patterns pats ^ " |- " ^ goal

  let string_of_assumption nm _assump =
    nm

  let string_of_error err = err

  let label_of_rule = function
    | Elim v -> "from " ^ v
    | Switch -> "="
    | Con con -> con
    | Var var -> var

  let is_alpha_numeric = function
    | 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' -> true
    | _ -> false

  let parse_identifier string =
    if String.length string = 0 then
      None
    else if not (String.for_all is_alpha_numeric string) then
      None
    else
      match string.[0] with
      | 'A' .. 'Z' ->
         Some (`Con string)
      | 'a' .. 'z' ->
         Some (`Var string)
      | _ ->
         None

  let parse_rule string =
    let string = String.trim string in
    if String.starts_with ~prefix:"from " string then
      (let string = String.sub string 5 (String.length string - 5) in
       match parse_identifier string with
       | None | Some (`Con _) ->
          Error "Expecting a variable name after 'from'"
       | Some (`Var var) ->
          Ok (Elim var))
    else if String.equal string "=" then
      Ok Switch
    else
      match parse_identifier string with
      | None ->
         Error "not understood"
      | Some (`Var var) -> Ok (Var var)
      | Some (`Con con) -> Ok (Con con)

end

module Component =
  Proof_tree_UI2.Make
    (UI)
    (struct let assumptions = Calculus.types
            let goal =
              Calculus.{
                  pats = [PVar ("x", "Nat"); PVar ("y", "Nat")]
                ; goal = "Nat"
                ; construct = false
              }
     end)

let component _ =
  (module Component : Ulmus.PERSISTENT)
