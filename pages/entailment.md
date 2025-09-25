# Topic 1.1: Entailment

```aside
This page assumes you have understood Topic 0: the [syntax](prop-logic-syntax.html) and [semantics](prop-logic-semantics.html) of Propositional Logic, and [truth tables](truth-tables.html).
```

One of the uses of logic (and possibly the most important one) is to identify when conclusions do and do not follow from some assumptions.

Logic does not concern itself with whether or not whether or not the assumptions are actually true, only the question of whether or not the formulas we are assuming are sufficient to conclude some other formula.

If a conclusion `Q` follows from some assumptions `P₁, P₂...` (in a rigorous way we define below), we will say that the assumptions `P₁, P₂...` *entails* `Q`. I will also write this in symbols:

```
  P₁, P₂ ... ⊧ Q
```

The assumptions `P₁, P₂...` may be finitely or infinitely many, though we will usually only be interested in finitely many assumptions.

The intuitive definition of entailment is the following:

> If all the assumptions `P₁, P₂, ...` are true, then the conclusion is true.

To make this formal, we must be explicit about valuations. So the full definition of entailment is:

>  Assumptions `P₁, P₂...` *entail* a conclusion `Q` (written `P₁, P₂, ... ⊧ Q`) if, for all valuations `v`, **whenever all the assumptions are true under `v` (i.e., for all `i`, `〚P_i〛v = T`), then the conclusion is true under `v` (i.e., `〚Q〛v = T`)**.

The definition of entailment can be subtle and difficult to understand at first without working through a few examples, so let's do that.

## Example Entailments

For Propositional Logic, it is possible to compute entailments by using truth tables. Let's see how to do this by some examples. These examples will also introduce some of the interesting consequences of the definition of entailment.

### “A” entails “A”

Our first example is the entailment `A ⊧ A`. Inituitively, this entailment ought to hold: if we assume `A`, then we should be able to conclude `A`. Let us check this by writing a truth table. We first write out all the possible values of `A`. These are all our different valuations, so we explicitly mark these columns as our valuation:

| A (valuation) | ... |
|---------------|-----|
|               |     |

Then we write down our assumptions as further columns and fill in the truth values. If our assumptions are composed of multiple connectives, we might need to put in extra columns for intermediate working. In this case, we only have one assumption which is just `A`, so we can write down directly:

| A (valuation) | A (assumption) | ... |
|---------------|----------------|-----|
|               |                |     |

To complete the table, we compute the values of the conclusion for each valuation. Again, this might require some intermediate working if the conclusion formula is complicated. in this case, it is just `A`, so we can write it down directly and fill out the rows in the table for all possible values of `A`:

| A (valuation) | A (assumption) | A (conclusion) |
|---------------|----------------|----------------|
| F             | F              | F              |
| T             | T              | T              |

Now, to check the entailment we have to check: for every valuation (row), if all the assumptions are true, then the conclusion is true. If this holds in every valuation (row), then entailment is valid. Otherwise, it is invalid.

Checking this table, we can see that the entailment holds. In the first row, the assumption is false, so we are OK. In the second row, the assumption is true, but so is the conclusion, so we are OK. After checking every row, we can conclude that `A ⊧ A`.

### “A and B” entails “A”

The entailment `A ∧ B ⊧ A` is a little more complex because there are two propositional atoms `A` and `B`. I will write out the table all in one go:

| A (valuation) | B (valuation) | A ∧ B (assumption) | A (conclusion) |
|---------------|---------------|--------------------|----------------|
| F             | F             | F                  | F              |
| T             | F             | F                  | T              |
| F             | T             | F                  | F              |
| T             | T             | T                  | T              |

Again, we check each valuation (row) to see whether whenever all the
assumptions are true, the conclusion is true. For this table:

- In rows 1 and 3: the assumption `A ∧ B` is false, so it does not matter that the conclusion is false.
- In row 2: the assumption is false and the conclusion is true. Since the assumption is false, we do not actually care what the conclusion is.
- In row 4: the assumption is true, so we need to check the conclusion. The conclusion is also true, so this row is good.

Together, for each row, we have that if the assumption is true, then the conclusion is true. Therefore, the entailment `A ∧ B ⊧ A` is valid.

### “A or B” does not entail “A”

The truth table for this entailment looks like this.

| A (valuation) | B (valuation) | A ∨ B (assumption) | A (conclusion) |
|---------------|---------------|--------------------|----------------|
| F             | F             | F                  | F              |
| F             | T             | T                  | F              |
| T             | F             | T                  | T              |
| T             | T             | T                  | T              |

In the second row, we can see that the assumption is `T` but the conclusion is `F`. Therefore this entailment is *not* valid.

Intuitively, this is because if we assume that `A ∨ B` is true, then we cannot safely conclude `A` is definitely true, because it might be that `B` is true and not `A`. This is exactly the situation described in the second row of the table.

