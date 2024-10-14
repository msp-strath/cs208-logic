%{
open Structure

(* FIXME: locations *)

%}

%token <string> IDENT
%token <int> INTLIT
%token VOCAB FOR CHECK MODEL
%token AXIOMATISATION SYNTH SIZE
%token LBRACE RBRACE MODELS EQUALS LPAREN RPAREN COMMA SLASH COLON

%token EOF UNKNOWN
%token <Fol_formula.formula> QUOTED

%start <Structure.item list> structure

%%

structure:
  | items=list(item); EOF
    { items }

item:
  | VOCAB; name=IDENT; LBRACE; arities=separated_list(COMMA,arity_defn); RBRACE
    { Vocab { name; arities } }
  | MODEL; name=IDENT; FOR; vocab_name=IDENT; LBRACE; defns=separated_list(COMMA,set_defn); RBRACE
    { Model { name; vocab_name; defns } }
  | AXIOMATISATION; name=IDENT; FOR; vocab=IDENT; LBRACE; formulas=separated_list(COMMA,named_formula); RBRACE
    { Axioms { name; vocab; formulas } }
  | CHECK; model_name=IDENT; MODELS; formula=QUOTED
    { Check { model_name; formula } }
  | SYNTH; axioms=IDENT; SIZE; cardinality=INTLIT
    { Synth { axioms; cardinality } }

named_formula:
  | nm=IDENT; COLON; f=QUOTED
    { (nm, f) }

arity_defn:
  | nm=IDENT; SLASH; arity=INTLIT
    { (nm, arity) }

set_defn:
  | nm=IDENT; EQUALS; LBRACE; tuples=separated_list(COMMA,tuple); RBRACE
    { (nm, tuples) }

tuple:
  | nm=IDENT
    { [nm] }
  | LPAREN; nms=separated_list(COMMA,IDENT); RPAREN
    { nms }
