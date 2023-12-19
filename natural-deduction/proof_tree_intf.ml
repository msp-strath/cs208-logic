module type CALCULUS = sig
  type goal

  type assumption

  type update

  val empty_update : update

  val update_goal : update -> goal -> goal

  val update_assumption : update -> assumption -> assumption

  type rule [@@deriving sexp]

  type error

  val apply :
    (string * assumption) list ->
    rule ->
    goal ->
    (((string * assumption) list * goal) list * update, error) result
end

module type HOLE = sig
  type t [@@deriving sexp]
  type goal

  val empty : goal -> t
end

module type PROOF_TREE = sig
  module Calculus : CALCULUS
  module Hole : HOLE with type goal = Calculus.goal

  type t
  type point

  (**{2 Creation of a proof tree} *)

  val init :
    ?content:Hole.t ->
    ?assumptions:(string * Calculus.assumption) list ->
    Calculus.goal ->
    t

  (**{2 Traversal of a proof tree} *)

  val fold :
    (point -> Hole.t -> 'a) ->
    (point -> Calculus.rule -> 'b list -> 'a) ->
    ((string * Calculus.assumption) list -> 'a -> 'b) ->
    t ->
    'b
  (** [fold f_hole f_rule f_box tree] folds over the proof tree
      [tree], using [f_hole] for each hole (providing the point and
      hole information), [f_rule] for each rule application, and
      [f_box] for each assumption box. The whole proof is within an
      assumption box. *)

  (**{2 Inspection of points in a proof tree} *)

  val up : point -> point option

  val root_goal : t -> Calculus.goal

  val root_assumptions : t -> (string * Calculus.assumption) list

  val goal : point -> Calculus.goal

  val assumptions : point -> (string * Calculus.assumption) list

  (**{2 Updating a point in a proof tree} *)

  val apply :
    Calculus.rule -> point -> (t, [> `RuleError of Calculus.error ]) result

  val set_hole : Hole.t -> point -> t

  (**{2 Unchecked representation} *)

  type tree = Hole of Hole.t | Rule of Calculus.rule * tree list
  [@@deriving sexp]

  val to_tree : t -> tree
  val subtree_of_point : point -> tree

  val of_tree :
    (string * Calculus.assumption) list ->
    Calculus.goal ->
    tree ->
    (t, [> `RuleError of Calculus.error | `LengthMismatch ]) result

  val insert_tree :
    tree ->
    point ->
    (t, [> `RuleError of Calculus.error | `LengthMismatch ]) result
end

module type Proof_tree = sig
  module type CALCULUS = CALCULUS
  module type HOLE = HOLE
  module type PROOF_TREE = PROOF_TREE

  module Make (Calculus : CALCULUS) (Hole : HOLE with type goal = Calculus.goal) :
    PROOF_TREE with module Calculus = Calculus and module Hole = Hole
end
