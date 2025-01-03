type document

val empty : document
val ( ^^ ) : document -> document -> document
val concat : document Seq.t -> document

val text : string -> document
val textf : ('a, unit, string, document) format4 -> 'a

val break_with : string -> document
val alignment_spaces : int -> document
val nest : int -> document -> document
val align : document -> document
val group : document -> document

val break : document

(** [break_words str] separates the string [str] into words and
    constructs a document by interspersing [group break] between each
    word. This has the effect of word wrapping [str]. *)
val break_words : string -> document

(* FIXME:
   1. configurable output targets
   2. styles (bold, italic, simple colours)
   3. flat output
   4. typed document constructor combinators
 *)
val print : ?width:int -> document -> unit

val to_string : ?width:int -> document -> string

val output_to_channel : Out_channel.t -> ?width:int -> document -> unit

val to_buffer : ?width:int -> Buffer.t -> document -> unit

val to_flat_string : document -> string
