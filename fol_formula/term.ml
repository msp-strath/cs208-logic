open Sexplib0.Sexp_conv
open Generalities

type t =
  | Var of string
  | Fun of string * t list
[@@deriving sexp]

(******************************************************************************)

let is_numeric_constant s =
  let is_digit = function '0' .. '9' -> true | _ -> false in
  let rec is_digits idx =
    idx = String.length s || (is_digit s.[idx] && is_digits (idx+1))
  in
  String.length s > 0 &&
    ((s.[0] = '-' && String.length s > 1 && is_digits 1)
     || is_digits 0)

let rec to_string = function
  | Var x -> x
  | Fun (f, []) when is_numeric_constant f ->
     f
  | Fun (f, tms) ->
     f ^ "(" ^ String.concat ", " (List.map to_string tms) ^ ")"

let%test "to_string_var" =
  String.equal (to_string (Var "x")) "x"

let%test "to_string_0" =
  String.equal (to_string (Fun ("0", []))) "0"

let%test "to_string_fun" =
  String.equal
    (to_string (Fun ("f", [Fun ("g", []); Var "x"])))
    "f(g(), x)"

let rec to_latex = function
  | Var x -> Printf.sprintf "\\mathit{%s}" x
  | Fun ("0", []) -> "0"
  | Fun (f, tms) ->
      Printf.sprintf "\\mathsf{%s}(%s)" f
        (String.concat ", " (List.map to_latex tms))

let parens d = Pretty.(text "(" ^^ d ^^ text ")")

let rec to_doc = function
  | Var x ->
     Pretty.text x
  | Fun ("0", []) ->
     Pretty.text "0"
  | Fun (fname, terms) ->
     Pretty.(text fname
             ^^ parens (terms |> List.to_seq |> Seq.map to_doc |> Seq_ext.intersperse (text ", ") |> concat))

let rec to_doc_prec l = function
  | Var x ->
     Pretty.text x
  | Fun ("0", []) ->
     Pretty.text "0"
  | Fun ("add", [x; y]) ->
     if l > 20 then
       Pretty.(text "("
               ^^ to_doc_prec 21 x
               ^^ Pretty.text " + "
               ^^ to_doc_prec 20 y
               ^^ Pretty.text ")")
     else
       Pretty.(to_doc_prec 21 x ^^ text " + " ^^ to_doc_prec 20 y)
  | Fun (fname, terms) ->
     Pretty.(text fname
             ^^ parens (terms |> List.to_seq |> Seq.map (to_doc_prec 100) |> Seq_ext.intersperse (text ", ") |> concat))



let rec pp fmt = function
  | Var x -> Format.fprintf fmt "%s" x
  | Fun ("0", []) -> Format.pp_print_string fmt "0"
  | Fun (f, tms) -> Format.fprintf fmt "%s(%a)" f pp_tms tms

and pp_tms fmt = function
  | [] -> ()
  | [ tm ] -> pp fmt tm
  | tm :: tms -> Format.fprintf fmt "%a, %a" pp tm pp_tms tms

let rec fv = function
  | Var v -> NameSet.add v
  | Fun (_, tms) -> List.fold_right fv tms

let rec equal t1 t2 = match t1, t2 with
  | Var x1, Var x2 ->
     String.equal x1 x2
  | Fun (f1, tms1), Fun (f2, tms2) ->
     String.equal f1 f2
     && List.length tms1 = List.length tms2
     && List.for_all2 equal tms1 tms2
  | _, _ ->
     false

(******************************************************************************)

let rec vars_eq x1 x2 = function
  | [] -> x1 = x2
  | (y1, y2) :: pairs ->
     (x1 = y1 && x2 = y2) || (x1 <> y1 && x2 <> y2 && vars_eq x1 x2 pairs)

let%test "vars_eq1" =
  vars_eq "x" "y" ["z","z"; "x","y"]

let%test "vars_eq2" =
  not @@ vars_eq "x" "y" ["y","x"]

let%test "vars_eq3" =
  not @@ vars_eq "x" "y" []

let%test "vars_eq4" =
  not @@ vars_eq "x" "y" ["x","z";"x","y"]

let%test "vars_eq5" =
  vars_eq "x" "y" ["y","z"; "x","y"]

(******************************************************************************)

let rec equal_open pairs t1 t2 = match t1, t2 with
  | Var x1, Var x2 -> vars_eq x1 x2 pairs
  | Fun (f1, tms1), Fun (f2, tms2) ->
     f1 = f2
     && List.length tms1 = List.length tms2
     && List.for_all2 (equal_open pairs) tms1 tms2
  | _, _ -> false

(******************************************************************************)

let rec subst x tm = function
  | Var y -> if x = y then tm else Var y
  | Fun (f, tms) -> Fun (f, List.map (subst x tm) tms)

let%test "subst1" =
  let m = Fun ("f", [Var "x"; Var "x"]) in
  let n = Fun ("g", [Var "x"]) in
  equal (subst "x" n m) (Fun ("f", [n; n]))
