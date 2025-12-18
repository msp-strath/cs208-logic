(** Simple structured documents *)

(** {2 Type definitions} *)

type url = string

type inline =
    Text of url
  | Strong of inline list
  | Emphasis of inline list
  | Code of url
  | Link of { content : inline list; href : url; }

type block =
  | Paragraph of inline list
  | Preformatted of url
  | Monospace of Pretty.document
  | Itemise of block list list
  | Enumerate of block list list

type section =
  {
    title : url;
    content : block list;
    subsections : section list;
  }

type document =
  {
    title : url;
    authors : url list;
    preamble : block list;
    sections : section list;
  }

(** {2 Construction functions} *)

(** {3 Document Structure} *)

val document :
  title:string ->
  ?authors:string list ->
  ?preamble:block list -> ?sections:section list -> unit -> document

val section :
  title:string ->
  ?content:block list -> ?subsections:section list -> unit -> section

(** {3 Blocks} *)

val para : inline list -> block

val preformatted : string -> block

val monospace : Pretty.document -> block

val itemise : block list list -> block

val enumerate : block list list -> block

(** {3 Inilne elements} *)

val text : string -> inline

val textf : ('a, unit, string, inline) format4 -> 'a

val strong : inline list -> inline

(** {2 Rendering} *)

module ToPretty :
  sig
    val pretty_of_inline : inline -> Pretty.document
    val pretty_of_inlines : inline list -> Pretty.document
    val pretty_of_block : block -> Pretty.document
    val pretty_of_blocks : block list -> Pretty.document
    val pretty_of_section : int -> section -> Pretty.document
    val pretty_of_document : document -> Pretty.document
  end
