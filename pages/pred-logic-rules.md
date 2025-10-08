# Topic 4: Proof rules for Predicate Logic

```aside
This page assumes that you have understood [natural deduction for Propositional Logic](natural-deduction-intro.html) and the [syntax of Predicate Logic](pred-logic-intro.html).
```

**THIS PAGE IS UNDER CONSTRUCTION**

We have seen the proof system of [natural deduction for Propositional Logic](natural-deduction-intro.html). This page describes how we can upgrade this system to [Predicate Logic](pred-logic-intro.html). The syntax of Predicate Logic is complicated by the presence of variables, so we need to alter our definition of judgement to take account of them. After doing this, we can take the basic rules for Propositional Logic unchanged, and add rules for the `∀` and `∃` quantifiers. Perhaps surprisingly, we also need to add special rules for equality `s = t`.

## Managing the Scope of Variables

The key difference between Propositional Logic and Predicate Logic is that the latter allows us to name individuals `x`, `y` and so on. To upgrade Natural Deduction to handle Predicate Logic, we need to make sure that we keep track of the names that we are using in our proofs, making sure that our terms and formulas are well-scoped.

We are going to be proving judgements that look like this:

```
   ⊢ ∀x. (p(x) ∧ q(x)) → p(x)
```
During the proof, we will have goals that look like:
```
   ... ⊢ (p(x) ∧ q(x)) → p(x)
```
The formula in the goal position has *free* occurrences of the variable `x`. To make sure that formulas make sense, we will keep track of variables as well as assumptions as part of the context to the left of the ⊢.

For the proof system for Predicate Logic, the judgements look like:
```
    P₁, x1, ..., xi, Pj, ..., xm, Pₙ ⊢ Q
```
where variables are mixed in with the assumed formulas. The same goes for when we have a formula in focus:
```
    P₁, x1, ..., xi, Pj, ..., xm, Pₙ [P] ⊢ Q
```
We will never focus on a variable, only formulas.

The important point about the variables `x` is that a variable appears *before* (i.e., to the *left*) of any free occurrences in formulas.

If `Γ` is a context containing variables and assumptions, then we say that a formula `P` is *well-scoped in `Γ`* if all of the free variables of `P` are in `Γ`. A whole context `Γ` is *well-scoped* if every formula in it is well-scoped in the context to its left. Similarly, a whole judgement is well-scoped if the conclusion and focus (if it exists) are well-scoped in the context.

### Exercises

Are these judgements well scoped?

1. ```
   P(a()) ⊢ Q
   ```

   ```selection {id=scope-ex1}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Well Scoped**. The a() names an individual from the vocabulary, and is not a variable.
   ```

2. ```
   Q(z,s(z())) ⊢ P
   ```

   ```selection {id=scope-ex2}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Not Well Scoped**. The variable “z” has not been declared to the left of where it is used.
   ```

3. ```
   x, y, P(x,y), Q(x) ⊢ R
   ```

   ```selection {id=scope-ex3}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Well Scoped**. The variables “x” and “y” have both been declared to the left of where they are used, and there are no other variables.
   ```

4. ```
   x, y, P(x,y), Q(x), R(z) ⊢ S
   ```

   ```selection {id=scope-ex4}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Not Well Scoped**. The variables “x” and “y” have been properly declared, but “z” has not.
   ```

5. ```
   x, y, P(x,y), ∀z. Q(z), R(z) ⊢ S
   ```

   ```selection {id=scope-ex5}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Not Well Scoped**. The “z” in “∀z. Q(z)” is bound by the quantifier, but the “z” in “R(z)” has not been declared.
   ```

6. ```
   x, y, P(x,y), Q(x), ∀z. R(z) ⊢ S
   ```

   ```selection {id=scope-ex6}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Well Scoped**. The “z” in “∀z. R(z)” is bound by the quantifier. The “x” and the “y” have been declared before (i.e., to the left of) use.
   ```

7. ```
   x, P(x,y), y, Q(x) | -R
   ```

   ```selection {id=scope-ex7}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Not Well Scoped**. The “y” in “P(x,y)” is not in scope.
   ```

