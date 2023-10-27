# Proof rules for Predicate Logic

With an understanding of [scope and substitution](scope-and-substitution.html), we can now look at the proof rules for Predicate Logic. The videos below introduce the rules and show how to use them in the interactive proof editor. There are exercises throughout the page to help you understand how the rules work, and so how the quantifiers work.

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

1. If every `p` has something that is `r`-related to it, and `a()` is a `p`, then there is something `r`-related to `a()`.

   ```focused-nd {id=pred-proof-allex1}
   (config (goal "(all x. p(x) -> (ex y. r(x,y))) -> p(a()) -> (ex z. r(a(),z))"))
   ```

2. If everything is not `p`, then there does not exist a `p`:

   ```focused-nd {id=pred-proof-allex2}
   (config (goal "(all x. ¬p(x)) -> ¬(ex y. p(y))"))
   ```

3. If there exists a non-`p`, then not everything is a `p`:

   ```focused-nd {id=pred-proof-allex3}
   (config (goal "(ex x. ¬p(x)) -> ¬(all y. p(y))"))
   ```

4. Quantifier order can be swapped, when they are the same quantifier:

   ```focused-nd {id=pred-proof-allex4}
   (config (goal "(all x. all y. R(x,y)) -> (all x. all y. R(y,x))"))
   ```
