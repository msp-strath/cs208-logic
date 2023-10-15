open Generalities

type void = | [@@deriving sexp]
let of_void : 'a. void -> 'a = function _ -> .
type meta = string

(* Heterogeneous list equality *)
let rec list_equal elem_eq xs ys =
  match xs, ys with
  | [], [] -> true
  | x::xs, y::ys -> elem_eq x y && list_equal elem_eq xs ys
  | _ -> false

(******************************************************************************)
module VarSet = Set.Make (String)
module VarMap = Map.Make (String)

module Term : sig
  type 'a t =
    | Var of 'a
    | Fun of string * 'a t list

  val equal : ('a -> 'b -> bool) -> 'a t -> 'b t -> bool

  val of_sexp : Sexplib0.Sexp.t ->
                (string t, (string, Sexplib0.Sexp.t) Annotated.t) result

  val check_no_vars : 'var t -> (void t, [>`HasVar of 'var]) result

  val traverse : ('a -> ('b, 'e) result) -> 'a t -> ('b t, 'e) result

  val traverse_ : ('a -> (unit, 'b) result) -> 'a t -> (unit, 'b) result

  val vars : string t -> VarSet.t -> VarSet.t

  val to_string : ('a -> string) -> 'a t -> string
end = struct
  open Sexplib.Type
  open Result_ext

  type 'a t =
    | Var of 'a
    | Fun of string * 'a t list

  let var x = Var x

  let is_uppercase_ascii = function
    | 'A' .. 'Z' -> true
    | _ -> false

  let is_symbol_char = function
    | 'A' .. 'Z'
    | 'a' .. 'z'
    | '-'
    | '_'
    | '0' .. '9' ->
       true
    | _ ->
       false

  let classify_atom str =
    if String.length str = 0 then
      Error "Not an atom: empty string"
    else if String.exists (fun c -> not (is_symbol_char c)) str then
      Error "Not an atom: invalid symbol character"
    else if is_uppercase_ascii str.[0] then
      Ok (`Var str)
    else
      Ok (`Symbol str)

  let rec of_sexp = function
    | Atom str as sexp ->
       (let* kind = annotate_error sexp @@ classify_atom str in
        match kind with
        | `Var vnm -> Ok (Var str)
        | `Symbol symb -> Ok (Fun (symb, [])))
    | List (Atom str :: sexps) as sexp ->
       (let* kind = annotate_error sexp @@ classify_atom str in
        match kind with
        | `Var vnm ->
           annotate_error sexp @@
             Error "Variable in head position"
        | `Symbol symb ->
           let* terms = traverse of_sexp sexps in
           Ok (Fun (symb, terms)))
    | List _ as sexp ->
       annotate_error sexp @@
         Error "Empty list"

  let rec check_no_vars = function
    | Var v -> Error (`HasVar v)
    | Fun (fnm, args) ->
       let* args = traverse check_no_vars args in
       ok (Fun (fnm, args))

  let rec traverse f = function
    | Var v -> Result.map var (f v)
    | Fun (fnm, args) ->
       let* args = Result_ext.traverse (traverse f) args in
       ok (Fun (fnm, args))

  let rec to_string string_of_var = function
    | Var vnm -> string_of_var vnm
    | Fun (fnm, []) ->
       fnm
    | Fun (fnm, arg_terms) ->
       fnm ^ "(" ^ String.concat ", " (List.map (to_string string_of_var) arg_terms) ^ ")"

  let equal var_eq t1 t2 =
    let rec check t1 t2 =
      match t1, t2 with
      | Var v1, Var v2 ->
         var_eq v1 v2
      | Fun (fnm1, terms1), Fun (fnm2, terms2) ->
         String.equal fnm1 fnm2 && list_equal check terms1 terms2
      | _ ->
         false
    in
    check t1 t2

  let rec vars term =
    match term with
    | Var x          -> VarSet.add x
    | Fun (_, terms) -> List.fold_right vars terms

  let rec traverse_ p = function
    | Var x          -> p x
    | Fun (_, terms) -> Result_ext.traverse_ (traverse_ p) terms
end

type rule_description =
  { premises   : meta Term.t list
  ; conclusion : meta Term.t
  }

(*
module ExampleRules = struct
  let rules =
    [ "R1",
      { premises = [ Fun("furry", [Var "X"])
                   ; Fun("makes-milk", [Var "X"])
                   ]
      ; conclusion = Fun("mammal", [Var "X"])
      }

    ; "A1",
      { premises = []
      ; conclusion = Fun("furry", [Fun("bear", [])])
      }

    ; "A2",
      { premises = []
      ; conclusion = Fun("makes-milk", [Fun("bear", [])])
      }
    ]
end
 *)

let eq_var (x : void) (y : void) = of_void y

let rec match_term (pattern : meta Term.t) (term : void Term.t) subst =
  match pattern, term with
  | Var v, term ->
     (match VarMap.find_opt v subst with
      | None -> Some (VarMap.add v term subst)
      | Some term' ->
         if Term.equal eq_var term term' then Some subst else None)
  | Fun (fnm1, terms1), Fun (fnm2, terms2) ->
     if fnm1 = fnm2 then
       match_terms terms1 terms2 subst
     else
       None
  | _, Var _ -> .

and match_terms patterns terms subst =
  match patterns, terms with
  | [], [] -> Some subst
  | p::patterns, t::terms ->
     (match match_term p t subst with
      | None -> None
      | Some subst -> match_terms patterns terms subst)
  | _ ->
     None

let rec apply_subst subst = function
  | Term.Var v -> VarMap.find v subst
  | Fun (fnm, terms) ->
     Term.Fun (fnm, List.map (apply_subst subst) terms)

module type RULES = sig
  val rules : (string * rule_description) list
end

module OfSexp = struct
  open Sexplib0.Sexp
  open Result_ext

  (* Check that every variable in the premises appears in the
     conclusion, so we will never need to prompt for variables'
     values. *)
  let check_rule premises conclusion =
    let conclusion_vars = Term.vars conclusion VarSet.empty in
    let check_var v =
      if VarSet.mem v conclusion_vars then
        Ok ()
      else
        Error (Printf.sprintf "Variable '%s' in premises does not appear in the conclusion" v)
    in
    let* () = Result_ext.traverse_ (Term.traverse_ check_var) premises in
    ok { premises; conclusion }

  let extract_all tag =
    List.partition_map
      (function
       | List (Atom head::body) when String.equal head tag ->
          Left body
       | sexp ->
          Right sexp)

  let expect_one parent tag f sexps =
    match extract_all tag sexps with
    | [tagged], other ->
       let* result = f parent tagged in
       Ok (result, other)
    | [], _other ->
       annotate_error parent @@ Error (Printf.sprintf "Expecting a '(%s ...)' entry" tag)
    | _::_::_, _other ->
       annotate_error parent @@ Error (Printf.sprintf "Multiple '(%s ...)' entries" tag)

  let expect_nil parent = function
    | [] -> Ok ()
    | _ -> annotate_error parent @@ Error (Printf.sprintf "Unneeded entries")

  let atom parent = function
    | [Atom atom] -> Ok atom
    | _           -> annotate_error parent @@ Error "Expecting an atom"

  let expect_head tag = function
    | List (Atom head::items) when String.equal head tag -> Ok items
    | sexp ->
       annotate_error sexp @@ Error (Printf.sprintf "Expecting (%s ...)" tag)

  let list_entry f _parent = traverse f
  let single_entry f parent = function
    | [sexp] -> f sexp
    | _      -> annotate_error parent @@ Error (Printf.sprintf "Expecting single entry")

  let rule_of_sexp sexp items =
    let* name,       items = expect_one sexp "name" atom items in
    let* premises,   items = expect_one sexp "premises" (list_entry Term.of_sexp) items in
    let* conclusion, items = expect_one sexp "conclusion" (single_entry Term.of_sexp) items in
    let* ()                = expect_nil sexp items in
    let* rule = annotate_error sexp @@ check_rule premises conclusion in
    Ok (name, rule)

  let config sexp =
    let* items        = expect_head "config" sexp in
    let  rules, items = extract_all "rule" items in
    let* goal,  items = expect_one sexp "goal" (single_entry Term.of_sexp) items in
    let* ()           = expect_nil sexp items in
    let* rules        = traverse (rule_of_sexp sexp) rules in
    match Term.traverse (fun v -> Error (`HasVar v)) goal with
    | Ok goal ->
       Ok (rules, goal)
    | Error (`HasVar _) ->
       annotate_error sexp (Error "goal has variables")

  let config_rules_only sexp =
    let* items        = expect_head "config" sexp in
    let  rules, items = extract_all "rule" items in
    let* ()           = expect_nil sexp items in
    traverse (rule_of_sexp sexp) rules
end

module Calculus (Rules : RULES) : sig
  include Proof_tree.CALCULUS
          with type goal = void Term.t
           and type assumption = void
           and type error = string

  val label_of_rule : rule -> string
  val parse_rule : string -> (rule, string) result
end = struct
  open Sexplib0.Sexp_conv

  type goal = void Term.t
  type assumption = void
  type update = unit

  let empty_update = ()
  let update_goal () g = g
  let update_assumption () a = a

  type rule = string [@@deriving sexp]

  let label_of_rule rule =
    rule

  let parse_rule str =
    match List.assoc_opt str Rules.rules with
    | None -> Error (Printf.sprintf "Unknown rule: %s" str)
    | Some _ -> Ok str

  type error = string

  let apply _assumps rule_name goal =
    let { conclusion; premises } = List.assoc rule_name Rules.rules in
    match match_term conclusion goal VarMap.empty with
    | Some subst ->
       let subgoals = List.map (fun t -> [], apply_subst subst t) premises in
       Ok (subgoals, ())
    | None ->
       Error "rule conclusion does not match goal"
end

module UI (Rules : RULES) = struct

  module Calculus = Calculus (Rules)

  let string_of_goal = Term.to_string of_void

  let string_of_assumption = of_void

  let string_of_error = Fun.id

  let label_of_rule = Calculus.label_of_rule

  let parse_rule = Calculus.parse_rule
end

let inference_rule (name, {premises; conclusion}) =
  let open Ulmus.Html in
  let proofbox elements =
    div ~attrs:[A.class_ "proofbox"] elements
  and premisebox elements =
    div ~attrs:[A.class_ "premisebox"] elements
  and formulabox sequent =
    div ~attrs:[ A.class_ "formulabox"]
      (text (Term.to_string Fun.id sequent))
  in
  proofbox begin%concat
    premisebox begin%concat
      concat_map (fun s -> proofbox (formulabox s)) premises;
      div ~attrs:[A.class_ "rulename"] (text name)
    end;
    formulabox conclusion
  end

let display_rules rules =
  match OfSexp.config_rules_only (Sexplib.Sexp.of_string rules) with
  | Ok rules ->
     let module C = struct
         type state = unit
         type action = void

         let render () =
           let open Ulmus.Html in
           div ~attrs:[A.style "display: flex; flex-wrap: wrap"]
             (concat_map (fun h -> div ~attrs:[A.style "margin: 10px"] h)
                (List.map inference_rule rules))
         let update action () = of_void action
         let initial = ()
       end
     in
     (module C : Ulmus.COMPONENT)
  | Error err ->
      let msg = Annotated.detail err in
      failwith msg

let component_of_rules rules goal =
  let module Rules = struct let rules = rules end in
  let module Goal = struct let goal = goal end in
  (module Proof_tree_UI2.Make (UI (Rules)) (Goal) : Ulmus.COMPONENT)

let from_rules config =
  match OfSexp.config (Sexplib.Sexp.of_string config) with
  | Ok (rules, goal) ->
     component_of_rules rules goal
  | Error err ->
     let msg = Annotated.detail err in
     (* FIXME: display inline *)
     failwith ("ERROR: " ^ msg)

(*
  let module P =
    struct
      module Calculus = C

      let name_of_rule rule_name = rule_name
      let left_label_of_rule rule_name = None (* FIXME: what is this for? *)

      type partial = void [@@deriving sexp]

      let name_of_partial = of_void

      type rule_selector =
        | Immediate of C.rule
        | Disabled of string
        | Partial of partial

      type selector_group =
        { group_name : string; rules : rule_selector list }

      let rule_selection _assumps goal =
        let check_rule (rule_name, { conclusion; _ }) =
          match match_term conclusion goal VarMap.empty with
          | None -> Disabled rule_name
          | Some _ -> Immediate rule_name
        in
        [{ group_name = "Rule"; rules = List.map check_rule rules }]

      let elim_assumption : conclusion:Calculus.goal ->
                            assumption:Calculus.assumption ->
                            idx:int ->
                            (string * [ `ByAssumption
                                      | `Rule of Calculus.rule
                                      | `Partial of partial ]) list
        = fun ~conclusion ~assumption ~idx ->
        of_void assumption

      module Part_type = struct
        type t = void
        let placeholder = of_void
        let class_ = of_void
      end

      type partial_formula_part =
        | T of string
        | I of { value : string; typ : Part_type.t; update : string -> partial }
        | F of Calculus.goal

      type partial_premise = {
          premise_formula : partial_formula_part list;
          premise_assumption : string option;
        }

      type partial_presentation = {
          premises : partial_premise list;
          apply : Calculus.rule option;
        }

      let present_partial : Calculus.goal -> partial -> partial_presentation =
        fun _ -> of_void

    end
  in (module P : Proof_tree_UI.PARTIALS)
 *)