8. ```
   ⊢ P(x)
   ```

   ```selection {id=scope-ex8}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Not Well Scoped**. The variable “x” has not been declared.
   ```

9. ```
   ⊢ ∀x. P(x)
   ```

   ```selection {id=scope-ex9}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Well Scoped**. The quantifier “∀x.” binds the use of “x” in “P(x)”.
   ```

10. ```
	x, y ⊢ P(x)
	```

	```selection {id=scope-ex10}
	(config (options ("Well Scoped" "Not Well Scoped")))
	```

	```details
	Answer...

	**Well Scoped**. The variable “x” is used in the conclusion, and has been declared in the context.
	```

11. ```
	x [Q(y)] ⊢ ∀y. P(y)
	```

	```selection {id=scope-ex11}
	(config (options ("Well Scoped" "Not Well Scoped")))
	```

	```details
	Answer...

	**Not Well Scoped**. The formula in focus “Q(y)” uses the variable “y” which has not been declared.
	```


12. ```
	x, P(y) [Q(y)] ⊢ ∀y. P(y)
	```

	```selection {id=scope-ex12}
	(config (options ("Well Scoped" "Not Well Scoped")))
	```

	```details
	Answer...

	**Not Well Scoped**. The assumption “P(y)” uses the variable “y” which has not been declared.
	```

13. ```
	x, y, P(y) [Q(y)] ⊢ ∀y. P(y)
	```

	```selection {id=scope-ex13}
	(config (options ("Well Scoped" "Not Well Scoped")))
	```

	```details
	Answer...

	**Well Scoped**. The assumption “P(y)” uses the variable “y” which has not been declared.
	```

## Proof Rules for “for all”

As for any connective, the [Natural Deduction](natural-deduction-intro.html) rules for `∀` have introduction and elimination forms. Before we look at these, let's look at what `∀x. P` means, and what this might mean in terms of proof rules.

There are (at least) two possible answers for what `∀x. P` can mean, depending on whether we are thinking about *consuming* or *producing* a statement of this shape:

1. It means that for all individuals, `a()`, `P[x := a()]` is true (using substitution). That is, if we *know* (or assume) that `∀x. P` is true, then we can deduce `P[x : = a()]` for any `a()`.
2. We can think about how we would *prove* or *demonstrate* a statement like this. To prove `∀x. P`, we must prove `P[x := x0]` for some *arbitrary* `x0`. This `x0` stands for any specific `a()` that might be chosen, so if our proof works with an arbitrary `x0` it will work for any specific `a()`.

We can turn the second point into the introduction rule for `∀`:

```rules-display
(config
 (rule
  (name "introduce")
  (premises "Γ, x0 ⊢ Q[x := x0]")
  (conclusion "Γ ⊢ ∀x. Q")))
```

In words: to prove `∀x. Q`, we must prove `Q[x := x0]` for an arbitrary `x0`.

This rule has the same name as the introduction for implication `P → Q`. This is not a coincidence, both rules introduce a new assumption into the context. For `P → Q` it introduces the assumption that `P` is true. For `∀x.` it introduces the assumption that there is an entity called `x`.

We have named `x` and `x0` separately in this rule to emphasise that they are playing different roles. However, it is common to reuse the same name for the introduced variable as long as it doesn't clash with any other name currently in scope.

You can use `introduce` twice and then `use` and `done` to complete the following proof:

```focused-nd {id=pred-logic-rules-example1}
(config
 (goal "all x. p(x) -> p(x)"))
```

The elimination rule for `∀x. P` follows the idea in the first point above and works when the formula is in focus:

```rules-display
(config
 (rule
  (name "inst")
  (premises "Γ [P[x := t]] ⊢ Q")
  (conclusion "Γ [∀x. P] ⊢ Q")))
```
with the side condition that `t` is well-scoped in `Γ`.

In words: if we assume `∀x. P` then we can deduce `P[x := t]` for any well-scoped `t`.

