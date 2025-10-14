# Topic 2: Natural Deduction

```aside
This page assumes that you are familiar with the syntax and semantics of Propositional Logic, and the [general ideas of deductive systems](proof-intro.html).
```

Now that we have looked at [the general idea of deductive systems](proof-intro.md), we focus on the particular system we will be using in this course: *(focused) Natural Deduction*.

The Natural Deduction system was invented by the logician Gerhard Gentzen in 1934 as a way to formalise proofs in logic. We will be using a variant of Gentzen's system that is designed to be easy to use for building proofs interactively.

The key feature of Natural Deduction is its *modularity*. There are two basic rules of the system, `Done` and `Use`, that allow us to manage assumptions. Then there are separate rules for each connective "and", "implies", "or" and "not". For each connective, we have Introduction rules that tell us how to prove a statement using that connective, and Elimination rules that tell us how to use a statement built from that connective. The natural symmetry between introduction and elimination rules gives the whole system a balanced feel.

## Judgements {id=natural-deduction:judgements}

The proof system we will use allows us to deduce statements that look like this:

```
    P₁, ..., Pₙ ⊢ Q
```

We read this as “from the assumptions `P₁`, ..., and `Pₙ`, we can prove `Q`”.

This looks and sounds similar to the statement `P₁, ..., Pₙ ⊧ Q` that indicates [entailment](entailment.md), but now we use the symbol `⊢` to indicate *provability* instead of semantic entailment (“semantic” meaning worked out in terms of the meanings of the formulas).

These two symbols are connected by the important definition of **Soundness**:

> A proof system is **sound** if P₁, ..., Pₙ ⊢ Q means that P₁, ..., Pₙ ⊧ Q

In other words, a proof system is sound if everything that is provable is true.

The converse to soundness is completeness (everything that is true is provable). We will come back to this at the end of this page.

We will also make use of an auxillary judgement, which picks out one of the assumptions as special:

```
    P₁, ..., Pₙ [P] ⊢ Q
```

This also means “from the assumptions `P₁`, ..., `Pₙ`, and `P` we can prove `Q`”, but the additional `[P]` indicates that the assumption `P` is *in focus*. We can think of this as indicating which assumption we are currently working on.

Because it is boring and messy to write out `P₁, ..., Pₙ` over and over again, we will use `Γ` as a shorthand to stand for zero or more assumptions. This will make writing the rules much easier.

## The basic rules: `done` and `use` {id=natural-deduction:done-use}

The two basic rules of the system are `done` and `use`. These look like this:

```rules-display
(config
 (rule
  (name "done")
  (premises)
  (conclusion "Γ [P] ⊢ P"))
 (rule
  (name "use")
  (premises "P ∈ Γ" "Γ [P] ⊢ Q")
  (conclusion "Γ ⊢ Q")))
```

- The rule `Done` means: to prove the conclusion `P`, then if we have the assumption `P` in focus, we are done.
- The rule `Use` means: if we are proving `Q` with nothing in focus, then we can choose an assumption `P` in `Γ` (this is what `P ∈ Γ` means) and put it in our focus. The premise `P ∈ Γ` is a *side condition*, it is not part of the proof proper, but something that we (or the computer) has to check when using the rule.

**Exercise** Let's put these rules into practice. The following proof can be completed just using `use` and `done`. In order to distinguish the assumptions we name them when building proofs on a computer. We use those names when referring to them in the `use` rule.

To complete this proof first enter `use H` into the box, and then `done`.

```focused-tree {id=prop-nd-1}
(config
 (assumptions (H "A"))
 (goal "A")
 (solution (Rule (Use H) ((Rule Close ())))))
```

**Exercise** Names become important when there are multiple assumptions. Complete the following two proofs. How many ways are there of doing the first proof?

1. Two identical assumptions with different names:

   ```focused-tree {id=prop-nd-2}
   (config
	(assumptions (H1 "A") (H2 "A"))
	(goal "A"))
   ```

