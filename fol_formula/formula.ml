open Sexplib0.Sexp_conv
open Generalities

type t =
  | True
  | False
  | Atom of string * Term.t list
  | Imp of t * t
  | And of t * t
  | Or of t * t
  | Not of t
  | Forall of string * t
  | Exists of string * t
[@@deriving sexp]

let rec ands = function [] -> True | [ p ] -> p | p :: ps -> And (p, ands ps)
let rec ors = function [] -> False | [ p ] -> p | p :: ps -> Or (p, ors ps)
let is_conjunction = function And _ -> true | _ -> false
let is_disjunction = function Or _ -> true | _ -> false
let is_implication = function Imp _ -> true | _ -> false
let is_negation = function Not _ -> true | _ -> false
let is_truth = function True -> true | _ -> false
let is_lem = function Or (f, Not f') -> f = f' | _ -> false

let to_string f =
  let rec formula = function
    | Forall (x, f) -> "∀" ^ x ^ ". " ^ formula f
    | Exists (x, f) -> "∃" ^ x ^ ". " ^ formula f
    | Imp _ as f -> imps f
    | And _ as f -> ands f
    | Or _ as f -> ors f
    | f -> base f
  and imps = function Imp (f1, f2) -> base f1 ^ " → " ^ imps f2 | f -> base f
  and ands = function And (f1, f2) -> base f1 ^ " ∧ " ^ ands f2 | f -> base f
  and ors = function Or (f1, f2) -> base f1 ^ " ∨ " ^ ors f2 | f -> base f
  and base = function
    | Atom ("=", [ t1; t2 ]) -> Term.to_string t1 ^ " = " ^ Term.to_string t2
    | Atom ("!=", [ t1; t2 ]) -> Term.to_string t1 ^ " != " ^ Term.to_string t2
    | Atom (a, []) -> a
    | Atom (a, tms) ->
        a ^ "(" ^ String.concat ", " (List.map Term.to_string tms) ^ ")"
    | Not f -> "¬" ^ base f
    | True -> "T"
    | False -> "F"
    | (Imp _ | And _ | Or _ | Forall _ | Exists _) as f -> "(" ^ formula f ^ ")"
  in
  formula f

let to_doc f =
  let open Pretty in
  let variable x = text x in
  let rec formula = function
    | Forall _ | Exists _ as f -> nest 2 (group (quantifiers f))
    | f -> propositional f
  and quantifiers = function
    | Forall (x, f) ->
       text "∀" ^^ variable x ^^ text ". " ^^ quantifiers f
    | Exists (x, f) ->
       text "∃" ^^ variable x ^^ text ". " ^^ quantifiers f
    | f -> break ^^ propositional f
  and propositional = function
    | Imp _ as f -> align (group (imps f))
    | And _ as f -> align (group (ands f))
    | Or _ as f -> align (group (ors f))
    | f -> base f
  and imps = function
    | Imp (f1, f2) -> base f1 ^^ text " →" ^^ break ^^ imps f2
    | f            -> base f
  and ands = function
    | And (f1, f2) -> base f1 ^^ break ^^ text "∧" ^^ break ^^ ands f2
    | f -> base f
  and ors = function
    | Or (f1, f2) -> base f1 ^^ break ^^ text "∨" ^^ break ^^ ors f2
    | f -> base f
  and base = function
    | Atom ("=", [ t1; t2 ]) ->
       Term.to_doc t1 ^^ text " = " ^^ Term.to_doc t2
    | Atom ("!=", [ t1; t2 ]) ->
       Term.to_doc t1 ^^ text " != " ^^ Term.to_doc t2
    | Atom (a, []) ->
       text a
    | Atom (a, tms) ->
       text a
       ^^ text "("
       ^^ (tms |> List.to_seq
           |> Seq.map Term.to_doc
           |> Seq_ext.intersperse (text ", ")
           |> concat)
       ^^ text ")"
    | Not f ->
       text "¬" ^^ base f
    | True -> text "T"
    | False -> text "F"
    | (Imp _ | And _ | Or _ | Forall _ | Exists _) as f ->
       text "(" ^^ formula f ^^ text ")"
  in
  formula f

let%test "to_string1" =
  String.equal
    (to_string (And (Atom ("A", []), Or (Atom ("B",[]), Atom ("C",[])))))
    "A ∧ (B ∨ C)"

(* FIXME: merge with 'to_string' *)
let to_latex f =
  let rec formula = function
    | Forall (x, f) -> Printf.sprintf "\\forall \\mathit{%s}. %s" x (formula f)
    | Exists (x, f) -> Printf.sprintf "\\exists \\mathit{%s}. %s" x (formula f)
    | Imp _ as f -> imps f
    | And _ as f -> ands f
    | Or _ as f -> ors f
    | f -> base f
  and imps = function
    | Imp (f1, f2) -> Printf.sprintf "%s \\to %s" (base f1) (imps f2)
    | f -> base f
  and ands = function
    | And (f1, f2) -> Printf.sprintf "%s \\land %s" (base f1) (ands f2)
    | f -> base f
  and ors = function
    | Or (f1, f2) -> Printf.sprintf "%s \\lor %s" (base f1) (ands f2)
    | f -> base f
  and base = function
    | Atom ("=", [ t1; t2 ]) -> Term.to_string t1 ^ " = " ^ Term.to_string t2
    | Atom ("!=", [ t1; t2 ]) ->
        Term.to_string t1 ^ " \\not= " ^ Term.to_string t2
    | Atom (a, []) -> Printf.sprintf "\\mathrm{%s}" a
    | Atom (a, tms) ->
        Printf.sprintf "\\mathrm{%s}(%s)" a
          (String.concat ", " (List.map Term.to_latex tms))
    | Not f -> "\\lnot " ^ base f
    | True -> "\\mathsf{T}"
    | False -> "\\mathsf{F}"
    | (Imp _ | And _ | Or _ | Forall _ | Exists _) as f -> "(" ^ formula f ^ ")"
  in
  formula f

(******************************************************************************)
(* FIXME: depend on a smaller interface than Html_sig.S *)
module Make_HTML_Formatter (Html : Html_sig.S) = struct
  module H = Html
  module A = H.A

  let comma = H.text ", "

  let connective str =
    H.span ~attrs:[ A.class_ "syn-connective" ] (H.text str)
  let relation str =
    H.span ~attrs:[ A.class_ "syn-relation" ] (H.text str)
  let variable str =
    H.span ~attrs:[ A.class_ "syn-variable" ] (H.text str)
  let func str =
    H.span ~attrs:[ A.class_ "syn-function" ] (H.text str)

  let comma_sep f x =
    x |> List.to_seq |> Seq.map f |> Seq_ext.intersperse comma |> List.of_seq |> H.concat_list

  let rec html_of_term = function
    | Term.Var x ->
       (* FIXME: link to binder! *)
       variable x
    | Fun ("0", []) ->
       func "0"
    | Fun (func_name, tms) ->
       H.concat_list
         [ func func_name
         ; H.text "("
         ; comma_sep html_of_term tms
         ; H.text ")"
         ]

  let html_of_formula =
    let rec formula = function
      | Forall (x, f) ->
         H.concat_list
           [ H.span ~attrs:[ A.class_ "syn-quantifier" ] (H.text ("∀" ^ x ^ ". "))
           ; formula f
           ]
      | Exists (x, f) ->
         H.concat_list
           [ H.span ~attrs:[ A.class_ "syn-quantifier" ] (H.text ("∃" ^ x ^ ". "))
           ; formula f
           ]
      | Imp _ as f -> imps f
      | And _ as f -> ands f
      | Or _ as f -> ors f
      | Atom _ | True | False | Not _ as f ->
         base f
    and imps = function
      | Imp (f1, f2) -> H.concat_list [ base f1; connective " → "; imps f2 ] | f -> base f
    and ands = function
      | And (f1, f2) -> H.concat_list [ base f1; connective " ∧ "; ands f2 ] | f -> base f
    and ors = function
      | Or (f1, f2) -> H.concat_list [ base f1; connective " ∨ "; ors f2 ] | f -> base f
    and base = function
      | True ->
         connective "T"
      | False ->
         connective "F"
      | Atom ("=" | "!=" as rel, [t1; t2]) ->
         H.concat_list
           [ html_of_term t1
           ; relation (" " ^ rel ^ " ")
           ; html_of_term t2
           ]
      | Atom (atom, []) ->
         relation atom
      | Atom (atom, tms) ->
         H.concat_list
           [ relation atom
           ; H.text "("
           ; comma_sep html_of_term tms
           ; H.text ")"
           ]
      | Not f ->
         H.concat_list
           [ connective "¬"
           ; base f
           ]
      | (Imp _ | And _ | Or _ | Forall _ | Exists _) as f ->
         H.concat_list
           [ H.text "("
           ; formula f
           ; H.text ")"
           ]
    in
    formula

end


(******************************************************************************)

let ( <.> ) f g x = f (g x)

let rec fv = function
  | Atom (_, tms) -> List.fold_right Term.fv tms
  | Imp (f1, f2) | And (f1, f2) | Or (f1, f2) -> fv f1 <.> fv f2
  | Not f -> fv f
  | True | False -> fun x -> x
  | Forall (v, f) | Exists (v, f) ->
      NameSet.union (NameSet.remove v (fv f NameSet.empty))

let%test "fv1" =
  NameSet.equal
    (fv (Forall ("x", Atom ("f", [Var "x"]))) NameSet.empty)
    NameSet.empty

let closed f = NameSet.is_empty (fv f NameSet.empty)

let%test "closed1" =
  closed (Forall ("x", Atom ("f", [Var "x"])))

let rec bound_and_free = function
  | Atom (_, tms) -> List.fold_right Term.fv tms
  | Imp (f1, f2) | And (f1, f2) | Or (f1, f2) -> fv f1 <.> fv f2
  | Not f -> fv f
  | True | False -> fun x -> x
  | Forall (v, f) | Exists (v, f) -> NameSet.add v <.> bound_and_free f

(* Capture avoiding substitution *)

let rec subst x tm = function
  | True -> True
  | False -> False
  | Atom (r, tms) -> Atom (r, List.map (Term.subst x tm) tms)
  | Imp (f1, f2) -> Imp (subst x tm f1, subst x tm f2)
  | And (f1, f2) -> And (subst x tm f1, subst x tm f2)
  | Or (f1, f2) -> Or (subst x tm f1, subst x tm f2)
  | Not f -> Not (subst x tm f)
  | Forall (y, f) ->
      if x = y then Forall (y, f)
      else
        let fv_t = Term.fv tm NameSet.empty in
        if NameSet.mem y fv_t then
          let fv = fv f fv_t in
          let y' = NameSet.fresh_for fv y in
          let f = subst y (Var y') f in
          Forall (y', subst x tm f)
        else Forall (y, subst x tm f)
  | Exists (y, f) ->
      if x = y then Exists (y, f)
      else
        let fv_t = Term.fv tm NameSet.empty in
        if NameSet.mem y fv_t then
          let fv = fv f fv_t in
          let y' = NameSet.fresh_for fv y in
          let f = subst y (Var y') f in
          Exists (y', subst x tm f)
        else Exists (y, subst x tm f)

let alpha_equal f1 f2 =
  let rec eq pairs f1 f2 =
    match (f1, f2) with
    | True, True -> true
    | False, False -> true
    | Atom (r1, tms1), Atom (r2, tms2) ->
        r1 = r2
        && List.length tms1 = List.length tms2
        && List.for_all2 (Term.equal_open pairs) tms1 tms2
    | Imp (f1a, f1b), Imp (f2a, f2b)
    | And (f1a, f1b), And (f2a, f2b)
    | Or (f1a, f1b), Or (f2a, f2b) ->
        eq pairs f1a f2a && eq pairs f1b f2b
    | Forall (x1, f1), Forall (x2, f2) | Exists (x1, f1), Exists (x2, f2) ->
        eq ((x1, x2) :: pairs) f1 f2
    | Not f1, Not f2 -> eq pairs f1 f2
    | _ -> false
  in
  eq [] f1 f2

let generalise t formula =
  let formula_vars = bound_and_free formula NameSet.empty in
  let x = NameSet.fresh_for formula_vars "X" in
  let fv_t = Term.fv t NameSet.empty in
  let rec gen_term s =
    if s = t then Term.Var x
    else
      match s with
      | Term.Var v -> Term.Var v
      | Term.Fun (f, tms) -> Term.Fun (f, List.map gen_term tms)
  in
  let rec gen_formula = function
    | (True | False) as f -> f
    | Atom (r, tms) -> Atom (r, List.map gen_term tms)
    | Imp (p, q) -> Imp (gen_formula p, gen_formula q)
    | And (p, q) -> And (gen_formula p, gen_formula q)
    | Or (p, q) -> Or (gen_formula p, gen_formula q)
    | Not p -> Not (gen_formula p)
    | Forall (x, p) ->
        if NameSet.mem x fv_t then Forall (x, p) else Forall (x, gen_formula p)
    | Exists (x, p) ->
        if NameSet.mem x fv_t then Exists (x, p) else Exists (x, gen_formula p)
  in
  (x, gen_formula formula)

let rewrite t1 t2 formula =
  let x, gen_formula = generalise t1 formula in
  subst x t2 gen_formula
