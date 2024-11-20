type error = Location.t * string * string

let string_of_error (_location, message, lexeme) =
  match lexeme with
  | "" -> Printf.sprintf "At the end of the input, %s" message
  | _ -> Printf.sprintf "On the input '%s', %s" lexeme message

let string_of_error_with_location (location, message, lexeme) =
  match lexeme with
  | "" -> Printf.sprintf "At the end of the input, %s" message
  | _ -> Printf.sprintf "On the input '%s' at %s, %s" lexeme (Location.to_string location) message

module type PARSER = sig
  type token

  module MenhirInterpreter :
    MenhirLib.IncrementalEngine.INCREMENTAL_ENGINE with type token = token
end

module type LEXER = sig
  type token

  val token : Lexing.lexbuf -> token
end

module Make
    (Parser : PARSER)
    (Lexer : LEXER with type token = Parser.token) (Messages : sig
      val message : int -> string
    end) : sig
  val parse :
    (Lexing.position -> 'a Parser.MenhirInterpreter.checkpoint) ->
    string ->
    ('a, [> `Parse of error ]) result
end = struct
  module MI = Parser.MenhirInterpreter

  (* Plan: to use the same idea as CompCert's error messages and use $0,
     $1, etc. to refer to items on the parse stack. *)

  (* FIXME: this doesn't handle UTF-8 at all... *)
  let shorten s =
    if String.length s <= 35 then s
    else String.sub s 0 15 ^ "....." ^ String.sub s (String.length s - 15) 15

  let extract input spos epos =
    let spos = spos.Lexing.pos_cnum in
    let epos = epos.Lexing.pos_cnum in
    assert (spos >= 0);
    assert (spos <= epos);
    let str = String.sub input spos (epos - spos) in
    shorten
      (String.map
         (function '\x00' .. '\x1f' (*| '\x80' .. '\xff'*) -> ' ' | c -> c)
         str)

  let digit_of_char c = Char.(code c - code '0')

  (* Expand out references of the form $i to the piece of the input
     that is referred to by that element of the current parse
     stack. *)
  let expand_message input env message =
    let buf = Buffer.create (String.length message) in
    let add_extract sidx eidx =
      if sidx < eidx then Buffer.add_string buf "\"???\""
      else
        match (MI.get sidx env, MI.get eidx env) with
        | None, _ | _, None -> Buffer.add_string buf "\"???\""
        | Some (MI.Element (_, _, spos, _)), Some (MI.Element (_, _, _, epos))
          ->
            let text = extract input spos epos in
            Printf.bprintf buf "'%s'" text
    in
    let rec loop i =
      if i < String.length message then
        match message.[i] with
        | '$' -> read_stack_idx (i + 1)
        | '\n' when i + 1 = String.length message ->
            (* trim the newline off the end *)
            ()
        | c ->
            Buffer.add_char buf c;
            loop (i + 1)
    and read_stack_idx i =
      if i = String.length message then Buffer.add_char buf '$'
      else
        match message.[i] with
        | '0' .. '9' as c -> read_stack_idx_int (digit_of_char c) (i + 1)
        | c ->
            Buffer.add_char buf '$';
            Buffer.add_char buf c;
            loop (i + 1)
    and read_stack_idx_int r i =
      if i = String.length message then add_extract r r
      else
        match message.[i] with
        | '0' .. '9' as c ->
            read_stack_idx_int (digit_of_char c + (10 * r)) (i + 1)
        | '-' -> read_snd_stack_idx r (i + 1)
        | c ->
            add_extract r r;
            Buffer.add_char buf c;
            loop (i + 1)
    and read_snd_stack_idx r i =
      if i = String.length message then Printf.bprintf buf "$%d-" r
      else
        match message.[i] with
        | '0' .. '9' as c -> read_snd_stack_idx_int r (digit_of_char c) (i + 1)
        | c ->
            Printf.bprintf buf "$%d-" r;
            Buffer.add_char buf c;
            loop (i + 1)
    and read_snd_stack_idx_int r s i =
      if i = String.length message then add_extract r s
      else
        match message.[i] with
        | '0' .. '9' as c ->
            read_snd_stack_idx_int r (digit_of_char c + (10 * s)) (i + 1)
        | c ->
            add_extract r s;
            Buffer.add_char buf c;
            loop (i + 1)
    in
    loop 0;
    Buffer.contents buf

  let parse entrypoint input =
    let lexbuf = Lexing.from_string input in
    let rec loop cp =
      match cp with
      | MI.Accepted a -> Ok a
      | MI.InputNeeded _env ->
          let token = Lexer.token lexbuf in
          let spos = Lexing.lexeme_start_p lexbuf in
          let epos = Lexing.lexeme_end_p lexbuf in
          loop (MI.offer cp (token, spos, epos))
      | MI.Shifting _ | MI.AboutToReduce _ -> loop (MI.resume cp)
      | MI.HandlingError env ->
          let pos = Location.of_lexbuf lexbuf in
          let lexeme = Lexing.lexeme lexbuf in
          let state = MI.current_state_number env in
          let message =
            try Messages.message state
            with Not_found -> "undocumented parse error"
          in
          let message = expand_message input env message in
          Error (`Parse (pos, message, lexeme))
      | MI.Rejected -> assert false
    in
    let init_pos = lexbuf.Lexing.lex_curr_p in
    loop (entrypoint init_pos)
end
