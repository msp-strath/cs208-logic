open Generalities
open Focused

let assump_nm =
  Command.item "assumption name" String_parser.name

let var_nm =
  Command.item "variable name" String_parser.name

let term =
  let term_p s =
    match Fol_formula.Term.of_string s with
    | Error _ -> Error "term not understood"
    | Ok t -> Ok t
  in
  Command.item "term" term_p

let formula =
  let formula_p s =
    match Fol_formula.Formula.of_string s with
    | Error _ -> Error "formula not understood"
    | Ok t -> Ok t
  in
  Command.item "formula" formula_p

let commands =
  let open Command in
  [ "true",
    plain Truth

  ; "split",
    plain Split

  ; "left",
    plain Left

  ; "right",
    plain Right

  ; "apply",
    plain Implies_elim

  ; "first",
    plain Conj_elim1

  ; "second",
    plain Conj_elim2

  ; "false",
    plain Absurd

  ; "not-elim",
    plain NotElim

  ; "refl",
    plain Refl

  ; "reflexivity",
    plain Refl

  ; "rewrite->",
    plain (Rewrite `ltr)

  ; "rewrite<-",
    plain (Rewrite `rtl)

  ; "done",
    plain Close

  ; "use",
    (let+ nm = assump_nm in Use nm)

  ; "introduce",
    (let+ nm = assump_nm in Introduce nm)

  ; "cases",
    (let+ nm1 = assump_nm and+ nm2 = assump_nm in Cases (nm1, nm2))

  ; "inst",
    (let+ t = term in Instantiate t)

  ; "exists",
    (let+ t = term in Exists t)

  ; "unpack",
    (let+ v = var_nm and+ h = assump_nm in ExElim (v, h))

  ; "not-intro",
    (let+ h = assump_nm in NotIntro h)

  ; "subst",
    (let+ v = var_nm and+ f = formula in Subst (v, f))

  ; "induction",
    (let+ v = var_nm in Induction v)
  ]

let of_string =
  Command.of_string commands
