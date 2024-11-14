open Parser_util

type 'a with_location =
  { detail : 'a
  ; location : Location.t
  }

type command =
  { head : string
  ; args : string list
  }

type proof = proof_detail with_location

and proof_detail =
  | Hole of string
  | Rule of command with_location * proof list

type item_detail =
  | Axiom of string with_location * string with_location
  | Theorem of string with_location * string with_location * proof

type item = item_detail with_location
