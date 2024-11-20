%{
open Ast
open Parser_util
open Generalities
%}

%token AXIOM THEOREM PROOF END
%token<string> IDENTIFIER QUOTED QIDENT
%token COLON SEMICOLON DOT LBRACE RBRACE DASH
%token EOF

%start<item list> items

%%

items: ds=item*; EOF { ds }

item:
| AXIOM; name=located(IDENTIFIER); COLON; fmla=located(QUOTED)
  { Axiom (name, fmla) }
| THEOREM; name=located(IDENTIFIER); COLON; fmla=located(QUOTED);
  PROOF;
    p=located(proof);
  x=located(END)
  { Theorem (name, fmla, p, x) }

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
located(X): x=X
    { Annotated.add (Location.mk $startpos $endpos) x }
