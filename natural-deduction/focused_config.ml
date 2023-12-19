open Generalities.Sexp_parser

type config = {
    name : string option;
    assumptions : (string * Focused.assumption) list;
    assumptions_name : string option;
    goal : Fol_formula.formula;
    solution : sexp option
  }

let config_p =
  let formula =
    let+? str = atom in
    Result.map_error
      (function `Parse e -> Parser_util.Driver.string_of_error e)
      (Fol_formula.Formula.of_string str)
  in
  let assumption_p =
    sequence
      (let+ name       = consume_next atom
       and+ assumption = consume_next formula
       and+ ()         = assert_nothing_left in
       (name, Focused.A_Formula assumption))
  in

  tagged "config"
    (let+ assumptions = consume_opt "assumptions" (many assumption_p)
     and+ assumptions_name= consume_opt "assumptions-name" (one atom)
     and+ goal        = consume_one "goal" (one formula)
     and+ name        = consume_opt "name" (one atom)
     and+ solution    = consume_opt "solution" (one sexp) in
     let  assumptions = Option.value ~default:[] assumptions in
     { name; assumptions; assumptions_name; goal; solution })