To use this rule in the prover, enter `inst` followed by the term in quotes. For example, after doing `introduce` and `use`, the following proof will use `inst "you()"`:

“If everything is a flump, then you are a flump”.

```focused-nd {id=pred-logic-rules-example2}
(config
 (goal "(all x. flump(x)) -> flump(you())"))
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
   (config
    (solution (Rule(Introduce x)((Rule(Introduce x-is-p-and-q)((Rule(Use x-is-p-and-q)((Rule Conj_elim1((Rule Close()))))))))))
    (goal "all x. (p(x) /\ q(x)) -> p(x)"))
   ```

2. If `p` is true for all things, then it is true for the specific individual `a()`.
   ```focused-nd {id=pred-proof-all2}
   (config
    (solution (Rule(Introduce everything-is-p)((Rule(Use everything-is-p)((Rule(Instantiate(Fun a()))((Rule Close()))))))))
    (goal "(all x. p(x)) -> p(a())"))
   ```

3. If `p` and `q` are true for all things, then `p` is true for all things.
   ```focused-nd {id=pred-proof-all3}
   (config
    (solution (Rule(Introduce all-p-and-q)((Rule(Introduce y)((Rule(Use all-p-and-q)((Rule(Instantiate(Var y))((Rule Conj_elim1((Rule Close()))))))))))))
    (goal "(all x. p(x) /\ q(x)) -> (all y. p(y))"))
   ```

## Proof rules for “exists”

The introduction and elimination rules for `∃x. P` are nearly the mirror image of the rules for `∀x. P`, in the same way that the rules for `P ∨ Q` are the (near) mirror image of the rules for `P ∧ Q`.

Just as for `∀x. P`, there are two ways to think about `∃x. P` depending on whether we are thinking about *consuming* or *producing* a statement of this kind:

1. `∃x. P` means that there is at least one `y` such that `P[x := y]` is true.
2. To *prove* `∃x. P` we must provide a *witness* term `t` such that `P[x := t]` is provable.

As before, the second point becomes the introduction rule:

```rules-display
(config
 (rule
  (name "exists")
  (premises "Γ ⊢ P[x := t]")
  (conclusion "Γ ⊢ ∃x. P")))
```

with the side condition that `t` is well-scoped in `Γ`.

In words: to prove `∃x. P`, we must give a `t` for which `P[x := t]` can be proved.

Just as with the `inst` rule for `∀`, to use the `exists` rule in the prover it is followed by the term in quotes that you want to use as the witness. In the following proof use `exists "you()"` after the first `introduce <name>`. The rest of the proof is then completed using `use` and `done`.

```focused-nd {id=pred-logic-rules-example3}
(config
 (goal "flump(you()) -> (ex x. flump(x))"))
```

THe first point becomes the elimination rule, where we “unpack” an existential assumption into a variable represening an individual and a property of that individual:

```rules-display
(config
 (rule
  (name "unpack")
  (premises "Γ, x0, P[x := x0] ⊢ Q")
  (conclusion "Γ [∃x. P] ⊢ Q")))
```

In words: if we know `∃x. P`, then we can assume there is some `x0` for which `P[x := x0]` is true.

