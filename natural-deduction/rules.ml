open Generalities

(* Heterogeneous list comparison *)
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

  val of_sexp : string t Sexp_parser.parser

  val check_no_vars : 'var t -> (Impossible.t t, [>`HasVar of 'var]) result

  val traverse : ('a -> ('b, 'e) result) -> 'a t -> ('b t, 'e) result

  val traverse_ : ('a -> (unit, 'b) result) -> 'a t -> (unit, 'b) result

  val vars : string t -> VarSet.t -> VarSet.t

  val map : ('a -> 'b) -> 'a t -> 'b t

  val contains : ('a -> bool) -> 'a t -> bool

  val to_string : ('a -> string) -> 'a t -> string

  type subst

  val empty_subst : subst

  val combine_subst : subst -> subst -> subst

  (* FIXME: abstract type of substitutions so we don't ever make a
     circular one. *)
  val apply_subst : subst -> string t -> string t

  val unify : string t -> string t -> subst -> subst option
end = struct
  open Result_ext.Syntax

  type 'a t =
    | Var of 'a
    | Fun of string * 'a t list

  let var x = Var x

  let is_uppercase_ascii = function
    | 'A' .. 'Z' -> true
    | _ -> false

  (*
  let is_symbol_char = function
    | 'A' .. 'Z'
    | 'a' .. 'z'
    | '-'
    | '_'
    | '0' .. '9' ->
       true
    | _ ->
       false
   *)

  let classify_atom str =
    if String.length str = 0 then
      Error "Not an atom: empty string"
    (* else if String.exists (fun c -> not (is_symbol_char c)) str then *)
    (*   Error "Not an atom: invalid symbol character" *)
    else if is_uppercase_ascii str.[0] then
      Ok (`Var str)
    else
      Ok (`Symbol str)

  let of_sexp =
    let open Sexp_parser in
    fix @@
      fun p_term ->
      on_kind
        ~atom:
        (fun str ->
          match classify_atom str with
          | Ok (`Var vnm) -> Ok (Var vnm)
          | Ok (`Symbol symb) -> Ok (Fun (symb, []))
          | Error _ as e -> e)
        ~list:
        (let* head = consume_next atom in
         let* args = many p_term in
         match classify_atom head with
         | Error _ as e -> result e
         | Ok (`Var _) -> fail "Variable in head position"
         | Ok (`Symbol head) -> return (Fun (head, args)))

  let rec check_no_vars = function
    | Var v -> Error (`HasVar v)
    | Fun (fnm, args) ->
       let* args = Result_ext.traverse check_no_vars args in
       Result.ok (Fun (fnm, args))

  let rec traverse f = function
    | Var v -> Result.map var (f v)
    | Fun (fnm, args) ->
       let* args = Result_ext.traverse (traverse f) args in
       Result.ok (Fun (fnm, args))

  let rec to_string string_of_var = function
    | Var vnm -> string_of_var vnm
    | Fun (fnm, []) ->
       fnm
    | Fun (fnm, arg_terms) ->
       fnm ^ "(" ^ String.concat ", " (List.map (to_string string_of_var) arg_terms) ^ ")"

  let rec contains p = function
    | Var v         -> p v
    | Fun (_, args) -> List.exists (contains p) args

  let rec map f = function
    | Var v -> Var (f v)
    | Fun (fnm, args) -> Fun (fnm, List.map (map f) args)

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

  type subst = string t VarMap.t

  let empty_subst = VarMap.empty

  (* Left-biased combination. Usually, this should only ever be used
     on disjoint substitutions. FIXME: why isn't this composition of
     substituions-as-functions? *)
  let combine_subst s1 s2 =
    VarMap.union (fun _ a _b -> Some a) s1 s2

  let rec apply_subst subst = function
    | Var v ->
       (match VarMap.find v subst with
        | exception Not_found -> Var v
        | term -> apply_subst subst term)
    | Fun (fnm, terms) ->
       Fun (fnm, List.map (apply_subst subst) terms)

  let rec unify (term1 : string t) (term2 : string t) subst =
    match apply_subst subst term1, apply_subst subst term2 with
    | Fun (fnm1, terms1), Fun (fnm2, terms2) ->
       if String.equal fnm1 fnm2 then
         unify_terms terms1 terms2 subst
       else
         None (* mismatched function symbols *)
    | Var v1, Var v2 when String.equal v1 v2 ->
       Some subst
    | Var v, term | term, Var v ->
       if contains (String.equal v) term then
         None (* circular *)
       else
         Some (VarMap.add v term subst)
  and unify_terms terms1 terms2 subst =
    match terms1, terms2 with
    | [], [] ->
       Some subst
    | t1::terms1, t2::terms2 ->
       (match unify t1 t2 subst with
        | None -> None
        | Some subst -> unify_terms terms1 terms2 subst)
    | _ ->
       None
end

type rule_description =
  { premises   : string Term.t list
  ; conclusion : string Term.t
  }

let freshen gensym { premises; conclusion } =
  let table = ref VarMap.empty in
  let update_var v =
    match VarMap.find v !table with
    | exception Not_found ->
       let replacement = gensym () in
       table := VarMap.add v replacement !table;
       replacement
    | replacement ->
       replacement
  in
  let premises = List.map (Term.map update_var) premises
  and conclusion = Term.map update_var conclusion
  in
  premises, conclusion

module type RULES = sig
  val rules : (string * rule_description) list
end

module OfSexp = struct
  open Sexp_parser

  let rule =
    let* name       = consume_one "name" (one atom) in
    let* premises   = consume_opt "premises" (many Term.of_sexp) in
    let* conclusion = consume_one "conclusion" (one Term.of_sexp) in
    let* ()         = assert_nothing_left in
    let  premises   = Option.value ~default:[] premises in
    return (name, { premises; conclusion })

  let config =
    tagged "config"
      (let* rules = consume_all "rule" rule in
       let* goal  = consume_one "goal" (one Term.of_sexp) in
       let* ()    = assert_nothing_left in
       let* goal  = result @@ Term.traverse (Result_ext.errorf "Goal has variable '%s'") goal in
       return (rules, goal))

  let config_rules_only =
    tagged "config"
      (let* rules = consume_all "rule" rule in
       let* ()    = assert_nothing_left in
       return rules)
end

module Calculus (Rules : RULES) : sig
  include Proof_tree.CALCULUS
          with type goal = string Term.t
           and type assumption = Impossible.t
           and type error = string

  val label_of_rule : rule -> string
  val parse_rule : string -> (rule, string) result
end = struct
  open Sexplib0.Sexp_conv

  type metavar = string

  let gensym =
    let next = ref 0 in
    fun () ->
    let id = !next in
    incr next;
    "X" ^ string_of_int id

  type goal = metavar Term.t
  type assumption = Impossible.t
  type update = Term.subst

  let empty_update = Term.empty_subst
  let update_goal = Term.apply_subst
  let update_assumption _subst = Impossible.elim
  let combine_update = Term.combine_subst

  (* FIXME: rule_of_sexp should check that it is a valid rule! *)
  type rule = string [@@deriving sexp]

  let label_of_rule rule =
    rule

  let parse_rule str =
    match List.assoc_opt str Rules.rules with
    | None -> Error (Printf.sprintf "Unknown rule: %s" str)
    | Some _ -> Ok str

  type error = string

  let apply _assumps rule_name goal =
    let rule_desc = List.assoc rule_name Rules.rules in
    let premises, conclusion = freshen gensym rule_desc in
    match Term.unify conclusion goal Term.empty_subst with
    | Some subst ->
       let subgoals = List.map (fun t -> [], Term.apply_subst subst t) premises in
       Ok (subgoals, subst)
    | None ->
       Error "rule conclusion does not match goal"
end

module UI (Rules : RULES) = struct

  module Calculus = Calculus (Rules)

  let string_of_goal = Term.to_string Fun.id

  let string_of_assumption _ = Impossible.elim

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
     (* FIXME: make widgets that just display fixed HTML *)
     let module C = struct
         type state = unit
         type action = Impossible.t

         let render () =
           let open Ulmus.Html in
           div ~attrs:[A.style "display: flex; flex-wrap: wrap"]
             (concat_map (fun h -> div ~attrs:[A.style "margin: 10px"] h)
                (List.map inference_rule rules))
         let update action () = Impossible.elim action
         let initial = ()
         let serialise () = ""
         let deserialise _ = Some ()
       end
     in
     (module C : Ulmus.PERSISTENT)
  | Error err ->
     let msg = Annotated.detail err in
     Widgets.Error_display.component ("Configuration error: " ^ msg)

let component_of_rules rules goal =
  let module Rules = struct let rules = rules end in
  let module Goal = struct let assumptions = [] let goal = goal end in
  (module Proof_tree_UI2.Make (UI (Rules)) (Goal) : Ulmus.PERSISTENT)

let from_rules config =
  match OfSexp.config (Sexplib.Sexp.of_string config) with
  | Ok (rules, goal) ->
     component_of_rules rules goal
  | Error err ->
     let msg = Annotated.detail err in
     Widgets.Error_display.component ("Configuration error: " ^ msg)
