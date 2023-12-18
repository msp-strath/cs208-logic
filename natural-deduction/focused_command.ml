open Generalities
open Focused
open Command

let valid_name str =
  let is_alpha = function 'A' .. 'Z' | 'a' .. 'z' | '_' -> true | _ -> false
  and is_alphanum = function
    | 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '-' | '_' -> true
    | _ -> false
  in
  String.length str > 0
  && is_alpha str.[0]
  && String.for_all is_alphanum str

let name_p =
  Result_ext.of_predicate ~on_error:"not an alphanumeric identifier" valid_name

let assump_nm =
  "assumption name", name_p

let var_nm =
  "variable name", name_p

let term =
  let term_p s =
    match Fol_formula.Term.of_string s with
    | Error _ -> Error "term not understood"
    | Ok t -> Ok t
  in
  ("term", term_p)

let formula =
  let formula_p s =
    match Fol_formula.Formula.of_string s with
    | Error _ -> Error "formula not understood"
    | Ok t -> Ok t
  in
  ("formula", formula_p)

let commands =
  [ "true", cmd e Truth
  ; "split", cmd e Split
  ; "left", cmd e Left
  ; "right", cmd e Right
  ; "apply", cmd e Implies_elim
  ; "first", cmd e Conj_elim1
  ; "second", cmd e Conj_elim2
  ; "false", cmd e Absurd
  ; "not-elim", cmd e NotElim
  ; "refl", cmd e Refl
  ; "reflexivity", cmd e Refl
  ; "rewrite->", cmd e (Rewrite `ltr)
  ; "rewrite<-", cmd e (Rewrite `rtl)
  ; "done", cmd e Close
  ; "use", cmd (assump_nm @-> e) (fun nm -> Use nm)
  ; "introduce", cmd (assump_nm @-> e) (fun nm -> Introduce nm)
  ; "cases", cmd (assump_nm @-> assump_nm @-> e) (fun h1 h2 -> Cases (h1, h2))
  ; "inst", cmd (term @-> e) (fun t -> Instantiate t)
  ; "exists", cmd (term @-> e) (fun t -> Exists t)
  ; "unpack", cmd (var_nm @-> assump_nm @-> e) (fun vnm hnm -> ExElim (vnm, hnm))
  ; "not-intro", cmd (assump_nm @-> e) (fun hnm -> NotIntro hnm)
  ; "subst", cmd (var_nm @-> formula @-> e) (fun vnm f -> Subst (vnm, f))
  ; "induction", cmd (var_nm @-> e) (fun x -> Induction x)
  ]

let of_string str =
  Result.map_error string_of_error (parse_command commands str)
