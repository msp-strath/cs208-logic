open Sexplib0.Sexp_conv

type t = Var of string | Fun of string * t list [@@deriving sexp]

let rec to_string = function
  | Var x -> x
  | Fun ("0", []) -> "0"
  | Fun (f, tms) -> f ^ "(" ^ String.concat ", " (List.map to_string tms) ^ ")"

let rec to_latex = function
  | Var x -> Printf.sprintf "\\mathit{%s}" x
  | Fun ("0", []) -> "0"
  | Fun (f, tms) ->
      Printf.sprintf "\\mathsf{%s}(%s)" f
        (String.concat ", " (List.map to_latex tms))

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

(* FIXME: with a list of pairs? *)
let rec equal t1 t2 =
  match (t1, t2) with
  | Var x1, Var x2 -> String.equal x1 x2
  | Fun (f1, tms1), Fun (f2, tms2) ->
      String.equal f1 f2
      && List.length tms1 = List.length tms2
      && List.for_all2 equal tms1 tms2
  | _, _ -> false

let rec subst x tm = function
  | Var y -> if x = y then tm else Var y
  | Fun (f, tms) -> Fun (f, List.map (subst x tm) tms)
