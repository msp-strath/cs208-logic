type state

val sexp_of_state : state -> Sexplib0.Sexp.t

val state_of_sexp :
  (string * Focused.assumption) list -> Focused.goal -> Sexplib0.Sexp.t -> state option

type action

val init :
  ?assumptions:(string * Focused.assumption) list -> Focused.goal -> state

val render :
  showtree:bool ->
  ?name:string ->
  ?assumps_name:string ->
  ?showlatex:bool ->
  state ->
  action Ulmus.html

val render_solution :
  showtree:bool ->
  ?name:string ->
  ?assumps_name:string ->
  ?showlatex:bool ->
  state ->
  'a Ulmus.html

val update : action -> state -> state

val instructions :
  ?implication:bool ->
  ?conjunction:bool ->
  ?disjunction:bool ->
  ?negation:bool ->
  ?quantifiers:bool ->
  ?equality:bool ->
  ?induction:bool ->
  unit ->
  'a Ulmus.html
