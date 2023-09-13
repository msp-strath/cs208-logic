%{ open Ast %}

%token <string> IDENT
%token <string> CONSTRUCTOR_NAME
(* %token <int> NATURAL *)
%token OP_AND
%token OP_OR
%token OP_EQ
%token OP_NE
%token OP_NOT
%token OP_IMPLIES

%token FORALL
%token SOME

%token DEFINITION
%token ATOM
%token DOMAIN

%token COMMA
%token COLON
%token LBRACE
%token RBRACE
%token LPAREN
%token RPAREN

%token EOF

%start<Ast.declaration list> structure
%start<Ast.declaration> item

%%

structure:
| items=list(item); EOF
  { items }

item:
| DEFINITION; name=identifier; LPAREN; args=separated_list(COMMA, arg_spec); RPAREN;
  LBRACE; body=term; RBRACE
  { Definition (name, args, body) }
| DEFINITION; name=identifier;
  LBRACE; body=term; RBRACE
  { Definition (name, [], body) }
| DOMAIN; name=identifier; LBRACE; constructors=separated_list(COMMA, constructor); RBRACE
  { Domain_decl (name, constructors) }
| ATOM; name=identifier; LPAREN; args=separated_list(COMMA, arg_spec); RPAREN
  { Atom_decl (name, args) }
| ATOM; name=identifier
  { Atom_decl (name, []) }

arg_spec:
| nm=identifier; COLON; domain=identifier
  { (nm, domain) }

identifier:
| name=IDENT
  { { detail=name; location = Location.mk $startpos $endpos } }

constructor:
| name=CONSTRUCTOR_NAME
  { { detail=name; location = Location.mk $startpos $endpos } }

term:
| t1=connected_term; OP_IMPLIES; t2=term
  { { detail = Implies (t1, t2); location = Location.mk $startpos $endpos } }
| t=connected_term
  { t }

connected_term:
| t=quant_term; OP_AND; ts=separated_nonempty_list(OP_AND, quant_term)
  { { detail = And (t::ts); location = Location.mk $startpos $endpos } }
| t=quant_term; OP_OR;  ts=separated_nonempty_list(OP_OR, quant_term)
  { { detail = Or (t::ts); location = Location.mk $startpos $endpos } }
| t=quant_term
  { t }

quant_term:
| FORALL; LPAREN; nm=IDENT; COLON; domain=identifier; RPAREN; LBRACE; body=term; RBRACE
  { { detail = BigAnd (nm, domain, body); location = Location.mk $startpos $endpos } }
| SOME; LPAREN; nm=IDENT; COLON; domain=identifier; RPAREN; LBRACE; body=term; RBRACE
  { { detail = BigOr (nm, domain, body); location = Location.mk $startpos $endpos } }
| t=eq_term
  { t }

eq_term:
| t1=base_term; OP_EQ; t2=base_term
  { { detail = Eq (t1, t2); location = Location.mk $startpos $endpos } }
| t1=base_term; OP_NE; t2=base_term
  { { detail = Ne (t1, t2); location = Location.mk $startpos $endpos } }
| t=base_term
  { t }

base_term:
| OP_NOT; t=base_term
  { { detail = Neg t; location = Location.mk $startpos $endpos } }
| nm=identifier
  { { detail = Apply(nm, []); location = Location.mk $startpos $endpos } }
| nm=identifier; LPAREN; terms=separated_list(COMMA,term); RPAREN
  { { detail = Apply(nm, terms); location = Location.mk $startpos $endpos } }
| LPAREN; t=term; RPAREN
  { t }
(* | TRUE
| FALSE *)
| cnm=CONSTRUCTOR_NAME
  { { detail = Constructor cnm; location = Location.mk $startpos $endpos } }
