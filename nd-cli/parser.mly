%{
open Ast
open Parser_util
%}

%token AXIOM THEOREM PROOF END
%token<string> IDENTIFIER QUOTED QIDENT
%token COLON SEMICOLON DOT LBRACE RBRACE DASH
%token EOF

%start<item list> items

%%

items: ds=located(item)*; EOF { ds }

item:
| AXIOM; name=identifier; COLON; fmla=quoted
  { Axiom (name, fmla) }
| THEOREM; name=identifier; COLON; fmla=quoted;
  PROOF;
    p=located(proof);
  END
  { Theorem (name, fmla, p) }

identifier: i=located(IDENTIFIER) { i }

quoted: s=located(QUOTED) { s}

proof:
| name=QIDENT
  { Hole name }
| c=located(command); DOT
  { Rule (c, []) }
| c=located(command); SEMICOLON; p=located(proof)
  { Rule (c, [p]) }
| c=located(command); LBRACE; ps=list(DASH; p=located(proof) {p}); RBRACE
  { Rule (c, ps) }

command:
| head=IDENTIFIER; args=command_arg* { { head; args } }

command_arg:
| id=IDENTIFIER { id }
| q=QUOTED { q }

(* Add location information to a production *)
%inline
located(X): detail=X
    { { detail; location = Location.mk $startpos $endpos } }
