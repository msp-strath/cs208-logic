open Generalities.Sexp_parser

let config_p =
  let formula =
    let+? str = atom in
    Result.map_error
      (function `Parse e -> Parser_util.Driver.string_of_error e)
      (Fol_formula.Formula.of_string str)
  in
  let assumption_p =
    sequence
      (let* name       = consume_next atom in
       let* assumption = consume_next formula in
       let* ()         = assert_nothing_left in
       return (name, `F assumption))
  in

  tagged "config"
    (let* assumptions = consume_opt "assumptions" (many assumption_p) in
     let* assumps_nm  = consume_opt "assumptions-name" (one atom) in
     let* goal        = consume_one "goal" (one formula) in
     let* name        = consume_opt "name" (one atom) in
     let* solution    = consume_opt "solution" (one sexp) in
     let  assumptions = Option.value ~default:[] assumptions in
     return (name, assumptions, assumps_nm, goal, solution))
