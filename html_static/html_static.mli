(** Generation of HTML in string form. *)

include Html_sig.S
(** Supports the generic HTML generation interface. *)

val raw_text : string -> _ t
(** [raw_text str] produces a document consisting of [str] without
    escaping any of the HTML-sensitive characters. FIXME: better
    description. *)

val raw_attr : string -> string -> _ attribute

val of_seq : 'a t Seq.t -> 'a t

(** Rendering of HTML documents to various kinds of outputs. *)
module Render : sig
  val to_buffer : ?doctype:bool -> Buffer.t -> _ t -> unit
  val to_string : ?doctype:bool -> _ t -> string
  val to_channel : ?doctype:bool -> out_channel -> _ t -> unit
  val print : ?doctype:bool -> _ t -> unit
  val to_custom : ?doctype:bool -> (string -> unit) -> _ t -> unit
end
