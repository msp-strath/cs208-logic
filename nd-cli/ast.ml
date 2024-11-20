open Parser_util
open Generalities

type 'a with_location = ('a, Location.t) Annotated.t

type command =
  { head : string
  ; args : string list
  }

type proof = proof_detail with_location

and proof_detail =
  | Hole of string
  | Rule of command with_location * proof list

type item =
  | Axiom of string with_location * string with_location
  | Theorem of string with_location * string with_location * proof * unit with_location
