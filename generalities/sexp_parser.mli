(** Sexp parsing *)

type sexp = Sexplib.Type.t = Atom of string | List of sexp list
(** The sexpression type *)

type error = (string, sexp) Annotated.t
(** Parse errors are descriptions annotated with the part of the input
    affected. *)

type 'a parser = sexp -> ('a, error) result
(** Direct parsers either extract a value from an {sexp}ression, or
    fail with an error. *)

type 'a seq_parser
(** Sequence parsers parse sequences of {sexp}ressions. Sequences can
    be accessed in random order or sequentially. *)

(** {2 Direct Sexp parsers} *)

val atom : string parser

val sequence : 'a seq_parser -> 'a parser

val list : 'a parser -> 'a list parser

val of_opt : (sexp -> 'a option) -> 'a parser

val of_conv : (sexp -> 'a) -> 'a parser

val to_conv : 'a parser -> (sexp -> 'a)

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
(** [one p] expects the sequence to consist of exactly one item which can
    be parsed by [p]. *)

val many : 'a parser -> 'a list seq_parser
(** [many p] expects the sequence to consist of zero or more items,
    each of which can be parsed with [p]. On success, it returns the
    list of parsed results in input order. *)

(** {2 Random access fields} *)

val consume_all : string -> 'a seq_parser -> 'a list seq_parser

val consume_one : string -> 'a seq_parser -> 'a seq_parser

val consume_opt : string -> 'a seq_parser -> 'a option seq_parser

(** {2 Positional access} *)

val consume_next : 'a parser -> 'a seq_parser

(** {2 End of sequence} *)

val assert_nothing_left : unit seq_parser
