%%

%public
term:
  | v=IDENT                                                             { Var v }
  | i=INTLIT                                                            { Fun (string_of_int i, []) }
  | f=IDENT; LPAREN; tms=separated_list(COMMA,term); RPAREN             { Fun (f, tms) }

%public
formula:
  | p=base_formula; AND; ps=separated_nonempty_list(AND, base_formula)  { Formula.ands (p::ps) }
  | p=base_formula; OR;  ps=separated_nonempty_list(OR, base_formula)   { Formula.ors (p::ps) }
  | p=base_formula; ARROW; q=arrow_formula                              { Imp (p, q) }
  | FORALL; x=IDENT; DOT; p=formula                                     { Forall (x, p) }
  | EXISTS; x=IDENT; DOT; p=formula                                     { Exists (x, p) }
  | p=base_formula                                                      { p }

arrow_formula:
  | p=base_formula; ARROW; q=arrow_formula                              { Imp (p, q) }
  | p=base_formula                                                      { p }

base_formula:
  | NOT; p=base_formula                                                 { Not p }
  | a=IDENT                                                             { Atom (a, []) }
  | a=IDENT; LPAREN; tms=separated_list(COMMA,term); RPAREN             { Atom (a, tms) }
  | t1=term; r=infix_rel; t2=term                                       { Atom (r, [t1; t2]) }
  | TRUE                                                                { True }
  | FALSE                                                               { False }
  | LPAREN; p=formula; RPAREN                                           { p }

infix_rel:
  | EQ         { "=" }
  | NE         { "!=" }
