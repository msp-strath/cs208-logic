%{
open Structure

(* FIXME: locations *)

%}

%token <string> IDENT
%token <int> INTLIT
%token THEORY FOR CHECK MODEL AXIOM PREDICATE
%token LBRACE RBRACE MODELS EQUALS LPAREN RPAREN COMMA SLASH COLON QMARK

%token EOF UNKNOWN
%token <Fol_formula.formula> QUOTED

%start <Structure.item list> structure

%%

structure:
  | items=list(item); EOF
    { items }

item:
  | THEORY; name=IDENT; LBRACE; items=list(theory_item); RBRACE
    { Theory { name; items } }
  | MODEL; name=IDENT; FOR; theory_name=IDENT;
      LBRACE; defns=list(set_defn); RBRACE
    { Model { name; theory_name; defns } }
  | CHECK; model_name=IDENT; MODELS; formula=QUOTED
    { Check { model_name; formula } }
/*
  | VOCAB; name=IDENT; LBRACE; arities=list(arity_defn); RBRACE
    { Vocab { name; arities } }
  | MODEL; name=IDENT; FOR; vocab_name=IDENT; LBRACE; defns=list(set_defn); RBRACE
    { Model { name; vocab_name; defns } }
  | AXIOMATISATION; name=IDENT; FOR; vocab=IDENT; LBRACE; formulas=list(named_formula); RBRACE
    { Axioms { name; vocab; formulas } }
  | CHECK; model_name=IDENT; MODELS; formula=QUOTED
    { Check { model_name; formula } }
  | SYNTH; axioms=IDENT; SIZE; cardinality=INTLIT
    { Synth { axioms; cardinality } }
*/

theory_item:
  | AXIOM; nm=IDENT; COLON; f=QUOTED
    { Axiom (nm, f) }
  | PREDICATE; nm=IDENT; SLASH; arity=INTLIT
    { SymbolDeclaration (nm, arity) }

set_defn:
  | nm=IDENT; EQUALS; LBRACE; tuples=separated_list(COMMA,tuple); RBRACE
    { (nm, Some tuples) }
  | nm=IDENT; EQUALS; QMARK
    { (nm, None) }

tuple:
  | nm=IDENT
    { [nm] }
  | LPAREN; nms=separated_list(COMMA,IDENT); RPAREN
    { nms }
