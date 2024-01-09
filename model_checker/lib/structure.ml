open Fol_formula

type item =
  | Vocab of { name : string; arities : (string * int) list }
  | Model of {
      name : string;
      vocab_name : string;
      defns : (string * string list list) list;
    }
  | Axioms of {
      name : string;
      vocab : string;
      formulas : (string * formula) list;
    }
  | Check of { model_name : string; formula : formula }
  | Synth of { axioms : string; cardinality : int }

type t = item list

let pp_comma_brk fmt () = Format.fprintf fmt ",@ "
let pp_comma_spc fmt () = Format.fprintf fmt ", "
let pp_tuple fmt =
  Format.fprintf fmt "(%a)"
    (Format.pp_print_list ~pp_sep:pp_comma_spc Format.pp_print_string)

let pp_item fmt = function
  | Vocab { name; arities } ->
      let pp_arity_decl fmt (nm, arity) = Format.fprintf fmt "%s/%d" nm arity in
      Format.fprintf fmt "@[<v2>vocab %s {@,%a@]@,}@," name
        (Format.pp_print_list ~pp_sep:pp_comma_brk pp_arity_decl)
        arities
  | Model { name; vocab_name; defns } ->
      let pp_set_decl fmt (nm, elements) =
        Format.fprintf fmt "%s = {@[<hv>%a@]}" nm
          (Format.pp_print_list ~pp_sep:pp_comma_brk pp_tuple)
          elements
      in
      Format.fprintf fmt "@[<v2>model %s for %s {@,%a@]@,}@," name vocab_name
        (Format.pp_print_list ~pp_sep:pp_comma_brk pp_set_decl)
        defns
  | Axioms { name; vocab; formulas } ->
      let pp_named_formula fmt (nm, formula) =
        Format.fprintf fmt "%s : \"%s\"" nm (Formula.to_string formula)
      in
      Format.fprintf fmt "@[<v2>axioms %s for %s {@,%a@]@,}@," name vocab
        (Format.pp_print_list ~pp_sep:pp_comma_brk pp_named_formula)
        formulas
  | Check { model_name; formula } ->
      Format.fprintf fmt "check %s |= \"%s\"@," model_name
        (Formula.to_string formula)
  | Synth { axioms; cardinality } ->
      Format.fprintf fmt "synth %s size %d@," axioms cardinality

let pp fmt =
  Format.fprintf fmt "@[<v>%a@]"
    (Format.pp_print_list ~pp_sep:Format.pp_print_cut pp_item)
