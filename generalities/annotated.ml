type ('a, 'b) t =
  { detail : 'a
  ; annotation : 'b
  }

let add annotation detail =
  { detail; annotation }

let map f { detail; annotation } =
  { detail; annotation = f annotation }
