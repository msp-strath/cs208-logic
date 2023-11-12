# Natural Deduction

```aside
This page assumes that you are familiar with the syntax and semantics of Propositional Logic, and the [general ideas of deductive systems](proof-intro.html).
```

After we have [looked at the general idea of deductive systems](proof-intro.html), we focus on the particular system we will be using in this course: *(focused) Natural Deduction*.

The Natural Deduction system was invented by the logician Gerhard Gentzen in 1934 as a way to formalise proofs in logic. We will be using a variant of Gentzen's system that is designed to be easy to use for building proofs interactively.

The key feature of Natural Deduction is its *modularity*. There are two basic rules of the system, `Done` and `Use`, that allow us to manage assumptions. Then there are separate rules for each connective "and", "implies", "or" and "not". For each connective, we have Introduction rules that tell us how to prove a statement using that connective, and Elimination rules that tell us how to use a statement built from that connective. The natural symmetry between introduction and elimination rules gives the whole system a balanced feel.

[Slides for these videos (PDF)](week04-slides.pdf).

## Video: Introducing Natural Deduction

```youtube
6Q2ujIUj67Y
```

```textbox {id=ndintro-notes1}
Enter any notes to yourself here.
```


## Online Proof Editor

To help you build proofs, these pages contain a proof editor specialised to the Natural Deduction proof system we will be using. The rest of this page contains information on how to use the editor for proofs involving And and Implication (see [the next page on implication](proof-implication.html)), and has some exercises for you to do.

### Video

```youtube
ditMR5-ilC4
```

```textbox {id=ndintro-notes2}
Enter any notes to yourself here.
```

### Commands for the Editor

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

- `split` can be used when the goal is a conjunction `P ∧ Q`. The proof will split into two sub-proofs, one to prove the first half of the conjunction P, and one to prove the other half Q.
- `true` can be used when the goal to prove is ‘T’ (true). This  will finish this branch of the proof.
- `use H` can be used whenever there is no current focus. `H` is the name of some assumption that is available on this branch of the proof.

#### Focused mode

These rules apply when there is a formula in focus. These rules either act upon the formula in focus, or finish the proof when the focused formula is the same as the goal.

- `done` can be used when the formula in focus is exactly the same  as the goal formula. This will finish this branch of the proof.
- `first` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘P’, the first part of the conjunction, and the proof continues.
- `second` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘Q’, the second part of the conjunction, and the proof continues.

### Exercises

Writing out formal proofs on paper is extremely tedious, so I have written an online proof editor tool that you will be using to build your own proofs.

1. A entails A:
   ```focused-nd {id=nd-intro-1}
   (config
    (assumptions (H "A"))
	(goal "A"))
   ```

2. A and B entails `A /\ B`
   ```focused-nd {id=nd-intro-2}
    (config
	 (assumptions (H1 A) (H2 B))
     (goal "A /\ B"))
    ```

3. `A /\ B` entails `A /\ B`
   ```focused-nd {id=nd-intro-3}
   (config
    (assumptions (H "A /\ B"))
    (goal "A /\ B"))
   ```

4. `A /\ B` entails `B /\ A`
   ```focused-nd {id=nd-intro-4}
   (config
    (assumptions (H "A /\ B"))
    (goal "B /\ A"))
   ```

5. Anything entails `T`
   ```focused-nd {id=nd-intro-5}
   (config
    (assumptions (H "A"))
    (goal "T"))
   ```

6. True on the right:
   ```focused-nd {id=nd-intro-6}
   (config
    (assumptions (H "A"))
    (goal "A /\ T"))
   ```

7. True on the left:
   ```focused-nd {id=nd-intro-7}
   (config
    (assumptions (H "A"))
    (goal "T /\ A"))
   ```