Just as for `cases` for `P ∨ Q`, to use this rule in the prover, we need to give a name for the new variable and a name for the new assumption when we use the `unpack` command.

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
   (config
    (solution (Rule(Introduce a-is-p)((Rule(Exists(Fun a()))((Rule(Use a-is-p)((Rule Close()))))))))
    (goal "p(a()) -> (ex x. p(x))"))
   ```

1. If something exists that has two properties, then something exists that has one of those properties:
   ```focused-nd {id=pred-proof-ex2}
   (config
    (solution (Rule(Introduce exists-a-p-and-q)((Rule(Use exists-a-p-and-q)((Rule(ExElim x x-is-p-and-q)((Rule(Exists(Var x))((Rule(Use x-is-p-and-q)((Rule Conj_elim1((Rule Close()))))))))))))))
    (goal "(ex x. p(x) /\ q(x)) -> (ex z. p(z))"))
   ```

2. If something exists that has one of two properties, then either there exists something that has the first property, or one that has the second:
   ```focused-nd {id=pred-proof-ex3}
   (config
    (solution (Rule(Introduce exists-a-p-or-q)((Rule(Use exists-a-p-or-q)((Rule(ExElim x x-is-p-or-q)((Rule(Use x-is-p-or-q)((Rule(Cases x-is-p x-is-q)((Rule Left((Rule(Exists(Var x))((Rule(Use x-is-p)((Rule Close())))))))(Rule Right((Rule(Exists(Var x))((Rule(Use x-is-q)((Rule Close()))))))))))))))))))
    (goal "(ex x. p(x) \/ q(x)) -> ((ex z. p(z)) \/ (ex z. q(z)))"))
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
   (config
    (solution (Rule(Introduce H)((Rule(Introduce a-is-p)((Rule(Use H)((Rule(Instantiate(Fun a()))((Rule Implies_elim((Rule(Use a-is-p)((Rule Close())))(Rule Close()))))))))))))
    (goal "(all x. p(x) -> (ex y. r(x,y))) -> p(a()) -> (ex z. r(a(),z))"))
   ```

2. If everything is not `p`, then there does not exist a `p`:

   ```focused-nd {id=pred-proof-allex2}
   (config
    (solution (Rule(Introduce H)((Rule(NotIntro exists-p)((Rule(Use exists-p)((Rule(ExElim y y-is-p)((Rule(Use H)((Rule(Instantiate(Var y))((Rule NotElim((Rule(Use y-is-p)((Rule Close()))))))))))))))))))
    (goal "(all x. ¬p(x)) -> ¬(ex y. p(y))"))
   ```

3. If there exists a non-`p`, then not everything is a `p`:

   ```focused-nd {id=pred-proof-allex3}
   (config
    (solution (Rule(Introduce H)((Rule(NotIntro all-are-p)((Rule(Use H)((Rule(ExElim x x-is-not-p)((Rule(Use x-is-not-p)((Rule NotElim((Rule(Use all-are-p)((Rule(Instantiate(Var x))((Rule Close()))))))))))))))))))
    (goal "(ex x. ¬p(x)) -> ¬(all y. p(y))"))
   ```

4. Quantifier order can be swapped, when they are the same quantifier:

   ```focused-nd {id=pred-proof-allex4}
   (config
    (solution (Rule(Introduce H)((Rule(Introduce x)((Rule(Introduce y)((Rule(Use H)((Rule(Instantiate(Var y))((Rule(Instantiate(Var x))((Rule Close()))))))))))))))
    (goal "(all x. all y. R(x,y)) -> (all x. all y. R(y,x))"))
   ```

5. “If every time there is an edge from *x* to *y* there is an edge from *y* to *x*, and every x has an edge from it to somewhere, then every *x* has an edge leading to it.”

   ```focused-nd {id=pred-proof-allex5}
   (config
	(assumptions
	 (symmetry "all x. all y. edge(x,y) -> edge(y,x)"))
	(goal "(all x. ex y. edge(x,y)) -> (all x. ex y. edge(y,x))"))
   ```

6. “If every time there is an edge from *x* to *y*, there is an edge from *y* to *x*, and there is no edge from a() to b(), then there is no edge from b() to a().”

   ```focused-nd {id=pred-proof-allex6}
   (config
	(assumptions
	 (symmetry "all x. all y. edge(x,y) -> edge(y,x)"))
	(goal "¬edge(a(),b()) -> ¬edge(b(),a())"))
   ```

7. “If every time there is edge from *x* to *y* and an edge from *y* to *z*, there is an edge from *x* to *z*, then if there is an edge from a() to b() and an edge from b() to c(), there is an edge from a() to c().”

   ```focused-nd {id=pred-proof-allex7}
   (config
	(assumptions
	 (transitivity "all x. all y. all z. edge(x,y) -> edge(y,z) -> edge(x,z)"))
	(goal "edge(a(),b()) -> edge(b(),c()) -> edge(a(),c())"))
   ```

8. “If every time there is edge from *x* to *y* and an edge from *y* to *z*, there is an edge from *x* to *z*, and if every time there is an edge from *x* to *y* there is an edge from *y* to *x*, and every *x* has an edge to some *y*, then for all *z*, there is an edge from *z* to *z*.”

   ```focused-nd {id=pred-proof-allex8}
   (config
	(assumptions
	 (transitivity "all x. all y. all z. edge(x,y) -> edge(y,z) -> edge(x,z)")
	 (symmetry "all x. all y. edge(x,y) -> edge(y,x)"))
	(goal "(all x. ex y. edge(x,y)) -> (all z. edge(z,z))"))
   ```

9. “If, for all *x* and *y* there is either an edge from *x* to *y* or an edge from *y* to *x*, and there is no edge from a() to b(), then there is an edge from b() to a().”

   ```focused-nd {id=pred-proof-allex9}
   (config
	(assumptions
	 (either-edge "∀x. ∀y. edge(x, y) ∨ edge(y, x)"))
	(goal "¬edge(a(), b()) → edge(b(), a())"))
   ```

10. “If, for all *x* and *y* there is either an edge from *x* to *y* or an edge from *y* to *x*, and for every *x* and *y*, if there is an edge from *x* to *y* there is an edge from *y* to *x*, then for all *x* and *y*, there is an edge from *x* to *y*.”

	```focused-nd {id=pred-proof-allex10}
	(config
	 (assumptions
	  (either-edge "∀x. ∀y. edge(x, y) ∨ edge(y, x)")
	  (symmetry "all x. all y. edge(x,y) -> edge(y,x)"))
	 (goal "all x. all y. edge(x,y)"))
	```

11. “If every dragon has a child that rides it, and there exists a dragon, then there exists a child.”

	```focused-nd {id=pred-proof-allex11}
	(config
	 (name "Question 2(a)")
	 (assumptions
	  (every-dragon-has-a-child "∀i. dragon(i) → (∃c. child(c) ∧ rides(c, i))")
	  (exists-a-dragon "∃i. dragon(i)"))
	 (goal "∃c. child(c)"))
	```

12. “If every child rides a dragon, and there is a child who doesn't ride a dragon, then the earth is hollow.”

	```focused-nd {id=pred-proof-allex12}
	(config
	 (name "Question 2(b)")
	 (assumptions
	  (every-child-rides-a-dragon "∀c. child(c) → (∃i. dragon(i) ∧ rides(c, i))")
	  (exists-child-without-dragon "∃c. child(c) ∧ (∀i. dragon(i) → ¬rides(c, i))"))
	 (goal "∃p. earth(m) ∧ hollow(m)"))
	```

## Equality

Equality (`s = t`) is a fundamental relationship between entities. When we state an equality `s = t`, we are saying that there is no way to tell the two individuals `s` and `t` apart from the point of view of the logical setting we are working in.

### Equivalence Relations

In the exercises above, we have given predicates such as `edge` meaning by adding properties about them (such as “symmetry”) to the list of things we are assuming. We could try to do the same thing for equality.

It is possible to define what it means to be an *equivalence relation* (i.e., a relation that acts like equality) by the following three properties. Here we do this for some binary relation `≈` to emphasise that these laws are not enough to define proper equality.

1. **Reflexivity**: everything is equal to itself; `t ≈ t`, for all terms `t`.
2. **Symmetry**: if `s ≈ t` then `t ≈ s`, for all terms `s` and `t`.
3. **Transitivity**: if `s ≈ t` and `t ≈ u`, then `s ≈ u`.

These can be written as formulas to give three axioms of an equivalence relation:

1. reflexivity: ∀ x. x ≈ x
2. symmetry: ∀ x. ∀ y. x ≈ y → y ≈ x
3. transitivity: ∀ x. ∀ y. ∀ z. x ≈ y → y ≈ z → x ≈ z

There's not much one can prove directly from these axioms without making further assumptions. One thing that can be proved is that, even without reflexivity, if `x` is equal to something, then it must be equal to itself:

```focused-nd {id=equality-equivrelation}
(config
 (assumptions (symmetry "all x. all y. equiv(x,y) -> equiv(y,x)")
			  (transitivity "all x. all y. all z. equiv(x,y) -> equiv(y,z) -> equiv(x,z)"))
 (goal "all x. (ex y. equiv(x,y)) -> equiv(x,x)")
 (solution (Rule(Introduce x)((Rule(Introduce x-equal-to-something)((Rule(Use x-equal-to-something)((Rule(ExElim y x-equiv-y)((Rule(Use transitivity)((Rule(Instantiate(Var x))((Rule(Instantiate(Var y))((Rule(Instantiate(Var x))((Rule Implies_elim((Rule(Use x-equiv-y)((Rule Close())))(Rule Implies_elim((Rule(Use symmetry)((Rule(Instantiate(Var x))((Rule(Instantiate(Var y))((Rule Implies_elim((Rule(Use x-equiv-y)((Rule Close())))(Rule Close())))))))))(Rule Close())))))))))))))))))))))))
