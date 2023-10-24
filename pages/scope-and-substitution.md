# Scope and Substitution

To use Natural Deduction for [Predicate Logic](pred-logic-intro.html) we need to upgrade our ideas of judgement to track which variables are in scope during a proof. We also need to be able to correctly substitute terms into formulas with free variables.

[Slides for the videos (PDF)](week07-slides.pdf)

## Managing which variables are in scope

The key difference between Propositional Logic and Predicate Logic is that the latter allows us to name individuals `x`, `y` and so on. To upgrade Natural Deduction to handle Predicate Logic, we need to make sure that we keep track of the names that we are using in our proofs, making sure that our terms and formulas are well-scoped.

Well-scopedness of terms and formulas means that all the *variables* mentioned in a term or formula are already declared to the left of them in a judgement. This is explained in the following video:

```youtube
uB5NtHCbuJc
```

```textbox {id=scope-subst-note1}
Enter any notes to yourself here.
```

### Exercises

Are these contexts of variables and assumptions well scoped?

1. A

2. B

3. C

```
                    context_scope_qn F.[ `F (Atom ("P", [ Fun ("a", []) ])) ];
                    context_scope_qn
                      F.
                        [
                          `F
                            (Atom
                               ("Q", [ Var "z"; Fun ("s", [ Fun ("z", []) ]) ]));
                        ];
                    context_scope_qn
                      F.
                        [
                          `V "x";
                          `V "y";
                          `F (Atom ("P", [ Var "x"; Var "y" ]));
                          `F (Atom ("Q", [ Var "x" ]));
                        ];
                    context_scope_qn
                      F.
                        [
                          `V "x";
                          `V "y";
                          `F (Atom ("P", [ Var "x"; Var "y" ]));
                          `F (Atom ("Q", [ Var "x" ]));
                          `F (Atom ("R", [ Var "z" ]));
                        ];
                    context_scope_qn
                      F.
                        [
                          `V "x";
                          `V "y";
                          `F (Atom ("P", [ Var "x"; Var "y" ]));
                          `F (all "z" (Atom ("Q", [ Var "z" ])));
                          `F (Atom ("R", [ Var "z" ]));
                        ];
                    context_scope_qn
                      F.
                        [
                          `V "x";
                          `V "y";
                          `F (Atom ("P", [ Var "x"; Var "y" ]));
                          `F (Atom ("Q", [ Var "x" ]));
                          `F (all "z" (Atom ("R", [ Var "z" ])));
                        ];
                    context_scope_qn
                      F.
                        [
                          `V "x";
                          `F (Atom ("P", [ Var "x"; Var "y" ]));
                          `V "y";
                          `F (Atom ("Q", [ Var "x" ]));
                        ]]);
```

Are these judgements well scoped?

1. A

2. B

3. C

```
                    judgement_scope_qn [] F.(Atom ("P", [ Var "x" ]));
                    judgement_scope_qn [] F.(all "x" (Atom ("P", [ Var "x" ])));
                    judgement_scope_qn
                      [ `V "x"; `V "y" ]
                      F.(all "x" (Atom ("P", [ Var "x" ])));
                    judgement_scope_qn
                      [ `V "x" ]
                      ~focus:F.(Atom ("Q", [ Var "y" ]))
                      F.(all "y" (Atom ("P", [ Var "y" ])));
                    judgement_scope_qn
                      [ `V "x"; `F (Atom ("P", [ Var "y" ])) ]
                      ~focus:F.(Atom ("Q", [ Var "y" ]))
                      F.(all "y" (Atom ("P", [ Var "y" ])))])]
```

## Substitution

Next is the important concept of subsitution. Substitution is how we go from a general statement like “for all x, if x is human, then x is mortal” to a specific statement "if socrates is human, then socrates is mortal": we *substitute* the specific individual “socrates” for the general variable “x”.

Substitution is not much more than simply “plugging in values”, like you may be used to in formulas in mathematics, but gets a little more subtle when we have formulas that bind variables in them, as we see in this video:

```youtube
Ehan-g6-EVQ
```

```textbox {id=scope-subst-note2}
Enter any notes to yourself here.
```

### Exercises

Compute the results of the following substitutions, being careful with renaming to avoid variable capture.

```
      subst_question
        ~f:F.(all "x" (p (Var "x") @-> q (Var "x", Var "y")))
        ~x:"x"
        ~tm:F.(Fun ("f", [ Var "x" ]));

      subst_question
        ~f:F.(all "x" (p (Var "x") @-> q (Var "x", Var "y")))
        ~x:"y"
        ~tm:F.(Fun ("f", [ Var "x" ]));

      subst_question
        ~f:F.(p (Var "x") @-> ex "x" (q (Var "x", Var "y")))
        ~x:"x"
        ~tm:(Fun ("g", [ Var "y" ]));

      subst_question
        ~f:F.(p (Var "x") @-> ex "y" (q (Var "x", Var "y")))
        ~x:"x"
        ~tm:(Fun ("g", [ Var "y" ]))]
```
