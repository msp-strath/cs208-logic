type t =
  | JString of string
  | JBool of bool
  | JInt of int
  | JArray of t list
  | JNull
  | JObject of (string * t) list

val to_document : t -> Pretty.document

val to_string : t -> string
