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
  state ->
  action Ulmus.html

val render_solution :
  showtree:bool ->
  ?name:string ->
  state ->
  'a Ulmus.html

val update : action -> state -> state