2. Two different assumptions with different names:

   ```focused-tree {id=prop-nd-3}
   (config
	(assumptions (H1 "A") (H2 "B"))
	(goal "B"))
   ```

**Exercise** The tree layout for proofs quickly gets too large to be manageable. An alternative layout for the proofs lists the rules used in an almost bullet-list style. Try the same proof again, but in this style:

```focused-nd {id=prop-nd-4}
(config
 (assumptions (H1 "A") (H2 "B"))
 (goal "B"))
```

By clicking on the “Show Proof Tree” button, you can see the corresponding proof tree.

## Rules for the Connectives {id=natural-deduction:rules}

The rules `use` and `done` only allow “librarian logic”. If something is already there in the assumptions, then we can prove it.

The rest of the rules of the system allow us to prove things using the connectives `∧`, `→`, `∨`, and `¬`. Two important organising principles of Natural Deduction are that (a) each rule only talks about one connective, and (b) rules for connectives come in two kinds:

1. **Introduction rules**, which allow us to construct proofs of a formula containing a connective.
2. **Elimination rules**, which allow us to use assumptions containing a connective.

This separation of rules is analogous to the situation in programming where we can *construct* objects (e.g., `new A(x,y)`) and we can do things to objects by calling methods on them (e.g., `x.m()`). We will see the analogy most clearly in the rules for `∧`, which we will look at first.

In our system, *introduction* rules will apply when there is no formula in focus and *elimination* rules will apply when there is a formula is focus. It is the formula that is in focus that we will be eliminating.

### Rules for And {id=natural-deduction:rules:and}

The introduction rule for `∧` is:

```rules-display
(config
 (rule
  (name "split")
  (premises "Γ ⊢ Q₁" "Γ ⊢ Q₂")
  (conclusion "Γ ⊢ Q₁ ∧ Q₂")))
```

In words: to prove `Q₁ ∧ Q₂`, we need to prove `Q₁` and `Q₂`.

**Exercise** Try this rule in the proof editor. The command `split` applies the rule and then the rest of the proof is completed using `use` and `done`.

```focused-nd {id=prop-nd-and-1}
 (config
  (assumptions (H1 A) (H2 B))
  (goal "A /\ B")
  (solution (Rule Split((Rule(Use H1)((Rule Close())))(Rule(Use H2)((Rule Close())))))))
```

The elimination rules for `∧` are:

```rules-display
(config
 (rule
  (name "first")
  (premises "Γ [P₁] ⊢ Q")
  (conclusion "Γ [P₁ ∧ P₂] ⊢ Q"))
 (rule
  (name "second")
  (premises "Γ [P₂] ⊢ Q")
  (conclusion "Γ [P₁ ∧ P₂] ⊢ Q")))
```

In words: if we have `P₁ ∧ P₂` in the focus, then we can either take the first or the second component and carry on the proof.

**Exercise** Using these rules, complete the following proofs using the editor. Type `first` or `second` to use the corresponding rules.

1. There are two proofs of this theorem, one which doesn't use any rules specific to `∧` and one that does.

   ```focused-nd {id=prop-nd-and-2}
   (config
    (assumptions (H "A /\ B"))
    (goal "A /\ B")
	(solution (Rule Split((Rule(Use H)((Rule Conj_elim1((Rule Close())))))(Rule(Use H)((Rule Conj_elim2((Rule Close())))))))))
   ```

2. This proof needs use of all the rules we have seen so far.

   ```focused-nd {id=nd-and-3}
   (config
    (assumptions (H "A /\ B"))
    (goal "B /\ A")
	(solution (Rule Split((Rule(Use H)((Rule Conj_elim2((Rule Close())))))(Rule(Use H)((Rule Conj_elim1((Rule Close())))))))))
   ```

````details
How is this like programming?