### Atomic Propositions stand for any Formula

If we know that an entailment `P1, ..., Pn ⊧ Q` holds, then we can replace ("substitute") any of the atomic propositions in the `P1`,..., `Pn` and `Q` with any other formula and we still get a valid entailment. We do have to do the same substitution everywhere though, this does not work if we only substitute in some of the assumptions or conclusion.

For example, above we saw that the entailment `A ∧ B ⊧ A` holds. By substituting `C → D` for `A`, we can immediately deduce that `(C → D) ∧ B ⊧ C → D` is a valid entailment.

In general, we have that if `P1, ..., Pn ⊧ Q` then `P1[A := R], ..., Pn[A := R] ⊧ Q[:= R]`, where `P[A := R]` means “replace all `A`s in `P` with `R`”. We will come back to substitution in [Topic 3: Scope and Substitution](scope-and-substitution.html).

### Implication internalises entailment

The following table shows that if we assume `A → B` and `A`, then we can conclude `B`.

| A (valuation) | B (valuation) | A → B (assumption) | A (assumption) | B (conclusion) |
|---------------|---------------|----------------------|----------------|----------------|
| F             | F             | T                    | F              | F              |
| F             | T             | T                    | F              | T              |
| T             | F             | F                    | T              | F              |
| T             | T             | T                    | T              | T              |

There is only one case where all of the assumptions are true: the last row. In this case it is also the case that the conclusion is true. Therefore, the entailment `A → B, A ⊧ B` holds.

There is another connection between implication and entailment. Whenever the entailment `A, B ⊧ C` holds, then so does `A ⊧ B → C`. To see this look at the following table, where the last two columns are filled in with `T` if that entailment holds for this valuation and false otherwise.

| A (valuation) | B (valuation) | C (valuation) | A, B ⊧ C | A ⊧ B → C (conclusion) |
|---------------|---------------|---------------|----------------|--------------------------------|
| F             | F             | F             | T              | T                              |
| F             | F             | T             | T              | T                              |
| F             | T             | F             | T              | T                              |
| F             | T             | T             | T              | T                              |
| T             | F             | F             | T              | T                              |
| T             | F             | T             | T              | T                              |
| T             | T             | F             | F              | F                              |
| T             | T             | T             | T              | T                              |

Checking the last two columns, we can see that they are equal for all valuations. Therefore, we have an equivalence between `A, B ⊧ C` and `A ⊧ B → C`.

### Adding assumptions

If we know `A ⊧ B`, then we also know `C, A ⊧ B`.

**Exercise** Write out a truth table to show this.

```textbox {id=entailment-1}
```

### Contradictory assumptions

One non-intuitive feature of entailment is that if the assumptions are contradictory, then we can conclude anything. This is demonstrated by the following truth table, which has two assumptions `A` and `¬A`:

| A (valuation) | B (valuation) | A (assumption) | ¬A (assumption) | B (conclusion) |
|---------------|---------------|----------------|-----------------|----------------|
| F             | F             | F              | T               | F              |
| F             | T             | F              | T               | T              |
| T             | F             | T              | F               | F              |
| T             | T             | T              | F               | T              |

There are **no** rows where all the assumptions are true, so the entailment `A, ¬A ⊧ B` holds. The proposition `B` is completely arbitrary so it can be anything.

This is one of the sometimes surprising features of two-valued logic (and of many other logical systems). Intuitively, it should not always be the case. If a database contains two pieces of contradictory evidence (e.g., that the same person is 25 years old and 45 years olds), then it should not be allowed to conclude that the moon is made of cheese. This is the motivation for other logical systems, such as the one discussed in [three-valued logic](tutorial-0-three-valued.html), or for careful logical modelling.

### Chaining entailments

If we know `A ⊧ B` and `B ⊧ C`, then we know that `A ⊧ C`. This allows us to chain together entailments to make chains of reasoning from assumptions to conclusions.

**Exercise** Write out truth tables to convince yourself of this fact.

```textbox {id=entailment-2}
```

**Exercise** Deduce this from the properties of implication (`A → B`) described above.

```textbox {id=entailment-3}
```

## Towards Proof Systems

The facts about entailment listed above build up to give a list of things that we know about our logic:

1. `A ∧ B ⊧ A` (above)
2. `A ∧ B ⊧ B` (exercise!)
3. `A → B, A ⊧ B` (above)
4. If `A, B ⊧ C` then `A ⊧ B → C` (above)
5. If `A ⊧ B` then `A, C ⊧ B`
6. If `P1, ..., Pn ⊧ Q` then `P1[A := R], ..., Pn[A := R] ⊧ Q[:= R]` (above)

and so on. Once we have enough of these facts, we can chain them together to prove larger properties without having to write out truth tables. This is the motivation for proof systems, which we introduce [next](proof-intro.html).
