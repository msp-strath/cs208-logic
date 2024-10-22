module Location = Parser_util.Location

type 'a with_location =
  { detail : 'a
  ; location : Location.t
  }

type constructor_name = string

(* FIXME: distinguish constructor and domain/variable names. *)
type name = string

let equal_name = String.equal

module NameMap = Map.Make (String)

type term_detail =
  (* References to atoms and defined data *)
  | Apply of name with_location * term list
  | Next of term * term
  (* Constants *)
  | StrConstant of string
  | Constructor of string
  (* built-in atoms *)
  | True
  | False
  | Eq of term * term
  | Ne of term * term
  (* Logical operations on literals, clauses, and conjunctions of clauses *)
  | Neg of term
  | Or  of term list
  | And of term list
  | Implies of term * term
  | BigOr  of name * name with_location * term
  | BigAnd of name * name with_location * term
  (* JSON bits *)
  | JSONObject of term
  | JSONArray of term
  | Sequence of term list
  | Assign of term * term
  | For of name * name with_location * term
  | If of term * term
  | The of name * name with_location * term

and term = term_detail with_location

type tuple = name with_location list
type table = tuple with_location list

type param_spec =
  (name with_location * name with_location) list

type definition =
  | Term of term
  | Table of table

(* Declarations that can appear at the top-level in a file *)
type declaration =
  | Definition  of name with_location * param_spec * definition
  | Domain_decl of name with_location * constructor_name with_location list
  | Atom_decl of name with_location * param_spec
  | Dump of term
  | IfSat of term * term
  | AllSat of term * term
  | Print of term

type script = declaration list

type marking_script =
  { domains : (name * constructor_name list) list
  ; atoms   : (name * name list) list
  ; definitions : (name * term * term) list
  }
