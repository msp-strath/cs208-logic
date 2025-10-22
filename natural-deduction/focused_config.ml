open Generalities.Sexp_parser

type config = {
    name : string option;
    assumptions : (string * Focused.assumption) list;
    goal : Fol_formula.formula;
    solution : sexp option
  }

let config_p =
  let assumption =
    let+? str = atom in
    if str = "var" then
      Ok Focused.A_Termvar
    else
      Result.map_error
        (function `Parse e ->
           Parser_util.Driver.string_of_error e)
        (Result.map (fun f -> Focused.A_Formula f) (Fol_formula.Formula.of_string str))
  in
  let formula =
    let+? str = atom in
    Result.map_error
      (function `Parse e ->
         Parser_util.Driver.string_of_error e)
      (Fol_formula.Formula.of_string str)
  in
  let named_assumption_p =
    sequence
      (let+ name       = consume_next atom
       and+ assumption = consume_next assumption
       and+ ()         = assert_nothing_left in
       (name, assumption))
  in

  tagged "config"
    (let+ assumptions = consume_opt "assumptions" (many named_assumption_p)
     and+ goal        = consume_one "goal" (one formula)
     and+ name        = consume_opt "name" (one atom)
     and+ solution    = consume_opt "solution" (one sexp) in
     let  assumptions = Option.value ~default:[] assumptions in
     { name; assumptions; goal; solution })
