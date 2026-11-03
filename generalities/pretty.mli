type +'tag document

val empty : 'tag document
val ( ^^ ) : 'tag document -> 'tag document -> 'tag document
val concat : 'tag document Seq.t -> 'tag document

val text : string -> 'tag document
val textf : ('a, unit, string, 'tag document) format4 -> 'a

val tag : 'tag -> 'tag document -> 'tag document

val break_with : string -> 'tag document
val alignment_spaces : int -> 'tag document
val nest : int -> 'tag document -> 'tag document
val align : 'tag document -> 'tag document
val group : 'tag document -> 'tag document

val map : ('tag1 -> 'tag2) -> 'tag1 document -> 'tag2 document

val break : 'tag document
val (^/^) : 'tag document -> 'tag document -> 'tag document

(** [break_words str] separates the string [str] into words and
    constructs a document by interspersing [group break] between each
    word. This has the effect of word wrapping [str]. *)
val break_words : string -> 'tag document

(* FIXME:
   1. configurable output targets
   2. styles (bold, italic, simple colours)
   3. flat output
   4. typed document constructor combinators
 *)
val print : ?width:int -> 'tag document -> unit

val to_string : ?width:int -> 'tag document -> string

val output_to_channel : Out_channel.t -> ?width:int -> 'tag document -> unit

val to_buffer : ?width:int -> Buffer.t -> 'tag document -> unit

val to_flat_string : 'tag document -> string

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

val format_tagged :
  (module TAGGED_OUTPUT with type tag = 'tag and type output_doc = 'out) ->
  ?width:int -> 'tag document -> 'out
