module type PARTIALS = sig
  module Calculus : Proof_tree.CALCULUS

  val name_of_rule : Calculus.rule -> string
  val left_label_of_rule : Calculus.rule -> string option

  type partial [@@deriving sexp]

  val name_of_partial : partial -> string

  (* Rule selection *)
  type rule_selector =
    | Immediate of Calculus.rule
    | Disabled of string
    | Partial of partial

  type selector_group = { group_name : string; rules : rule_selector list }

  val rule_selection :
    (string * Calculus.assumption) list -> Calculus.goal -> selector_group list

  val elim_assumption :
    conclusion:Calculus.goal ->
    assumption:Calculus.assumption ->
    idx:int ->
    (string * [ `ByAssumption | `Rule of Calculus.rule | `Partial of partial ])
    list

  module Part_type : sig
    type t

    val placeholder : t -> string
    val class_ : t -> string
  end

  (* Partial proof presentation *)
  type partial_formula_part =
    | T of string
    | I of { value : string; typ : Part_type.t; update : string -> partial }
    | F of Calculus.goal

  type partial_premise = {
    premise_formula : partial_formula_part list;
    premise_assumption : string option;
  }

  type partial_presentation = {
    premises : partial_premise list;
    apply : Calculus.rule option;
  }

  val present_partial : Calculus.goal -> partial -> partial_presentation
end

module type FORMULA = sig
  type t

  val to_string : t -> string
end

module Make
    (Goal : FORMULA)
    (Assumption : FORMULA) (Calculus : sig
      include
        Proof_tree.CALCULUS
          with type goal = Goal.t
           and type assumption = Assumption.t
           and type error = [ `Msg of string ]

      val assumption : int -> rule
    end)
    (Partial : PARTIALS with module Calculus = Calculus) : sig
  type state

  val sexp_of_state : state -> Sexplib0.Sexp.t
  val state_of_sexp : Goal.t -> Sexplib0.Sexp.t -> state

  type action

  val render : state -> action Ulmus.html
  val update : action -> state -> state
  val initial : Goal.t -> state
end