```

(A binary relation that only has symmetry and transitivity is called a *partial equivalence relation*. They are useful for describing the semantics of programming languages.)

### Proof Rules for Equality

These three axioms are the minimum for a relation `≈` to be considered some form of equivalence. However, they are not enough to properly define equality because they do not specify the effect that two things being equal has on everything else in the system.

Specifically, *equality* has the following special property, usually attributed to  the philosopher Leibniz:

> If `t1 = t2` then *everything* that is true about `t1` is true about `t2`.

Or, in more symbols:

> If `t1 = t2` and `P[x ↦ t1]` then `P[x ↦ t2]`.

This property is known as “substitutivity” or, more philosophically, as “indiscernability of equivalents”. It can be read in two ways:

1. If two things are equal, there is no way to write a formula that is true about one and false about the other.
2. If two things are equal, then we can replace one with the other wherever we want with no effect on what is true; i.e., we can substitute one for the other.

Because it applies for all formulas `P` We can't express this property as an axiom in our system, so we add it as a new rule. This is the *elimination* rule for equality:

FIXME: subst rule.

The `subst` rule is quite tricky to use because we have to give a formula `P` such that `P[x := t1]` is the formula we start with and `P[x := t2]` is the formula the one we want to end up with. Writing out `P` each time can be tedious. Usually, we want to replace *every* occurrence of `t1` with `t2`. We will write this as `P{t1 |-> t2}`, and use it in two new *rewrite* rules:

FIXME: rewrite rules

`rewrite<-` can be used to prove this theorem. After introducing the two assumptions, `use` the `a() = b()` assumption with `rewrite<-` to replace the `b()` in the goal with `a()`. The goal will then match the other assumption.

```focused-nd {id=equality-rewrite-example}
(config
 (goal "p(a()) -> a() = b() -> p(b())"))
