module type S = sig
  include Ulmus.S

  val initial : state
end

val opsem : Operational_semantics.Calculus.goal -> (module S)

val focusing :
  ?name:string ->
  ?assumps_name:string ->
  ?assumptions:(string * [ `V | `F of Fol_formula.formula ]) list ->
  Fol_formula.formula ->
  (module S)
