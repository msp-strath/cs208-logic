type proof =
  | Introduce of string * proof
  | NotIntro  of string * proof   (* Could be same as previous? *)
  | True
  | Split     of proof * proof

  | Left      of proof
  | Right     of proof
  | Exists    of term * proof

  | Use       of string * elims

and elims =
(* Apply the *)
  | Apply     of proof * elims
  | Refuted   of proof
  | Inst      of term * elims
  | Project   of [`First|`Second] * elims

(* Termination of the eliminations *)
  | Done

(* Eliminators via pattern matching *)
  | Cases     of string * proof * string * proof
  | False
  | Unpack    of string * string * proof


  G |- P(0)       G, n, P(n) |- P(n+1)
 ---------------------------------------
           G |- all x. P(x)

or

  G |- P[x:=0]    G, n, P[x:=n] |- P[x:=n+1]
 --------------------------------------------
                G, x |- P

(* induction x;
   - { proving P[x:=0] }
     ...
   - { assuming 'n' }
     { assuming 'P[x:=n]' with name 'IH' }
     { proving P[x:=n+1] }
     ...
*)




%%


proof:
  | INTRODUCE; n=IDENT; SEMICOLON; p=proof                { () }
  | TRUE                                                  { () }
  | SPLIT; LBRACE; DASH; p1=proof; DASH; p2=proof; RBRACE { () }
  | LEFT; SEMICOLON; p=proof
  | RIGHT; SEMICOLON; p=proof
  | EXISTS; t=term; SEMICOLON; p=proof
  | NOTINTRO; n=IDENT; SEMICOLON; p=proof
  | USE; n=IDENT; COMMA; e=elims

/* all these are single argument constructors ... */
constructor:
  | INTRODUCE; n=IDENT
  | LEFT
  | RIGHT
  | EXISTS; t=term
  | NOTINTRO; n=IDENT  /* ... why isn't this just 'introduce'? */

elims:
  | APPLY; WITH; LBRACE; p=proof; RBRACE; e=elim
  | REFUTED; BY; LBRACE; p=proof; RBRACE
  | INST; t=term; COMMA; e=elim
  | FIRST; COMMA; e=elim
  | SECOND; COMMA; e=elim
  | CASES; n1=IDENT; OR; n2=IDENT; LBRACE; DASH; p1=proof; DASH; p2=proof; RBRACE
  | UNPACK; AS; n=IDENT; h=IDENT; IN; p=proof
  | FALSE
  | DONE
