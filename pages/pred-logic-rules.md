# Proof rules for Predicate Logic

```aside
This page assumes that you have understood natural deduction for Propositional Logic ([introduction](natural-deduction-intro.html), [rules for implication](proof-implication.html), [rules for or and not](proof-or.html)), the [introduction to predicate logic](pred-logic-intro.html) and the rules on [scoping and substitution](scope-and-substitution.html).
```

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

````details
Proof commands...

The blue boxes represent parts of the proof that are unfinished.  The comments (in green) tells you what the current goal is. Either the goal is unfocused:

```
{ goal: <some formula> }
```

or there is a formula is focus:

```
{ focus: <formula1>; goal: <formula2> }
```

The commands that you can use differ according to which mode youare in. The commands correspond directly to the proof rules given in the videos.

#### Unfocused mode

These rules can be used when there is no formula in the focus. These rules either act on the conclusion directly to break it down into simpler sub-goals, or switch to focused mode (the `use` command).

- `introduce H` can be used when the goal is an implication ‘P → Q’. The name `H` is used to give a name to the new assumption P. The proof then continues proving Q with this new assumption. A green comment is inserted to say what the new named assumption is.
- **NEW** `introduce y` can be used when the goal is a *for all* quantification ‘∀x. Q’. The name `y` is used for the assumption of an arbitrary individual that we have to prove ‘Q’ for. The proof then continues proving ‘Q’. A green comment is inserted to say that the rest of this branch of the proof is under the assumption that there is a named entity.
- `split` can be used when the goal is a conjunction “P ∧ Q”. The proof will split into two sub-proofs, one to prove the first half of the conjunction “P”, and one to prove the other half “Q”.
- `true` can be used when the goal to prove is ‘T’ (true). This  will finish this branch of the proof.
- `left` can be used when the goal to prove is a disjunction ‘P ∨ Q’. A new sub goal will be created to prove ‘P’.
- `right` can be used when the goal to prove is a disjunction ‘P ∨ Q’. A new sub goal will be created to prove ‘Q’.
- `not-intro H` can be used when the goal is a negation ‘¬P’. The name `H` is used to give a name to the new assumption P. The proof then continues proving F (i.e. False) with this new assumption. A green comment is inserted to say what the new named assumption is.
- `use H` can be used whenever there is no current focus. `H` is the name of some assumption that is available on this branch of the proof. Named assumptions come from the original statement to be proved, and uses of `introduce H`, `cases H1 H2`, `not-intro H`, and `unpack y H`.

#### Focused mode

These rules apply when there is a formula in focus. These rules either act upon the formula in focus, or finish the proof when the focused formula is the same as the goal.

- `done` can be used when the formula in focus is exactly the same  as the goal formula. This will finish this branch of the proof.
- `apply` can be used when the formula in focus is an implication ‘P → Q’. A new subgoal to prove ‘P’ is generated, and the focus becomes ‘Q’ to continue the proof.
- `first` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘P’, the first part of the conjunction, and the proof continues.
- `second` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘Q’, the second part of the conjunction, and the proof continues.
- `cases H1 H2` can be used then the formula in focus is a disjunction ‘P ∨ Q’. The proof splits into two branches, one for ‘P’ and one for ‘Q’. The two names `H1` and `H2` are used to name the new assumption on the two branches. Green comments are inserted to say what the new named assumptions are.
- `false` can be used when the formula in focus is ‘F’ (false). The proof finishes at this point, no matter what the conclusion is.
- `not-elim` can be used when the formula in focus is a negation  ‘¬P’. A new subgoal is generated to prove ‘P’ in order to generate a contradiction.
- **NEW** `inst "t"` can be used when the formula in focus is of the form ‘∀x. P’. The term t (which must be in quotes) is substituted in the place of x in the formula after the quantifier and the substituted formula ‘P[x:=t]’ remains in focus.
````

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

````details
Proof commands...

