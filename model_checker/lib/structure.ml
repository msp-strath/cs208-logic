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
