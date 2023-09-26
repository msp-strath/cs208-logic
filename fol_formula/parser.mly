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

%start<Formula.t> whole_formula
%start<Term.t> whole_term

%%

whole_term:
  | t=term; EOF                                                         { t }

whole_formula:
  | p=formula; EOF                                                      { p }