The blue boxes represent parts of the proof that are unfinished.  The comments (in green) tells you what the current goal is. Either the goal is unfocused:

```
{ goal: <some formula> }
```

or there is a formula is focus:

```
{ focus: <formula1>; goal: <formula2> }
```

The commands that you can use differ according to which mode youare in. The commands correspond directly to the proof rules given in the videos.

#### Unfocused mode

These rules can be used when there is no formula in the focus. These rules either act on the conclusion directly to break it down into simpler sub-goals, or switch to focused mode (the `use` command).

- `introduce H` can be used when the goal is an implication ‘P → Q’. The name `H` is used to give a name to the new assumption P. The proof then continues proving Q with this new assumption. A green comment is inserted to say what the new named assumption is.
- `introduce y` can be used when the goal is a *for all* quantification ‘∀x. Q’. The name `y` is used for the assumption of an arbitrary individual that we have to prove ‘Q’ for. The proof then continues proving ‘Q’. A green comment is inserted to say that the rest of this branch of the proof is under the assumption that there is a named entity.
- `split` can be used when the goal is a conjunction “P ∧ Q”. The proof will split into two sub-proofs, one to prove the first half of the conjunction “P”, and one to prove the other half “Q”.
- `true` can be used when the goal to prove is ‘T’ (true). This  will finish this branch of the proof.
- `left` can be used when the goal to prove is a disjunction ‘P ∨ Q’. A new sub goal will be created to prove ‘P’.
- `right` can be used when the goal to prove is a disjunction ‘P ∨ Q’. A new sub goal will be created to prove ‘Q’.
- `not-intro H` can be used when the goal is a negation ‘¬P’. The name `H` is used to give a name to the new assumption P. The proof then continues proving F (i.e. False) with this new assumption. A green comment is inserted to say what the new named assumption is.
- **NEW** `exists "t"` can be used when the goal is an *exists* quantification ‘∃x. Q’. The term `t` which must be in quotes, is used as the existential witness and is substituted for `x` in Q. The proof then continues proving ‘Q[x:=t]’,
- `use H` can be used whenever there is no current focus. `H` is the name of some assumption that is available on this branch of the proof. Named assumptions come from the original statement to be proved, and uses of `introduce H`, `cases H1 H2`, `not-intro H`, and `unpack y H`.

#### Focused mode

These rules apply when there is a formula in focus. These rules either act upon the formula in focus, or finish the proof when the focused formula is the same as the goal.

- `done` can be used when the formula in focus is exactly the same  as the goal formula. This will finish this branch of the proof.
- `apply` can be used when the formula in focus is an implication ‘P → Q’. A new subgoal to prove ‘P’ is generated, and the focus becomes ‘Q’ to continue the proof.
- `first` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘P’, the first part of the conjunction, and the proof continues.
- `second` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘Q’, the second part of the conjunction, and the proof continues.
- `cases H1 H2` can be used then the formula in focus is a disjunction ‘P ∨ Q’. The proof splits into two branches, one for ‘P’ and one for ‘Q’. The two names `H1` and `H2` are used to name the new assumption on the two branches. Green comments are inserted to say what the new named assumptions are.
- `false` can be used when the formula in focus is ‘F’ (false). The proof finishes at this point, no matter what the conclusion is.
- `not-elim` can be used when the formula in focus is a negation  ‘¬P’. A new subgoal is generated to prove ‘P’ in order to generate a contradiction.
- `inst "t"` can be used when the formula in focus is of the form ‘∀x. P’. The term t (which must be in quotes) is substituted in the place of x in the formula after the quantifier and the substituted formula ‘P[x:=t]’ remains in focus.
- **NEW** `unpack y H` can be used when the formula in focus is of the form ‘∃x. P’. The existential is “unpacked” into the assumption of an entity `y` and its property ‘P[x:=y]’, which is named `H`. Green comments are inserted to say what the assumption ‘`H`’ is.
````

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

