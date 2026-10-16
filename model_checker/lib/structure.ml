open Fol_formula

type identifier = string

type theory_item =
  | SymbolDeclaration of identifier * int
  | Axiom of identifier * formula

type item =
  | Theory of {
    name  : identifier;
    items : theory_item list;
  }
  | Model of {
    name : identifier;
    theory_name : identifier;
    defns : (identifier * string list list option) list;
  }
  | Check of { model_name : identifier; formula : formula; }

(*
type item =
  | Vocab of {
    name : string;
    arities : (string * int) list;
  }
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
  (** Check a single formula *)

  | Synth of { axioms : string; cardinality : int }
(** Synthesise a model for some axioms given a cardinality. *)
  *)

type t = item list
