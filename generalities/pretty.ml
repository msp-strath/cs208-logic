(* Specification is that a group is formatted flat if the current
   column plus the flat_width plus the context's break_distance is
   less than the width, otherwise format with breaks.
 *)

type break_distance =
  { distance : int
  ; closed   : bool
  }

let ( ++ ) bw1 bw2 =
  if bw1.closed then
    bw1
  else
    { distance = bw1.distance + bw2.distance
    ; closed   = bw2.closed
    }

let ( +/ ) {distance; closed} bd =
  if closed then distance else distance + bd

type doc =
  | Empty
  | Concat of doc * doc * break_distance
  | Text of string
  | Break of string
  | AlignSpaces of int
  | Nest of int * doc
  | Align of doc
  | Group of doc * int

type document =
  { doc         : doc
  ; break_width : break_distance
  ; flat_width  : int
  }

let empty =
  { doc = Empty
  ; break_width = { distance = 0; closed = false }
  ; flat_width = 0
  }

let ( ^^ ) doc1 doc2 =
  { doc = Concat (doc1.doc, doc2.doc, doc2.break_width)
  ; break_width = doc1.break_width ++ doc2.break_width
  ; flat_width = doc1.flat_width + doc2.flat_width
  }

let concat = Seq.fold_left (^^) empty

let text s =
  let l = String.length s in
  { doc = Text s
  ; break_width = { distance = l; closed = false }
  ; flat_width = l
  }

let textf fmt = Printf.ksprintf text fmt

let break_with s =
  { doc = Break s
  ; flat_width = String.length s
  ; break_width = { distance = 0; closed = true }
  }

let break = break_with " "

let alignment_spaces n =
  { doc = AlignSpaces n
  ; flat_width = 0
  ; break_width = { distance = n; closed = false }
  }

let nest i doc =
  { doc = Nest (i, doc.doc)
  ; flat_width = doc.flat_width
  ; break_width = doc.break_width
  }

let align doc =
  { doc = Align doc.doc
  ; flat_width = doc.flat_width
  ; break_width = doc.break_width
  }

let group doc =
  { doc = Group (doc.doc, doc.flat_width)
  ; flat_width = doc.flat_width
  ; break_width = doc.break_width
  }

(******************************************************************************)
(* Output of documents *)

let emit =
  print_string
let emit_newline =
  print_newline
let emit_spaces n =
  print_string (String.make n ' ')

let output ?(width=80) document =
  let rec flat = function
    | Empty | AlignSpaces _ ->
       ()
    | Nest (_, doc) | Align doc | Group (doc, _) ->
       flat doc
    | Concat (doc1, doc2, _) ->
       flat doc1; flat doc2
    | Text s | Break s ->
       emit s
  in
  let rec process col bd indent = function
    | Empty ->
       col
    | Concat (doc1, doc2, bd_inner) ->
       let col = process col (bd_inner +/ bd) indent doc1 in
       process col bd indent doc2
    | Text s ->
       emit s;
       col + String.length s
    | Break _ ->
       emit_newline ();
       emit_spaces indent;
       indent
    | AlignSpaces n ->
       emit_spaces n;
       col + n
    | Nest (i, doc) ->
       process col bd (indent + i) doc
    | Align doc ->
       process col bd col doc
    | Group (doc, flat_width) ->
       if col + flat_width + bd <= width then
         (flat doc; col + flat_width)
       else
         process col bd indent doc
  in
  let _ = process 0 0 0 document.doc in
  ()
