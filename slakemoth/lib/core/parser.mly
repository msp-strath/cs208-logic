%{ open Ast %}

%token <string> IDENT
%token <string> CONSTRUCTOR_NAME
%token <string> STRING_LITERAL
%token OP_AND
%token OP_OR
%token OP_EQ
%token OP_NE
%token OP_NOT
%token OP_IMPLIES
%token TRUE FALSE

%token FORALL
%token SOME
%token DEFINE
%token ATOM
%token DOMAIN
%token KW_DUMP KW_IFSAT KW_FOR KW_IF KW_ALLSAT KW_PRINT NEXT THE TABLE

%token COMMA
%token COLON
%token LBRACE RBRACE
%token LPAREN RPAREN
%token LBRACK RBRACK

%token EOF UNKNOWN

%start<Ast.declaration list> structure
%start<Ast.marking_script> marking_script

%%

structure:
| items=list(item); EOF
  { items }

marking_script:
| domains=list(domain_decl); atoms=list(atom_decl);
  definitions=list(check_definition); EOF
  { { domains; atoms; definitions } }

check_definition:
| DEFINE; name=identifier; LBRACE; body=term; RBRACE; json=term
  { (name.detail, body, json) }

domain_decl:
| DOMAIN; name=identifier; LBRACE; constructors=separated_list(COMMA, constructor); RBRACE
  { (name.detail, List.map (fun x -> x.detail) constructors) }

atom_decl:
| ATOM; name=identifier; param_spec=param_spec
  { (name.detail, List.map (fun (_,x) -> x.detail) param_spec) }


item:
| DEFINE; name=identifier; param_spec=param_spec; LBRACE; body=term; RBRACE
  { Definition (name, param_spec, Term body) }
| DEFINE; name=identifier; param_spec=param_spec; TABLE; LBRACE; items=list(tuple); RBRACE
  { Definition (name, param_spec, Table items) }
| DOMAIN; name=identifier; LBRACE; constructors=separated_list(COMMA, constructor); RBRACE
  { Domain_decl (name, constructors) }
| ATOM; name=identifier; param_spec=param_spec
  { Atom_decl (name, param_spec) }
| cmd=print_command; LPAREN; t=term; RPAREN
  { cmd t }
| cmd=solve_command; LPAREN; t1=term; RPAREN; t2=base_term
  { cmd t1 t2 }

param_spec:
| LPAREN; args=separated_list(COMMA, binding); RPAREN
  { args }
| (* empty *)
  { [] }

print_command:
| KW_DUMP { fun t -> Dump t }
| KW_PRINT { fun t -> Print t }

solve_command:
| KW_IFSAT { fun t1 t2 -> IfSat (t1, t2) }
| KW_ALLSAT { fun t1 t2 -> AllSat (t1, t2) }

tuple:
| LPAREN; values=separated_list(COMMA, constructor); RPAREN
  { { detail=values; location = Location.mk $startpos $endpos } }

binding:
| nm=identifier; COLON; domain=identifier
  { (nm, domain) }

identifier:
| name=IDENT
  { { detail=name; location = Location.mk $startpos $endpos } }

constructor:
| name=CONSTRUCTOR_NAME
  { { detail=name; location = Location.mk $startpos $endpos } }

term:
| t=quant_term
  { t }

quant_term:
| q=quantifier; LPAREN; nm=IDENT; COLON; domain=identifier; RPAREN; body=quant_term
  { { detail = q (nm, domain) body; location = Location.mk $startpos $endpos } }
| KW_IF; LPAREN; t=term; RPAREN; body=quant_term
  { { detail = If (t, body); location = Location.mk $startpos $endpos } }
| t=implication_term
  { t }

quantifier:
| FORALL { fun (nm, domain) body -> BigAnd (nm, domain, body) }
| SOME   { fun (nm, domain) body -> BigOr (nm, domain, body) }
| KW_FOR { fun (nm, domain) body -> For (nm, domain, body) }
| THE    { fun (nm, domain) body -> The (nm, domain, body) }

implication_term:
| t1=eq_term; OP_IMPLIES; t2=implication_term
  { { detail = Implies (t1, t2); location = Location.mk $startpos $endpos } }
| t=connected_term
  { t }

connected_term:
| t=eq_term; OP_AND; ts=separated_nonempty_list(OP_AND, eq_term)
  { { detail = And (t::ts); location = Location.mk $startpos $endpos } }
| t=eq_term; OP_OR;  ts=separated_nonempty_list(OP_OR, eq_term)
  { { detail = Or (t::ts); location = Location.mk $startpos $endpos } }
| t=eq_term; COMMA; ts=separated_nonempty_list(COMMA, eq_term)
  { { detail = Sequence (t::ts); location = Location.mk $startpos $endpos } }
| t=eq_term
  { t }

eq_term:
| t1=base_term; op=binop; t2=base_term
  { { detail = op t1 t2; location = Location.mk $startpos $endpos } }
| t=base_term
  { t }

binop:
| OP_EQ { fun t1 t2 -> Eq (t1, t2) }
| OP_NE { fun t1 t2 -> Ne (t1, t2) }
| COLON { fun t1 t2 -> Assign (t1, t2) }

base_term:
| OP_NOT; t=base_term
  { { detail = Neg t; location = Location.mk $startpos $endpos } }
| NEXT; LPAREN; t1=base_term; COMMA; t2=base_term; RPAREN
  { { detail = Next (t1, t2); location = Location.mk $startpos $endpos } }
| nm=identifier
  { { detail = Apply(nm, []); location = Location.mk $startpos $endpos } }
| nm=identifier; LPAREN; terms=separated_list(COMMA,base_term); RPAREN
  { { detail = Apply(nm, terms); location = Location.mk $startpos $endpos } }
| LPAREN; t=term; RPAREN
  { t }
(* FIXME: empty arrays and objects *)
| LBRACE; t=term; RBRACE
  { { detail = JSONObject t; location = Location.mk $startpos $endpos } }
| LBRACK; t=term; RBRACK
  { { detail = JSONArray t; location = Location.mk $startpos $endpos } }
| cnm=CONSTRUCTOR_NAME
  { { detail = Constructor cnm; location = Location.mk $startpos $endpos } }
| s=STRING_LITERAL
  { { detail = StrConstant s; location = Location.mk $startpos $endpos } }
| TRUE
  { { detail = True; location = Location.mk $startpos $endpos } }
| FALSE
  { { detail = False; location = Location.mk $startpos $endpos } }
