%{
    open Fol_formula
    open Hoare_calculus
%}

%token <string> IDENT
%token <int> INTLIT
%token AND
%token OR
%token NOT
%token LPAREN
%token RPAREN
%token ARROW
%token EOF
%token COMMA
%token DOT
%token FORALL
%token EXISTS
%token TRUE
%token FALSE
%token EQ
%token NE
%token UNKNOWN

// %token PLUS

// Programming bits
%token IF WHILE ASSERT ASSIGN END

%start<Hoare_calculus.program_rule> whole_command

%%

whole_command:
| c=command; EOF { c }

command:
| v=IDENT; ASSIGN; t=term                  { Assign (v, t) }
| IF; LPAREN; t=boolean_expr; RPAREN        { If t }
| WHILE; LPAREN; t=boolean_expr; RPAREN     { While t }
| ASSERT; LPAREN; f=formula; RPAREN         { Assert f }
| END                                       { End }

boolean_expr:
| t1=term; EQ; t2=term { Rel (t1, Eq, t2) }
| t1=term; NE; t2=term { Rel (t1, Ne, t2) }

/* terms and formulas etc. */

term:
  | v=IDENT                                                             { Var v }
  | i=INTLIT                                                            { Fun (string_of_int i, []) }
  | f=IDENT; LPAREN; tms=separated_list(COMMA,term); RPAREN             { Fun (f, tms) }

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
