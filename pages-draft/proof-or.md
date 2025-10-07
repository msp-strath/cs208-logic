# Proof Rules for Or and Not

```aside
This page assumes you have understood the [basics of natural deduction](natural-deduction-intro.html) for Propositional Logic and the proof rules for [implication](proof-implication.html).
```


So far, we have seen the [basic natural deduction system and the proof rules for and](natural-deduction-intro.html) and the [rules for implication](proof-implication.html). We now add the rules for the remaining two connectives of Propositional Logic: "or" and "not".

## Videos

These videos describe the rules for "or":

```youtube
VmDShN9HZd4
```

and for "not":

```youtube
BEAE1Xg0SYE
```

```textbox {id=proof-or-notes1}
Enter any notes to yourself here.
```

[Slides](week05-slides.pdf)

## The Interactive Editor

The rules for "or" and "not" are also available in the proof editor. This video explains how to use them for some examples.

```youtube
sqJxNGv3IZ0
```

```textbox {id=proof-or-notes2}
Enter any notes to yourself here.
```

### Exercises

````details
Proof Commands...

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
- `split` can be used when the goal is a conjunction “P ∧ Q”. The proof will split into two sub-proofs, one to prove the first half of the conjunction “P”, and one to prove the other half “Q”.
- `true` can be used when the goal to prove is ‘T’ (true). This  will finish this branch of the proof.
- `left` can be used when the goal to prove is a disjunction ‘P ∨ Q’. A new sub goal will be created to prove ‘P’.
- `right` can be used when the goal to prove is a disjunction ‘P ∨ Q’. A new sub goal will be created to prove ‘Q’.
- `not-intro H` can be used when the goal is a negation ‘¬P’. The name `H` is used to give a name to the new assumption P. The proof then continues proving F (i.e. False) with this new assumption. A green comment is inserted to say what the new named assumption is.
- `use H` can be used whenever there is no current focus. `H` is the name of some assumption that is available on this branch of the proof. Named assumptions come from the original statement to be proved, and uses of `introduce H`.

#### Focused mode

These rules apply when there is a formula in focus. These rules either act upon the formula in focus, or finish the proof when the focused formula is the same as the goal.

- `done` can be used when the formula in focus is exactly the same  as the goal formula. This will finish this branch of the proof.
- `apply` can be used when the formula in focus is an implication ‘P → Q’. A new subgoal to prove ‘P’ is generated, and the focus becomes ‘Q’ to continue the proof.
- `first` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘P’, the first part of the conjunction, and the proof continues.
- `second` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘Q’, the second part of the conjunction, and the proof continues.
- `cases H1 H2` can be used then the formula in focus is a disjunction ‘P ∨ Q’. The proof splits into two branches, one for ‘P’ and one for ‘Q’. The two names `H1` and `H2` are used to name the new assumption on the two branches. Green comments are inserted to say what the new named assumptions are.
- `false` can be used when the formula in focus is ‘F’ (false). The proof finishes at this point, no matter what the conclusion is.
- `not-elim` can be used when the formula in focus is a negation  ‘¬P’. A new subgoal is generated to prove ‘P’ in order to generate a contradiction.
````

#### Exercise 1

If we have `A` or `B`, and both imply `C`, then we have `C`.

```focused-nd {id=or-ex1}
(config (goal "(A \/ B) -> (A -> C) -> (B -> C) -> C")
 (solution (Rule(Introduce a-or-b)((Rule(Introduce a-implies-c)((Rule(Introduce b-implies-c)((Rule(Use a-or-b)((Rule(Cases a b)((Rule(Use a-implies-c)((Rule Implies_elim((Rule(Use a)((Rule Close())))(Rule Close())))))(Rule(Use b-implies-c)((Rule Implies_elim((Rule(Use b)((Rule Close())))(Rule Close())))))))))))))))))
```

#### Exercise 2

If we have `A` or `B`, and `A` implies `C` and `B` implies `D`, then we have `C` or `D`.

```focused-nd {id=or-ex2}
(config (goal "(A \/ B) -> (A -> C) -> (B -> D) -> (C \/ D)")
 (solution (Rule(Introduce a-or-b)((Rule(Introduce a-implies-c)((Rule(Introduce b-implies-d)((Rule(Use a-or-b)((Rule(Cases a b)((Rule Left((Rule(Use a-implies-c)((Rule Implies_elim((Rule(Use a)((Rule Close())))(Rule Close())))))))(Rule Right((Rule(Use b-implies-d)((Rule Implies_elim((Rule(Use b)((Rule Close())))(Rule Close())))))))))))))))))))
```

