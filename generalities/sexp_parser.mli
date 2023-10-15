(** Sexp parsing *)

type sexp = Sexplib.Type.t = Atom of string | List of sexp list

type error = (string, sexp) Annotated.t

type 'a parser = sexp -> ('a, error) result

type 'a seq_parser

(** {2 Direct Sexp parsers} *)

val atom : string parser

val list : 'a seq_parser -> 'a parser

val match_tag : (string -> 'a seq_parser) -> 'a parser

val tagged : string -> 'a seq_parser -> 'a parser

val ( let+? ) : 'a parser -> ('a -> ('b, string) result) -> 'b parser

(** {2 Sequence parsers} *)

val ( let* ) : 'a seq_parser -> ('a -> 'b seq_parser) -> 'b seq_parser

val return : 'a -> 'a seq_parser

val fail : string -> 'a seq_parser

val lift : ('a, string) result -> 'a seq_parser

(** {3 Uniform parsers} *)

val one : 'a parser -> 'a seq_parser

val many : 'a parser -> 'a list seq_parser

(** {2 Random access fields} *)

val consume_all : string -> 'a seq_parser -> 'a list seq_parser

val consume_one : string -> 'a seq_parser -> 'a seq_parser

val consume_opt : string -> 'a seq_parser -> 'a option seq_parser

(** {2 Positional} *)

val consume_next : 'a parser -> 'a seq_parser

val assert_nothing_left : unit seq_parser