```

The introduction rule for equality is *reflexivity*:

```rules-display
(config
 (rule
  (name "refl")
  (conclusion "Γ ⊢ t = t")))
```

In words: it is always the case that any term `t` is equal to itself.

The rewrite rules and reflexivity are enough to prove the other two properties *symmetry* and *transitivity* for equality:

```focused-nd {id=equality-symmetry}
(config
 (name "Symmetry")
 (goal "all x. all y. x = y -> y = x")
 (solution (Rule(Introduce x)((Rule(Introduce y)((Rule(Introduce x-eq-y)((Rule(Use x-eq-y)((Rule(Rewrite ltr)((Rule Refl())))))))))))))
```

```focused-nd {id=equality-transitivity}
(config
 (name "Transitivity")
 (goal "all x. all y. all z. x = y -> y = z -> x = z")
 (solution (Rule(Introduce x)((Rule(Introduce y)((Rule(Introduce z)((Rule(Introduce x-eq-y)((Rule(Introduce y-eq-z)((Rule(Use x-eq-y)((Rule(Rewrite ltr)((Rule(Use y-eq-z)((Rule Close())))))))))))))))))))
```

### What things are equal?

One consequence of treating equal things as always substitutable for one another is that what we consider to be equality depends on exactly what and how we are modelling. What is considered equal for one application domain might not make sense for another.

Sentences involving quotation in Natural Language are a rich source of tricky examples. For example the sentence “‘Edinburgh’ has 9 letters” might be considered true, but if we were to also consider “Edinburgh” to be equal to “The capital of Scotland”, then we would be able to derive the obviously false fact that “‘The capital of Scotland’ has 9 letters”.

The fundamental problem here is that the statement “‘X’ has N letters” states facts about individuals that are not preserved by our notion of equality. The relation “‘X’ has N letters” makes distinctions between individuals (in this case, it looks at their descriptive names) which are not preserved if we consider “Edinburgh” as just a different name for the capital of Scotland. To fix this example, we need to make sure that our predicates and our equalities are consistent, either by not admitting that “Edinburgh” and “The capital of Scotland” are equal, or by not allowing statements of the form “‘X’ has N letters” in our vocabulary.

This kind of example crops up in Computer Science whenever we have to make a distinction between the *description* of a process (i.e., the program that implements it) and the *observable behaviour* of a process. In some cases equality should track the implementation (e.g., a text editor application should treat different program texts differently), and in others it should track the behaviour (e.g., an optimising compiler is allowed to change the implementation if it preserves the behaviour). In philosophical jargon, these two aspects are referred to the *intension* (how a thing is built) and *extension* (how a thing acts) of an object.

This example demonstrates what can go wrong if we have a mismatch between the properties we assume of things, and what things are equal. Two things can be equal only if we do not talk about any properties that may separate them. Here is the example with letter counts from above:

FIXME: use string literals?

```focused-nd {id=equality-intensional1}
(config
 (assumptions
  (edinburgh-has-nine-letters           "has-nine-letters(edinburgh())")
  (capital-of-scotland-not-nine-letters "¬has-nine-letters(capital-of-scotland())")
  (edinburgh-is-capital-of-scotland     "edinburgh() = capital-of-scotland()"))
 (goal "F")
 (solution (Rule(Use capital-of-scotland-not-nine-letters)((Rule NotElim((Rule(Use edinburgh-is-capital-of-scotland)((Rule(Rewrite rtl)((Rule(Use edinburgh-has-nine-letters)((Rule Close())))))))))))))
