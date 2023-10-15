(* val opsem : Operational_semantics.Calculus.goal -> (module Ulmus.COMPONENT) *)

(*
val focusing :
  ?name:string ->
  ?assumps_name:string ->
  ?assumptions:(string * [ `V | `F of Fol_formula.formula ]) list ->
  Fol_formula.formula ->
  (module Ulmus.COMPONENT)
 *)

val focusing_component : string -> (module Ulmus.COMPONENT)

val tree_component : string -> (module Ulmus.COMPONENT)
