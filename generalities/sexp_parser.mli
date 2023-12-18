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

val sexp : sexp parser
(** [sexp] is the parser that returns the underlying s-expression
    value. It always succeeds. *)

val atom : string parser
(** [atom] is the parser that expects the input to be a single
    {!Atom}. It returns the string value attached to the atom. This
    parser fails if the input is a {!List}. *)

val list : 'a parser -> 'a list parser
(** [list p] expects the input to be a {!List} and uses the [p] parser
    to parse all the elements of that list. *)

val sequence : 'a seq_parser -> 'a parser

val match_tag : (string -> 'a seq_parser) -> 'a parser

val tagged : string -> 'a seq_parser -> 'a parser

val on_kind : atom:(string -> ('a, string) result) ->
              list:'a seq_parser ->
              'a parser

val ( let+? ) : 'a parser -> ('a -> ('b, string) result) -> 'b parser

val fix : ('a parser -> 'a parser) -> 'a parser

(** {3 Other kinds of parser} *)

val of_opt : (sexp -> 'a option) -> 'a parser

val of_conv : (sexp -> 'a) -> 'a parser

val to_conv : 'a parser -> (sexp -> 'a)

(** {2 Sequence parsers} *)

(** {3 Connectives} *)

val ( let* ) : 'a seq_parser -> ('a -> 'b seq_parser) -> 'b seq_parser

val ( let+ ) : 'a seq_parser -> ('a -> 'b) -> 'b seq_parser

val ( and+ ) : 'a seq_parser -> 'b seq_parser -> ('a * 'b) seq_parser

val return : 'a -> 'a seq_parser

val fail : string -> 'a seq_parser

val result : ('a, string) result -> 'a seq_parser

(** {3 Positional access} *)

val consume_next : 'a parser -> 'a seq_parser

val one : 'a parser -> 'a seq_parser
(** [one p] expects the sequence to consist of exactly one item which
    can be parsed by [p]. The parse fails if there is not exactly one
    item in the sequence. *)

val many : 'a parser -> 'a list seq_parser
(** [many p] expects the sequence to consist of zero or more items,
    each of which can be parsed with [p]. On success, it returns the
    list of parsed results in input order. *)

(** {3 Named Fields}

    The following sequence parsers treat a sequence of s-expressions
    as an associative array of the form [((field_nm ...) (field_nm
    ...) .. )]. *)

val consume_all : string -> 'a seq_parser -> 'a list seq_parser
(** [consume_all fld_nm parser]  *)

val consume_one : string -> 'a seq_parser -> 'a seq_parser

val consume_opt : string -> 'a seq_parser -> 'a option seq_parser

(** {3 End of sequence} *)

val assert_nothing_left : unit seq_parser