```

More generally, if we have two things that have different properties (one is `P` and one is not `P`), then they must be not equal:

```focused-nd {id=equality-intensional2}
(config
 (goal "all x. all y. P(x) -> ¬P(y) -> ¬(x = y)")
 (solution (Rule(Introduce x)((Rule(Introduce y)((Rule(Introduce x-is-p)((Rule(Introduce y-is-not-p)((Rule(NotIntro x-eq-y)((Rule(Use y-is-not-p)((Rule NotElim((Rule(Use x-eq-y)((Rule(Rewrite rtl)((Rule(Use x-is-p)((Rule Close())))))))))))))))))))))))
```

### Exercises : Abelian Groups

An [abelian group](https://en.wikipedia.org/wiki/Abelian_group) is a generalisation of the ideas of addition and multiplication of numbers. We assume there is an operation ‘combine’ that combines two things (e.g., adding or multiplying), an operation ‘inv’ that takes the inverse of a thing (e.g., negation or reciprocal), and a value ‘emp()’ that has no effect when combined with something else (e.g., zero for addition, or one for multiplication). What makes an abelian group *abelian* and not just a group is that it does not matter what order things are combined in: ‘combine(x,y) = combine(y,x)’.

The axioms of an abelian group are:

1. *combine-assoc* : ∀x. ∀y. ∀z. combine(x, combine(y, z)) = combine(combine(x, y), z)

   This axiom states that if you have three things to combine together, then it does matter which order you do the ‘combine’ operations in, the answers are always the same. Axioms like this are usually called *associativity*, or *assoc* for short.
2. *combine-comm* : ∀x. ∀y. combine(x, y) = combine(y, x)

   This axiom states that combining ‘x’ with ‘y’ is the same as combining ‘y’ with ‘x’, just as it is for normal addition and multiplication. Axioms like this are usually called *commutativity*, or *comm* for short.
3. *combine-inv* : ∀x. combine(x, inv(x)) = emp()

   This axiom states that combining something with its inverse is equal to the empty thing. E.g., `x + (-x) = 0` for addition on numbers.
4. *combine-emp* : ∀x. combine(x, emp()) = x

   This axiom states that combining ‘x’ with ‘emp()’ is the same as ‘x’. We can think of ‘emp()’ as being like ‘0’ for addition, or ‘1’ for multiplication.

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
- **NEW** `refl` can be used when the goal is ‘t = t’ for some term ‘t’. Note that the terms on each side of the equality must be exactly the same. If this command is applicable, then this branch of the proof is complete.
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
- **NEW** `rewrite->` can be used when the formula in focus is an equality ‘t1 = t2’. Every occurrence of ‘t1’ in the goal is rewritten to ‘t2’. (The rewrite goes left to right.)
- **NEW** `rewrite<-` can be used when the formula in focus is an equality ‘t1 = t2’. Every occurrence of ‘t2’ in the goal is rewritten to ‘t1’. (The rewrite goes right to left.)
````


1. ‘emp()’s in the middle of a combination can always be removed:

   ```focused-nd {id=equality-abelian1}
   (config
	(assumptions
	 (combine-assoc "∀x. ∀y. ∀z. combine(x, combine(y, z)) = combine(combine(x, y), z)")
	 (combine-comm "∀x. ∀y. combine(x, y) = combine(y, x)")
	 (combine-inv "∀x. combine(x, inv(x)) = emp()")
	 (combine-emp "∀x. combine(x, emp()) = x"))
	(goal "all x. all y. combine(x, combine(emp(), y)) = combine(x,y)")
	(solution (Rule(Introduce x)((Rule(Introduce y)((Rule(Use combine-comm)((Rule(Instantiate(Fun emp()))((Rule(Instantiate(Var y))((Rule(Rewrite ltr)((Rule(Use combine-emp)((Rule(Instantiate(Var y))((Rule(Rewrite ltr)((Rule Refl())))))))))))))))))))))
   ```

2. The ‘combine-emp’ axiom works the other way round as well:

   ```focused-nd {id=equality-abelian2}
   (config
	(assumptions
	 (combine-assoc "∀x. ∀y. ∀z. combine(x, combine(y, z)) = combine(combine(x, y), z)")
	 (combine-comm "∀x. ∀y. combine(x, y) = combine(y, x)")
	 (combine-inv "∀x. combine(x, inv(x)) = emp()")
	 (combine-emp "∀x. combine(x, emp()) = x"))
	(goal "all x. combine(emp(), x) = x")
	(solution (Rule(Introduce x)((Rule(Use combine-comm)((Rule(Instantiate(Fun emp()))((Rule(Instantiate(Var x))((Rule(Rewrite ltr)((Rule(Use combine-emp)((Rule(Instantiate(Var x))((Rule Close())))))))))))))))))
   ```

3. The ‘combine-inv’ axiom works the other way round as well:

   ```focused-nd {id=equality-abelian3}
   (config
	(assumptions
	 (combine-assoc "∀x. ∀y. ∀z. combine(x, combine(y, z)) = combine(combine(x, y), z)")
	 (combine-comm "∀x. ∀y. combine(x, y) = combine(y, x)")
	 (combine-inv "∀x. combine(x, inv(x)) = emp()")
	 (combine-emp "∀x. combine(x, emp()) = x"))
	(goal "all x. combine(inv(x), x) = emp()")
	(solution (Rule(Introduce x)((Rule(Use combine-comm)((Rule(Instantiate(Fun inv((Var x))))((Rule(Instantiate(Var x))((Rule(Rewrite ltr)((Rule(Use combine-inv)((Rule(Instantiate(Var x))((Rule Close())))))))))))))))))
   ```