The rules for `∧` are very similar to the interface of this Java class. The expression `new Pair(x,y)` constructs a new pair object / proof of `A ∧ B`, and the methods `first()` and `second()` get the objects / proofs from the pair. The proof `use H; first; done` is written in Java as `H.first();`.

```
public class Pair<A,B> {
  private A a;
  private B b;

  public Pair(A a, B b) {
    this.a = a;
	this.b = b;
  }

  public A first() {
    return a;
  }

  public B second() {
    return b;
  }
}
```
````

### Rules for True {id=natural-deduction:rules:true}

The constant truth value `T` only has an introduction rule:

```rules-display
(config
 (rule
  (name "true")
  (conclusion "Γ ⊢ T")))
```

In words: we can always prove `T`.

There is no elimination rule for `T` because a proof of `T` contains no useful information.

**Exercises** Complete the following proofs using the proof rules you have seen so far:

1. Anything entails `T`
   ```focused-nd {id=prop-nd-true-1}
   (config
    (assumptions (H "A"))
    (goal "T")
	(solution (Rule Truth())))
   ```

2. True on the right:
   ```focused-nd {id=prop-nd-true-2}
   (config
    (assumptions (H "A"))
    (goal "A /\ T")
	(solution (Rule Split((Rule(Use H)((Rule Close())))(Rule Truth())))))
   ```

3. True on the left:
   ```focused-nd {id=prop-nd-true-3}
   (config
    (assumptions (H "A"))
    (goal "T /\ A")
	(solution (Rule Split((Rule Truth())(Rule(Use H)((Rule Close())))))))
   ```

### Rules for Implication {id=natural-deduction:rules:implies}

The introduction rule for implication is:

```rules-display
(config
 (rule
  (name "introduce")
  (premises "Γ, P ⊢ Q")
  (conclusion "Γ ⊢ P → Q")))
```

In words: to prove `P → Q`, we prove `Q` assuming `P`.

When we use the `introduce` rule in the proof editor, we need to name the new assumption that is being added. So the full command is `introduce H`, where `H` is the name of the new assumption. Just as with variable names in programming, it is a good idea to use meaningful names for assumptions and not just `H`.

**Exercise** Complete these proofs using `introduce`. They only differ from the proofs above in that `introduce` is needed to start the proof by introducing things into the assumptions.

1. `A` implies `A`:
   ```focused-nd {id=prop-nd-implies-1}
   (config (goal "A -> A")
	(solution (Rule(Introduce a)((Rule(Use a)((Rule Close())))))))
   ```

2. `A ∧ B` implies `B ∧ A`:
   ```focused-nd {id=prop-nd-implies-2}
   (config (goal "(A /\ B) -> (B /\ A)")
	(solution (Rule(Introduce a-and-b)((Rule Split((Rule(Use a-and-b)((Rule Conj_elim2((Rule Close())))))(Rule(Use a-and-b)((Rule Conj_elim1((Rule Close())))))))))))
   ```

The elimination rule for implication is where we start to be able to write proofs of much more complex statements because it allows us to prove conditional statements based on assumptions that are themselves conditional.

The elimination rule is:

```rules-display
(config
 (rule
  (name "apply")
  (premises "Γ ⊢ P₁" "Γ [P₂] ⊢ Q")
  (conclusion "Γ [P₁ → P₂] ⊢ Q")))
```

In words: if we have `P₁ → P₂` in focus, then if we prove `P₁` we can continue our proof with `P₂`.

**Exercises** Complete these proofs using `apply` as well as the other rules we've seen so far.

1. This proof and the next show that repeated implication is the same as implication from an `∧`:

   ```focused-nd {id=nd-prop-implies-3}
   (config (goal "((A /\ B) -> C) -> A -> B -> C")
	(solution (Rule(Introduce ab-implies-c)((Rule(Introduce a)((Rule(Introduce b)((Rule(Use ab-implies-c)((Rule Implies_elim((Rule Split((Rule(Use a)((Rule Close())))(Rule(Use b)((Rule Close())))))(Rule Close())))))))))))))
   ```
