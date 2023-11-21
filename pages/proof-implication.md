# Natural Deduction: Implication

```aside
This page assumes you have understood the [basics of natural deduction](natural-deduction-intro.html) for Propositional Logic.
```

## Video

```youtube
WJVpoJpjOn0
```

```textbox {id=proof-implication-notes1}
Enter any notes to yourself here.
```

[Slides](week04-slides.pdf)

## Exercises

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
- `use H` can be used whenever there is no current focus. `H` is the name of some assumption that is available on this branch of the proof. Named assumptions come from the original statement to be proved, and uses of `introduce H`.

#### Focused mode

These rules apply when there is a formula in focus. These rules either act upon the formula in focus, or finish the proof when the focused formula is the same as the goal.

- `done` can be used when the formula in focus is exactly the same  as the goal formula. This will finish this branch of the proof.
- `apply` can be used when the formula in focus is an implication ‘P → Q’. A new subgoal to prove ‘P’ is generated, and the focus becomes ‘Q’ to continue the proof.
- `first` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘P’, the first part of the conjunction, and the proof continues.
- `second` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘Q’, the second part of the conjunction, and the proof continues.
````

### Exercise 1

```focused-nd {id=implies-ex1}
(config (goal "A -> A")
 (solution (Rule(Introduce a)((Rule(Use a)((Rule Close())))))))
```

### Exercise 2

```focused-nd {id=implies-ex2}
(config (goal "(A /\ B) -> (B /\ A)")
 (solution (Rule(Introduce a-and-b)((Rule Split((Rule(Use a-and-b)((Rule Conj_elim2((Rule Close())))))(Rule(Use a-and-b)((Rule Conj_elim1((Rule Close())))))))))))
```

### Exercise 3

```focused-nd {id=implies-ex3}
(config (goal "((A /\ B) -> C) -> A -> B -> C")
 (solution (Rule(Introduce ab-implies-c)((Rule(Introduce a)((Rule(Introduce b)((Rule(Use ab-implies-c)((Rule Implies_elim((Rule Split((Rule(Use a)((Rule Close())))(Rule(Use b)((Rule Close())))))(Rule Close())))))))))))))
```

### Exercise 4

```focused-nd {id=implies-ex4}
(config (goal "(A -> B -> C) -> (A /\ B) -> C")
 (solution (Rule(Introduce a-implies-b-implies-c)((Rule(Introduce a-and-b)((Rule(Use a-implies-b-implies-c)((Rule Implies_elim((Rule(Use a-and-b)((Rule Conj_elim1((Rule Close())))))(Rule Implies_elim((Rule(Use a-and-b)((Rule Conj_elim2((Rule Close())))))(Rule Close())))))))))))))
```

### Exercise 5

```focused-nd {id=implies-ex5}
(config (goal "(A -> B) -> (B -> C) -> (A -> C)")
 (solution (Rule(Introduce a-implies-b)((Rule(Introduce b-implies-c)((Rule(Introduce a)((Rule(Use b-implies-c)((Rule Implies_elim((Rule(Use a-implies-b)((Rule Implies_elim((Rule(Use a)((Rule Close())))(Rule Close())))))(Rule Close())))))))))))))
```

### Exercise 6

```focused-nd {id=implies-ex6}
(config (goal "(A /\ B /\ C) -> ((A /\ B) /\ C)")
 (solution (Rule(Introduce a-and-b-and-c)((Rule Split((Rule Split((Rule(Use a-and-b-and-c)((Rule Conj_elim1((Rule Close())))))(Rule(Use a-and-b-and-c)((Rule Conj_elim2((Rule Conj_elim1((Rule Close())))))))))(Rule(Use a-and-b-and-c)((Rule Conj_elim2((Rule Conj_elim2((Rule Close())))))))))))))
```

### Exercise 7

```focused-nd {id=implies-ex7}
(config (goal "(A /\ B) -> (B -> C) -> (A /\ C)")
 (solution (Rule(Introduce a-and-b)((Rule(Introduce b-implies-c)((Rule Split((Rule(Use a-and-b)((Rule Conj_elim1((Rule Close())))))(Rule(Use b-implies-c)((Rule Implies_elim((Rule(Use a-and-b)((Rule Conj_elim2((Rule Close())))))(Rule Close())))))))))))))
```
