(* Specification is that a group is formatted flat if the current column
   plus the flat_width plus the context's break_distance is less than
   the width, otherwise format with breaks.
 *)

type break_distance = {
  distance : int;
  closed   : bool;
}

let ( ++ ) bw1 bw2 =
  if bw1.closed then
    bw1
  else
    {
      distance = bw1.distance + bw2.distance;
      closed   = bw2.closed;
    }

let ( +/ ) {distance; closed} bd =
  if closed then distance else distance + bd

type 'tag doc =
  | Empty
  | Concat of 'tag doc * 'tag doc * break_distance
  | Text of string
  | Tag of 'tag * 'tag doc
  | Break of string
  | AlignSpaces of int
  | Nest of int * 'tag doc
  | Align of 'tag doc
  | Group of 'tag doc * int

let rec map_doc f = function
  | Empty -> Empty
  | Concat (doc1, doc2, bd) ->
    Concat (map_doc f doc1, map_doc f doc2, bd)
  | Text _ | Break _ | AlignSpaces _ as doc ->
    doc
  | Tag (t, doc) ->
    Tag (f t, map_doc f doc)
  | Nest (i, doc) ->
    Nest (i, map_doc f doc)
  | Align doc ->
    Align (map_doc f doc)
  | Group (doc, d) ->
    Group (map_doc f doc, d)

type 'tag document = {
  doc         : 'tag doc;
  break_width : break_distance;
  flat_width  : int;
}

let map f d =
  {d with doc = map_doc f d.doc}

let empty = {
  doc = Empty;
  break_width = { distance = 0; closed = false };
  flat_width = 0;
}

let ( ^^ ) doc1 doc2 = {
  doc = Concat (doc1.doc, doc2.doc, doc2.break_width);
  break_width = doc1.break_width ++ doc2.break_width;
  flat_width = doc1.flat_width + doc2.flat_width;
}

let concat docs = Seq.fold_left (^^) empty docs

let text s =
  let l = String.length s in
  {
    doc = Text s;
    break_width = { distance = l; closed = false };
    flat_width = l;
  }

let tag t d = {
  doc = Tag (t, d.doc);
  flat_width = d.flat_width;
  break_width = d.break_width;
}

let textf fmt = Printf.ksprintf text fmt

let break_with s = {
  doc = Break s;
  flat_width = String.length s;
  break_width = { distance = 0; closed = true };
}

let alignment_spaces n = {
  doc = AlignSpaces n;
  flat_width = 0;
  break_width = { distance = n; closed = false };
}

let nest i doc = {
  doc = Nest (i, doc.doc);
  flat_width = doc.flat_width;
  break_width = doc.break_width;
}

let align doc = {
  doc = Align doc.doc;
  flat_width = doc.flat_width;
  break_width = doc.break_width;
}

let group doc = {
  doc = Group (doc.doc, doc.flat_width);
  flat_width = doc.flat_width;
  break_width = doc.break_width;
}

(******************************************************************************)
(* Derived *)

let break = break_with " "

let break_words str =
  str
  |> Seq_ext.words
  |> Seq.map text
  |> Seq_ext.intersperse (group break)
  |> concat

let (^/^) d1 d2 = d1 ^^ break ^^ d2

(* let of_seq docs = Seq.fold_left (^^) empty docs *)

(******************************************************************************)
(* Structured output of documents, using tags. *)
module type TAGGED_OUTPUT = sig
  type tag

  type output_doc

  val empty : output_doc
  val (^^) : output_doc -> output_doc -> output_doc
  val text : string -> output_doc
  val spaces : int -> output_doc
  val tag : tag -> output_doc -> output_doc
  val line_break : output_doc
end

let format_tagged (type tag) (type output) (module Out : TAGGED_OUTPUT with type tag = tag and type output_doc = output) ?(width=80) document =
  let open Out in
  let rec flat = function
    | Empty | AlignSpaces _ ->
      empty
    | Nest (_, doc) | Align doc | Group (doc, _) ->
      flat doc
    | Concat (doc1, doc2, _) ->
      flat doc1 ^^ flat doc2
    | Text s | Break s ->
      text s
    | Tag (t, doc) ->
      tag t (flat doc)
  in
  let rec process col bd indent = function
    | Empty ->
      col, empty
    | Concat (doc1, doc2, bd_inner) ->
      let col, odoc1 = process col (bd_inner +/ bd) indent doc1 in
      let col', odoc2 = process col bd indent doc2 in
      col', odoc1 ^^ odoc2
    | Text s ->
      col + String.length s, text s
    | Break _ ->
      indent, line_break ^^ spaces indent
    | AlignSpaces n ->
      col + n, spaces n
    | Nest (i, doc) ->
      process col bd (indent + i) doc
    | Align doc ->
      process col bd col doc
    | Group (doc, flat_width) ->
      if col + flat_width + bd <= width then
        (col + flat_width, flat doc)
      else
        process col bd indent doc
    | Tag (t, doc) ->
      let col, odoc = process col bd indent doc in
      col, tag t odoc
  in
  let _col, outdoc = process 0 0 0 document.doc in
  outdoc

(******************************************************************************)
(* Output of documents, ignoring tags *)

type output =
  { emit         : string -> unit
  ; emit_newline : unit -> unit
  ; emit_spaces  : int -> unit
  }

let output_of_channel ch =
  { emit         = Out_channel.output_string ch
  ; emit_newline = (fun () -> Out_channel.output_char ch '\n')
  ; emit_spaces  = (fun n -> Out_channel.output_string ch (String.make n ' '))
  }

let output_of_buffer b =
  { emit         = Buffer.add_string b
  ; emit_newline = (fun () -> Buffer.add_string b "\n")
  ; emit_spaces  = (fun n -> Buffer.add_string b (String.make n ' '))
  }

let output_flat output document =
  let { emit; _ } = output in
  let rec flat = function
    | Empty | AlignSpaces _ ->
       ()
    | Nest (_, doc) | Align doc | Group (doc, _) | Tag (_, doc) ->
       flat doc
    | Concat (doc1, doc2, _) ->
       flat doc1; flat doc2
    | Text s | Break s ->
       emit s
  in
  flat document

let output ?(width=80) output document =
  let { emit; emit_newline; emit_spaces } = output in
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
    | Tag (_, doc) ->
       process col bd indent doc
    | Group (doc, flat_width) ->
       if col + flat_width + bd <= width then
         (output_flat output doc; col + flat_width)
       else
         process col bd indent doc
  in
  let _ = process 0 0 0 document.doc in
  ()

let print ?width document =
  let o = output_of_channel Out_channel.stdout in
  output ?width o document

let output_to_channel ch ?width document =
  let o = output_of_channel ch in
  output ?width o document

let to_buffer ?width b document =
  let o = output_of_buffer b in
  output ?width o document

let to_string ?width document =
  let b = Buffer.create 8192 in
  to_buffer ?width b document;
  Buffer.contents b

let to_flat_string document =
  let b = Buffer.create 8192 in
  let o = output_of_buffer b in
  output_flat o document.doc;
  Buffer.contents b
