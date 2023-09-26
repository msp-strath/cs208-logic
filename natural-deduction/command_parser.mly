%token INTRODUCE
%token TRUE SPLIT LEFT RIGHT REFL USE EXISTS NOT_INTRO
%token APPLY FIRST SECOND FALSE NOT_ELIM DONE CASES INST UNPACK SUBST
%token SEMICOLON LBRACE RBRACE ASTERISK

%start <([`Rule of (Focused.rule, 'a list)] as 'a)> script

%%

intro_command:
| INTRODUCE; i=ident { Introduce i }
| TRUE         { Truth }
| SPLIT        { Split }
| LEFT         { Left }
| RIGHT        { Right }
| REFL         { Refl }
| USE; i=IDENT { USE i }
| EXISTS; t=term          { Exists t }
| NOT_INTRO; x=IDENT      { NotIntro x }

elim_command:
| APPLY       { Apply }
| FIRST       { Conj_elim1 }
| SECOND      { Conj_elim2 }
| FALSE       { Absurd }
| NOT_ELIM    { NotElim }
| DONE        { Close }
| CASES; x=IDENT; y=IDENT   { Cases (x, y) }
| INST; t=term              { Instantiate t }
| UNPACK; x=IDENT; y=IDENT  { Unpack (x, y) }
| SUBST; x=IDENT; f=formula { Subst (x, f) }

command:
| c=intro_command  { c }
| c=elim_command   { c }

script:
| c=command { `Rule (c, []) }
| c=command; SEMICOLON; s=script { `Rule (c, [s]) }
| c=command; LBRACE; cs=clauses; RBRACE { `Rule (c, cs) }

clauses:
| ASTERISK; s=script             { [s] }
| ASTERISK; s=script; cs=clauses { s::cs }
