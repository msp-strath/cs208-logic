open Ast

type kind =
  | Constant
  | Literal
  | Clause
  | Clauses
  | Domain of name
  | Json
  | JsonSequence
  | Assignments
  | Symbol

(*  Constant <= Literal <= Clause <= Clauses <= Json <= JsonSequence
    Domain _ <= Symbol <= Json
    Assignments
 *)

let is_sub_kind k1 k2 =
  match k1, k2 with
  | Constant, (Constant | Literal | Clause | Clauses | Json | JsonSequence) -> true
  | Literal,  (Literal | Clause | Clauses | Json | JsonSequence) -> true
  | Clause,   (Clause | Clauses | Json | JsonSequence) -> true
  | Clauses,  (Clauses | Json | JsonSequence) -> true
  | Domain dnm1, Domain dnm2 -> equal_name dnm1 dnm2
  | Domain _, (Symbol | Json | JsonSequence) -> true
  | Symbol,   (Symbol | Json | JsonSequence) -> true
  | Json,     (Json | JsonSequence) -> true
  | JsonSequence, JsonSequence -> true
  | Assignments, Assignments -> true
  | _, _ -> false

let intersect_kind k1 k2 =
  match k1, k2 with
  | Constant, Constant
  | Constant, (Literal | Clause | Clauses | Json | JsonSequence)
  | (Literal | Clause | Clauses | Json | JsonSequence), Constant ->
     Some Constant
  | Constant, (Assignments | Symbol | Domain _)
  | (Assignments | Symbol | Domain _), Constant ->
     None
  | Literal, Literal
  | Literal, (Clause | Clauses | Json | JsonSequence)
  | (Clause | Clauses | Json | JsonSequence), Literal ->
     Some Literal
  | Literal, (Assignments | Symbol | Domain _)
  | (Assignments | Symbol | Domain _), Literal ->
     None
  | Clause, Clause
  | Clause, (Clauses | Json | JsonSequence)
  | (Clauses | Json | JsonSequence), Clause ->
     Some Clause
  | Clause, (Assignments | Symbol | Domain _)
  | (Assignments | Symbol | Domain _), Clause ->
     None
  | Clauses, Clauses
  | Clauses, (Json | JsonSequence)
  | (Json | JsonSequence), Clauses ->
     Some Clauses
  | Clauses, (Assignments | Symbol | Domain _)
  | (Assignments | Symbol | Domain _), Clauses ->
     None
  | Domain dnm1, Domain dnm2 ->
     if equal_name dnm1 dnm2 then Some k1 else None
  | Domain nm, (Symbol | Json | JsonSequence)
  | (Symbol | Json | JsonSequence), Domain nm ->
     Some (Domain nm)
  | Domain _, Assignments
  | Assignments, Domain _ ->
     None
  | Symbol, Symbol
  | Symbol, (Json | JsonSequence)
  | (Json | JsonSequence), Symbol ->
     Some Symbol
  | Symbol, Assignments
  | Assignments, Symbol ->
     None
  | Json, Json
  | Json, JsonSequence
  | JsonSequence, Json ->
     Some Json
  | Json, Assignments
  | Assignments, Json ->
     None
  | JsonSequence, JsonSequence ->
     Some JsonSequence
  | JsonSequence, Assignments
  | Assignments, JsonSequence ->
     None
  | Assignments, Assignments ->
     Some Assignments

let string_of_kind = function
  | Constant -> "Constant"
  | Literal -> "Literal"
  | Clause -> "Clause"
  | Clauses -> "Clauses"
  | Domain name -> Printf.sprintf "Domain(%s)" name
  | Json -> "Json"
  | JsonSequence -> "JsonSequence"
  | Assignments -> "Assignments"
  | Symbol -> "Symbol"

type operation_type = kind list * kind

let apply_operation (expected_types, result_type) given_types =
  if List.length expected_types = List.length given_types then
    if List.for_all2 is_sub_kind given_types expected_types then
      `Type result_type
    else
      `Top
  else
    `Top