````details
Proof commands...

The blue boxes represent parts of the proof that are unfinished.  The comments (in green) tells you what the current goal is. Either the goal is unfocused:

```
{ goal: <some formula> }
```

or there is a formula is focus:

```
{ focus: <formula1>; goal: <formula2> }
```

The commands that you can use differ according to which mode youare in. The commands correspond directly to the proof rules given in the videos.

#### Unfocused mode

These rules can be used when there is no formula in the focus. These rules either act on the conclusion directly to break it down into simpler sub-goals, or switch to focused mode (the `use` command).

- `introduce H` can be used when the goal is an implication ‘P → Q’. The name `H` is used to give a name to the new assumption P. The proof then continues proving Q with this new assumption. A green comment is inserted to say what the new named assumption is.
- `introduce y` can be used when the goal is a *for all* quantification ‘∀x. Q’. The name `y` is used for the assumption of an arbitrary individual that we have to prove ‘Q’ for. The proof then continues proving ‘Q’. A green comment is inserted to say that the rest of this branch of the proof is under the assumption that there is a named entity.
- `split` can be used when the goal is a conjunction “P ∧ Q”. The proof will split into two sub-proofs, one to prove the first half of the conjunction “P”, and one to prove the other half “Q”.
- `true` can be used when the goal to prove is ‘T’ (true). This  will finish this branch of the proof.
- `left` can be used when the goal to prove is a disjunction ‘P ∨ Q’. A new sub goal will be created to prove ‘P’.
- `right` can be used when the goal to prove is a disjunction ‘P ∨ Q’. A new sub goal will be created to prove ‘Q’.
- `not-intro H` can be used when the goal is a negation ‘¬P’. The name `H` is used to give a name to the new assumption P. The proof then continues proving F (i.e. False) with this new assumption. A green comment is inserted to say what the new named assumption is.
- `exists "t"` can be used when the goal is an *exists* quantification ‘∃x. Q’. The term `t` which must be in quotes, is used as the existential witness and is substituted for `x` in Q. The proof then continues proving ‘Q[x:=t]’,
- `use H` can be used whenever there is no current focus. `H` is the name of some assumption that is available on this branch of the proof. Named assumptions come from the original statement to be proved, and uses of `introduce H`, `cases H1 H2`, `not-intro H`, and `unpack y H`.

#### Focused mode

These rules apply when there is a formula in focus. These rules either act upon the formula in focus, or finish the proof when the focused formula is the same as the goal.

- `done` can be used when the formula in focus is exactly the same  as the goal formula. This will finish this branch of the proof.
- `apply` can be used when the formula in focus is an implication ‘P → Q’. A new subgoal to prove ‘P’ is generated, and the focus becomes ‘Q’ to continue the proof.
- `first` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘P’, the first part of the conjunction, and the proof continues.
- `second` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘Q’, the second part of the conjunction, and the proof continues.
- `cases H1 H2` can be used then the formula in focus is a disjunction ‘P ∨ Q’. The proof splits into two branches, one for ‘P’ and one for ‘Q’. The two names `H1` and `H2` are used to name the new assumption on the two branches. Green comments are inserted to say what the new named assumptions are.
- `false` can be used when the formula in focus is ‘F’ (false). The proof finishes at this point, no matter what the conclusion is.
- `not-elim` can be used when the formula in focus is a negation  ‘¬P’. A new subgoal is generated to prove ‘P’ in order to generate a contradiction.
- `inst "t"` can be used when the formula in focus is of the form ‘∀x. P’. The term t (which must be in quotes) is substituted in the place of x in the formula after the quantifier and the substituted formula ‘P[x:=t]’ remains in focus.
- `unpack y H` can be used when the formula in focus is of the form ‘∃x. P’. The existential is “unpacked” into the assumption of an entity `y` and its property ‘P[x:=y]’, which is named `H`. Green comments are inserted to say what the assumption ‘`H`’ is.
````

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
