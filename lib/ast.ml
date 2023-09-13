module Location = struct
  type t =
    | Source of { start : Lexing.position; endpos : Lexing.position }
    | Internal
  let mk start endpos = Source {start; endpos}
  let internal = Internal
  let to_string () = function
    | Source { start; _ } ->
       Printf.sprintf "line %d, column %d"
         start.pos_lnum
         start.pos_cnum (* FIXME *)
    | Internal ->
       "<internal>"
end

type 'a with_location =
  { detail : 'a
  ; location : Location.t
  }

type constructor_name = string
type name = string

type term_detail =
  | Apply of name with_location * term list
  (* Constants *)
  | IntConstant of int
  | Constructor of string
  (* built-in atoms *)
  | Eq of term * term
  | Ne of term * term
  (* Logical operations on literals, clauses, and conjunctions of clauses *)
  | Neg of term
  | Or  of term list
  | And of term list
  | Implies of term * term
  | BigOr  of name * name with_location * term
  | BigAnd of name * name with_location * term

and term = term_detail with_location

type declaration =
  | Definition  of name with_location * (name with_location * name with_location) list * term
  | Domain_decl of name with_location * constructor_name with_location list
  | Atom_decl of name with_location * (name with_location * name with_location) list


(******************************************************************************)

(* Declarations are either:

   domain timestep [0..n];
   domain state_component { A, B, C, D };

   -- declares a fresh atom
   atom state(t : timestep, component : state_component);

   define blump(blah a) {
     switch(a) {
     case A: TRUE
     case B:
     case C:
     case D:
     }
   }

   define blah(t) {
     state(t,A) OR state(t,B)
   }

   define bloo() {
     forall(x : timestep) { blah(t) }
   }
 *)