2. And back again...

   ```focused-nd {id=nd-prop-implies-4}
   (config (goal "(A -> B -> C) -> (A /\ B) -> C")
	(solution (Rule(Introduce a-implies-b-implies-c)((Rule(Introduce a-and-b)((Rule(Use a-implies-b-implies-c)((Rule Implies_elim((Rule(Use a-and-b)((Rule Conj_elim1((Rule Close())))))(Rule Implies_elim((Rule(Use a-and-b)((Rule Conj_elim2((Rule Close())))))(Rule Close())))))))))))))
   ```

3. This is a proof that implications can be chained together:

   ```focused-nd {id=nd-prop-implies-5}
   (config (goal "(A -> B) -> (B -> C) -> (A -> C)")
	(solution (Rule(Introduce a-implies-b)((Rule(Introduce b-implies-c)((Rule(Introduce a)((Rule(Use b-implies-c)((Rule Implies_elim((Rule(Use a-implies-b)((Rule Implies_elim((Rule(Use a)((Rule Close())))(Rule Close())))))(Rule Close())))))))))))))
   ```

4. This is a lengthy proof that `∧` is associative (in at least one direction). That is, it doesn't matter if the brackets go to the left or the right:

   ```focused-nd {id=nd-prop-implies-6}
   (config (goal "(A /\ B /\ C) -> ((A /\ B) /\ C)")
	(solution (Rule(Introduce a-and-b-and-c)((Rule Split((Rule Split((Rule(Use a-and-b-and-c)((Rule Conj_elim1((Rule Close())))))(Rule(Use a-and-b-and-c)((Rule Conj_elim2((Rule Conj_elim1((Rule Close())))))))))(Rule(Use a-and-b-and-c)((Rule Conj_elim2((Rule Conj_elim2((Rule Close())))))))))))))
   ```

5. This proof uses an implication to update one side of a pair:

   ```focused-nd {id=nd-prop-implies-7}
   (config (goal "(A /\ B) -> (B -> C) -> (A /\ C)")
	(solution (Rule(Introduce a-and-b)((Rule(Introduce b-implies-c)((Rule Split((Rule(Use a-and-b)((Rule Conj_elim1((Rule Close())))))(Rule(Use b-implies-c)((Rule Implies_elim((Rule(Use a-and-b)((Rule Conj_elim2((Rule Close())))))(Rule Close())))))))))))))
   ```

### Rules for Or {id=natural-deduction:rules:or}

The introduction rules for `∨` are the near mirror image of the elimination rules for `∧`:

```rules-display
(config
 (rule
  (name "left")
  (premises "Γ ⊢ Q₁")
  (conclusion "Γ ⊢ Q₁ ∨ Q₂"))
 (rule
  (name "right")
  (premises "Γ ⊢ Q₂")
  (conclusion "Γ ⊢ Q₁ ∨ Q₂")))
```

In words: to prove `Q₁ ∨ Q₂`, you can go left and prove `Q₁` or you can go right and prove `Q₂`.

**Exercise** Use the rule `left` to complete this proof:

1. ```focused-nd {id=prop-nd-or-1}
   (config (goal "A -> (A \/ B)")
	 (solution (Rule (Introduce a)((Rule Left ((Rule (Use a) ((Rule Close ())))))))))
   ```

The elimination rule for `∨` is more complex, but in some sense is similar to the introduction rule for `∧`:

```rules-display
(config
 (rule
  (name "cases")
  (premises "Γ, P₁ ⊢ Q" "Γ, P₂ ⊢ Q")
  (conclusion "Γ [P₁ ∨ P₂] ⊢ Q")))
```

In words: if we have `P₁ ∨ P₂` in the focus, then to continue the proof we need to split into two proofs: one where `P₁` is assumed and one where `P₂` is assumed.