#### Exercise 3

If `A` or `B` implies `C`, then we know that both `A` implies `C` and `B` implies `C`.

```focused-nd {id=or-ex3}
(config (goal "((A \/ B) -> C) -> ((A -> C) /\ (B -> C))")
 (solution (Rule(Introduce a-or-b-implies-c)((Rule Split((Rule(Introduce a)((Rule(Use a-or-b-implies-c)((Rule Implies_elim((Rule Left((Rule(Use a)((Rule Close())))))(Rule Close())))))))(Rule(Introduce b)((Rule(Use a-or-b-implies-c)((Rule Implies_elim((Rule Right((Rule(Use b)((Rule Close())))))(Rule Close())))))))))))))
```

#### Exercise 4

`A` or (`B` and `C`) implies (`A` or `B`) and (`A` or `C`). This is one direction of the distributivity law we used in [Converting to CNF](converting-to-cnf.html).

```focused-nd {id=or-ex4}
(config (assumptions (H "A \/ (B /\ C)"))
        (goal "(A \/ B) /\ (A \/ C)")
		(solution (Rule Split((Rule(Use H)((Rule(Cases a b-and-c)((Rule Left((Rule(Use a)((Rule Close())))))(Rule Right((Rule(Use b-and-c)((Rule Conj_elim1((Rule Close())))))))))))(Rule(Use H)((Rule(Cases a b-and-c)((Rule Left((Rule(Use a)((Rule Close())))))(Rule Right((Rule(Use b-and-c)((Rule Conj_elim2((Rule Close())))))))))))))))
```

#### Exercise 5

(`A` or `B`) and (`A` or `C`) imply `A` or (`B` and `C`). This is other direction of distributivity.

```focused-nd {id=or-ex5}
(config (assumptions (H "(A \/ B) /\ (A \/ C)"))
        (goal "A \/ (B /\ C)")
		(solution (Rule(Use H)((Rule Conj_elim1((Rule(Cases a b)((Rule Left((Rule(Use a)((Rule Close())))))(Rule(Use H)((Rule Conj_elim2((Rule(Cases a c)((Rule Left((Rule(Use a)((Rule Close())))))(Rule Right((Rule Split((Rule(Use b)((Rule Close())))(Rule(Use c)((Rule Close())))))))))))))))))))))
```

#### Exercise 6

`A` implies `¬¬A`:

```focused-nd {id=or-ex6}
(config (goal "A -> ¬ ¬ A")
 (solution (Rule(Introduce not-not-a)((Rule(Use excluded-middle)((Rule(Cases a not-a)((Rule(Use a)((Rule Close())))(Rule(Use not-not-a)((Rule NotElim((Rule(Use not-a)((Rule Close())))))))))))))))
```

#### Exercise 7

If we assume `A` or `¬A`, then `¬¬A` implies `A`. (We can't prove `¬¬A → A` without this assumption, see [Soundness, Completeness, and Some Philosophy](sound-complete-meaning.html).

```focused-nd {id=or-ex7}
(config (assumptions ("excluded-middle" "A \/ ¬A"))
        (goal "¬¬A -> A")
		(solution (Rule(Introduce not-not-a)((Rule(Use excluded-middle)((Rule(Cases a not-a)((Rule(Use a)((Rule Close())))(Rule(Use not-not-a)((Rule NotElim((Rule(Use not-a)((Rule Close())))))))))))))))
```

#### Exercise 8

`A → F` implies `¬A`, which demonstrates one direction of the equivalence between them.

```focused-nd {id=or-ex8a}
(config (goal "(A -> F) -> ¬A")
 (solution (Rule(Introduce a-implies-F)((Rule(NotIntro H)((Rule(Use a-implies-F)((Rule Implies_elim((Rule(Use H)((Rule Close())))(Rule Close())))))))))))
```

and `¬A` implies `A → F`, which demonstrates the other direction.

```focused-nd {id=or-ex8b}
(config (goal "¬A -> (A -> F)")
 (solution (Rule(Introduce not-a)((Rule(Introduce a)((Rule(Use not-a)((Rule NotElim((Rule(Use a)((Rule Close())))))))))))))
```
