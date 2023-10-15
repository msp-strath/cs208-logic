type t
type v

val create : unit -> t
val gen : t -> v
val add_implies : t -> v -> v -> v
val add_conj : t -> v list -> v
val add_disj : t -> v list -> v
val add_not : t -> v -> v
val add_assert : t -> v -> unit
val add_clause : t -> (bool * v) list -> unit
val solve : t -> [ `UNSAT | `SAT of v -> bool ]

val solve_with_assumptions :
  t -> (v * bool) list -> [ `UNSAT | `SAT of v -> bool ]
