# Proof rules for Predicate Logic

[Slides for the videos below (PDF)](week07-slides.pdf)

## Proof rules for “for all”

```youtube
jTy2Z7EYT9U
```

```textbox {id=pred-logic-rules-note1}
Enter any notes to yourself here
```

### Using the Proof Editor

```youtube
BZxi-09OG50
```

```textbox {id=pred-logic-rules-note2}
Enter any notes to yourself here
```

### Exercises

These exercises use the new rules for “for all”, as well as the rules for the propositional connectives:

FIXME: proof commands

1. For all things, if `p` and `q` are true, then `p` is true:
   ```focused-nd {id=pred-proof-all1}
   (config (goal "all x. (p(x) /\ q(x)) -> p(x)"))
   ```

2. If `p` is true for all things, then it is true for the specific individual `a()`.
   ```focused-nd {id=pred-proof-all2}
   (config (goal "(all x. p(x)) -> p(a())"))
   ```

3. If `p` and `q` are true for all things, then `p` is true for all things.
   ```focused-nd {id-pred-proof-all3}
   (config (goal "(all x. p(x) /\ q(x)) -> (all y. p(y))"))
   ```

## Proof rules for “exists”

```youtube
VfpYHl_s1FI
```

```textbox {id=pred-logic-rules-note3}
Enter any notes to yourself here
```

### Using the Proof Editor

```youtube
Ay9QxA3iuGo
```

```textbox {id=pred-logic-rules-note4}
Enter any notes to yourself here
```

### Exercises

These exercises use the new rules for “exists”, as well as the rules for the propositional connectives:

FIXME: Proof commands

1. If `p` is true for `a()`, then there exists a thing for which `p` is true:
   ```focused-nd {id=pred-proof-ex1}
   (config (goal "p(a()) -> (ex x. p(x))"))
   ```

1. If something exists that has two properties, then something exists that has one of those properties:
   ```focused-nd {id=pred-proof-ex2}
   (config (goal "(ex x. p(x) /\ q(x)) -> (ex z. p(z))"))
   ```

2. If something exists that has one of two properties, then either there exists something that has the first property, or one that has the second:
   ```focused-nd {id=pred-proof-ex3}
   (config (goal "(ex x. p(x) \/ q(x)) -> ((ex z. p(z)) \/ (ex z. q(z)))"))
   ```

## Exercises combining ∀ and ∃

These exercises combine “for all” and “exists”:

1.

```
          li
            (nd
               F.(
                 all "x"
                   (Atom ("p", [ Var "x" ])
                   @-> ex "y" (Atom ("r", [ Var "x"; Var "y" ])))
                 @-> Atom ("p", [ Fun ("a", []) ])
                 @-> ex "z" (Atom ("r", [ Fun ("a", []); Var "z" ]))))]
          li
            (nd
               F.(
                 all "x" (Not (Atom ("P", [ Var "x" ])))
                 @-> Not (ex "y" (Atom ("P", [ Var "y" ])))));
          li
            (nd
               F.(
                 ex "x" (Not (Atom ("P", [ Var "x" ])))
                 @-> Not (all "y" (Atom ("P", [ Var "y" ])))));
          li
            (nd
               F.(
                 all "x" (all "y" (Atom ("R", [ Var "x"; Var "y" ])))
                 @-> all "x" (all "y" (Atom ("R", [ Var "y"; Var "x" ])))))]
```

FIXME: some more interesting questions using a simple axiomatisation.