Comparing this rule to the introduction rule for `P₁ ∧ P₂` we can see that they both split the proof into two cases. The difference is that we split the conclusion to prove an `∧` and split an assumption to prove a `∨`.

Just as for `introduce`, the rule `cases` introduces new assumptions. This means that we need to name them when we use the rule. The full syntax is `cases H1 H2`, where `H1` and `H2` are the names of the two new assumptions (again, it is a good idea to use meaningful names).

**Exercises** Complete the following proofs using the rules for implication and or. Check the solutions if you get stuck.

1. ```focused-nd {id=prop-nd-or-2}
   (config (goal "(A \/ B) -> (A -> C) -> (B -> C) -> C")
	(solution (Rule(Introduce a-or-b)((Rule(Introduce a-implies-c)((Rule(Introduce b-implies-c)((Rule(Use a-or-b)((Rule(Cases a b)((Rule(Use a-implies-c)((Rule Implies_elim((Rule(Use a)((Rule Close())))(Rule Close())))))(Rule(Use b-implies-c)((Rule Implies_elim((Rule(Use b)((Rule Close())))(Rule Close())))))))))))))))))
   ```
2. ```focused-nd {id=prop-nd-or-3}
   (config (goal "(A \/ B) -> (A -> C) -> (B -> D) -> (C \/ D)")
	(solution (Rule(Introduce a-or-b)((Rule(Introduce a-implies-c)((Rule(Introduce b-implies-d)((Rule(Use a-or-b)((Rule(Cases a b)((Rule Left((Rule(Use a-implies-c)((Rule Implies_elim((Rule(Use a)((Rule Close())))(Rule Close())))))))(Rule Right((Rule(Use b-implies-d)((Rule Implies_elim((Rule(Use b)((Rule Close())))(Rule Close())))))))))))))))))))
   ```
3. ```focused-nd {id=prop-nd-or-4}
   (config (goal "((A \/ B) -> C) -> ((A -> C) /\ (B -> C))")
	(solution (Rule(Introduce a-or-b-implies-c)((Rule Split((Rule(Introduce a)((Rule(Use a-or-b-implies-c)((Rule Implies_elim((Rule Left((Rule(Use a)((Rule Close())))))(Rule Close())))))))(Rule(Introduce b)((Rule(Use a-or-b-implies-c)((Rule Implies_elim((Rule Right((Rule(Use b)((Rule Close())))))(Rule Close())))))))))))))
   ```
4. ```focused-nd {id=prop-nd-or-5}
   (config (assumptions (H "A \/ (B /\ C)"))
		   (goal "(A \/ B) /\ (A \/ C)")
		   (solution (Rule Split((Rule(Use H)((Rule(Cases a b-and-c)((Rule Left((Rule(Use a)((Rule Close())))))(Rule Right((Rule(Use b-and-c)((Rule Conj_elim1((Rule Close())))))))))))(Rule(Use H)((Rule(Cases a b-and-c)((Rule Left((Rule(Use a)((Rule Close())))))(Rule Right((Rule(Use b-and-c)((Rule Conj_elim2((Rule Close())))))))))))))))
   ```
5. ```focused-nd {id=prop-nd-or-6}
   (config (assumptions (H "(A \/ B) /\ (A \/ C)"))
		   (goal "A \/ (B /\ C)")
		   (solution (Rule(Use H)((Rule Conj_elim1((Rule(Cases a b)((Rule Left((Rule(Use a)((Rule Close())))))(Rule(Use H)((Rule Conj_elim2((Rule(Cases a c)((Rule Left((Rule(Use a)((Rule Close())))))(Rule Right((Rule Split((Rule(Use b)((Rule Close())))(Rule(Use c)((Rule Close())))))))))))))))))))))
   ```

### Rules for False {id=natural-deduction:rules:false}

Just as `T` only has an introduction rule. `F` (for False) only has an elimination rule:

```rules-display
(config
 (rule
  (name "false")
  (conclusion "Γ [F] ⊢ Q")))
```

In words: if we have an assumption of `F` in our focus, then we can prove anything. Implicitly, we are assuming that `F` is true, which it isn't, so we are in a situation where our assumptions are contradictory and we can prove anything.

**Exercise** Complete the following proofs. The new rule is `false`.

1. ```focused-nd {id=prop-nd-false-1}
   (config (goal "F -> A"))
   ```
2. ```focused-nd {id=prop-nd-false-2}
   (config (goal "(A \/ F) -> A"))
   ```
3. ```focused-nd {id=prop-nd-false-3}
   (config (goal "A -> (A -> F) -> B"))
   ```

### Rules for Negation {id=natural-deduction:rules:negation}

Given the rules so far, we could *define* negation as:

```
¬P = P → F
```

This would be nice because we wouldn't need to define any new rules for it. We would simply use the rules for implication and `F`.

Nevertheless, in the spirit of keeping the system modular, and because it makes the formulas look nicer, we include explicit rules for negation. The introduction rule is:

```rules-display
(config
 (rule
  (name "not-intro")
  (premises "Γ, P ⊢ F")
  (conclusion "Γ ⊢ ¬P")))
```

(notice that this breaks our convention of only mentioning one connective in each rule: this mentions `¬` and `F`.)

In words: to prove `¬P`, we prove that assuming `P` proves `F`.

As for `introduce` and `cases`, `not-intro` adds a new assumption so it needs a name for this new assumption.

**Exercise** Prove that adding this rule is enough to show that `(A → F)` implies `¬A`:

```focused-nd {id=prop-nd-not-1}
(config (goal "(A -> F) -> ¬A"))
```

The elimination rule for `¬` is:

```rules-display
(config
 (rule
  (name "not-elim")
  (premises "Γ ⊢ P")
  (conclusion "Γ [¬P] ̌⊢ Q")))
```

In words: if we have `¬P` in focus, then proving `P` will allow us to conclude `Q`.

**Exercises**

1. The elimination rule for `¬` allows us to prove the other direction of the equivalence between `¬A` and `A -> F`:

   ```focused-nd {id=prop-nd-not-2}
   (config (goal "¬A -> (A -> F)"))
   ```

2. We can also prove that contradictory assumptions allow us to prove anything:

   ```focused-nd {id=prop-nd-not-3}
   (config (goal "A -> ¬A -> B"))
   ```

3. And one half of the double negation equivalence:

   ```focused-nd {id=prop-nd-not-4}
   (config (goal "A -> ¬¬A"))
   ```

   But can we prove the other direction of the double negation equivalence?

## Soundness, Completeness, and Philosophy {id=natural-deduction:sound-complete}

With the rules we have so far, it is not possible to prove the other direction of the double negation equivalence:

```focused-nd {id=prop-nd-dne-fail}
(config (goal "¬¬A -> A"))
```

If you try this proof using `not-elim`, you will get stuck trying to prove `¬A` from the assumption that `¬¬A` is true. Trying to use the assumption again just gets you back to where you started.

Another thing we can't prove is the “law of excluded middle”: `A ∨ ¬A`:

```focused-nd {id=prop-nd-excluded-middle-fail}
(config (goal "A \/ ¬A"))
```

The failure to prove this is even more obvious. With the rules we have so far, the only rules that apply are `left` and `right`. But if we use either of these then we get stuck in a situation where we are proving `A` or `¬A` from no assumptions. If the system is sound, then surely this can't be possible!

On the other hand, `A ∨ ¬A` is true in our two-valued semantics.

This failure means that the proof system so far is **incomplete** for the two-valued `True`/`False` semantics. There are things that are valid, but we cannot prove them.

If we assume excluded middle for `A`, then we can prove the other direction of the double negation equivalence: that not not `A` implies `A`:

```focused-nd {id=prop-nd-dne-with-excluded-middle}
(config (assumptions ("excluded-middle" "A \/ ¬A"))
        (goal "¬¬A -> A")
		(solution (Rule(Introduce not-not-a)((Rule(Use excluded-middle)((Rule(Cases a not-a)((Rule(Use a)((Rule Close())))(Rule(Use not-not-a)((Rule NotElim((Rule(Use not-a)((Rule Close())))))))))))))))
```

We can fix the incompleteness by adding a new rule:

```rules-display
(config
 (rule
  (name "excluded-middle")
  (premises "Γ, P ⊢ Q" "Γ, ¬P ⊢ Q")
  (conclusion "Γ ⊢ Q")))
```

This rule is slightly odd in that it applies to the proof of any formula `Q`, with nothing in focus, and says that for any other `P` we get to complete the proof under the assumption that either `P` is true or is false.

Adding this rule would make the system complete with respect to the two-valued semantics. But is it a good idea to do so?

### Classical vs Intuitionistic Mathematics {id=natural-deduction:sound-complete:classical-intuitionistic}

Of course, if we are interested in things that are definitely either true or false, then not having excluded middle is bad. But it is worth having a think about what we are doing with our logic.

One view of logic is that we are using it to reason about things that exist independently of us and have properties regardless of whether we can percieve them. Numbers, shapes, sequence of numbers, even infinite ones, are all assumed to have definite properties. So if we have an infinite sequence of numbers, the question of whether or not one of those numbers is zero has a definite answer. Either it does or it doesn't. In this view (the “classical” view), logical statements are about what *is*, and what *is* is either True or False.

Another point of view is that logical statements represent possible observations that we (or a computer) can *percieve* or have evidence for. For an infinite sequence of numbers, we cannot say for certain whether it contains a zero unless we have a way of actually finding it. If we do not have such a way (because searching an infinite sequence would never end), then we cannot make the statement that the sequence has a zero in it or not.

This second viewpoint is known as *Intuitionism* and was devised by the mathematician L. E. J. Brouwer in the early 20th century. The original justification by Brouwer was in terms of his personal beliefs about how mathematics is an activity that only exists in our heads and has no external reality. As a philosophy, it is tricky to separate from ideas about psychology and so on. Nevertheless, it has been extremely influential in Computer Science, due to the connection between the idea that logical statements are things that can have evidence, and the idea that data in a computer are evidence. We can make the following table:

| Evidence of... | Is...                                                         |
|----------------|---------------------------------------------------------------|
| `T`            | there is always evidence of `T`                               |
| `F`            | there is no evidence of `F`                                   |
| `P ∧ Q`        | evidence of `P` and evidence of `Q`                           |
| `P ∨ Q`        | evidence of `P` or evidence of `Q` and we know which          |
| `P → Q`        | a process for converting evidence of `P` into evidence of `Q` |

We have already discussed the similarity of the rules for `∧` and those for a `Pair` class in Java. But it is the final row in this table that really connects to Computer Science: evidence of an implication is a *program* that converts evidence from its inputs to evidence in its outputs. If you do CS410 *Advanced Functional Programming* in 4th year, then you will see this idea taken to its logical conclusion.

The evidence interpretation of logic shows immediately that excluded middle (and therefore double negation elimination) is not sound for this interpretation. To produce evidence of `A ∨ (A → F)` for any `A`, then we would need to be able to look at `A` and *decide* whether or not it is true. As we shall see later in the course, there are some problems that are undecidable by any computer program.

**Exercise** The [three-valued](tutorial-0-three-valued.md) interpretation also does not have excluded middle. Is it a suitable interpretation for the proof system we have built in this page?

```details
Answer...

No, because the three-valued interpretation also supports the double negation equivalence `A = ¬¬A`. The proof system we have built does not support either of these. Also, both the Kleene and Łukasiewicz implications act very differently to the implication in the proof system we have described here.
```
