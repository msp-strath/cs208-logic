# Truth Tables, Satisfiability and Validity

Truth tables are a way of systematically working out the truth value assigned to a formula for each possible valuation (assignment of truth values to atoms). We work out the value of `〚P〛v` for every possible `v` in a single large table. The overall process for working out a truth table is similar to the above process for working out `〚P〛v` — we break the formula down into subformulas and compute the truth values assigned "bottom up" — but we arrange the work slightly differently. Truth tables are useful for working out truth value assignments for all possible assignments without missing any accidentally.

## Video

```youtube
okddmJ1xVgg
```

[Slides (PDF)](week01-slides.pdf)

## Truth Tables by Example

Let's see how truth tables work by example. Let's say we want to write
a truth table for the formula:

```formula
   (A ∨ B) ∧ ¬ A
```

We start by writing out all the possible values of the atoms `A` and `B`. There are four lines, because there are `2² = 4` possible valuations with two atoms. We will fill in the rest of the table below.

| A | B | ... |
|---|---|-----|
| F | F |     |
| F | T |     |
| T | F |     |
| T | T |     |

Now we will fill in more columns by looking at the \emph{subformulas}
of the original formula. Subformulas of a formula are the subtrees of
the formula when it is written out as a tree. For our formula
`(A ∨ B) ∧ ¬ A`, the top-level connective is `∧` and the subformulas are

```formula
  A ∨ B
```

and

```formula
  ¬ A
```

We add these columns to our table:

| A | B | A ∨ B | ¬ A | ... |
|---|---|-------|-----|-----|
| F | F |       |     |     |
| F | T |       |     |     |
| T | F |       |     |     |
| T | T |       |     |     |

Now we fill in the table, using the values of `A` and `B` for each row, and the look-up tables for each connective. So for the `A ∨ B` column, we have:

| A | B | A ∨ B | ¬ A | ... |
|---|---|-------|-----|-----|
| F | F | F     |     |     |
| F | T | T     |     |     |
| T | F | T     |     |     |
| T | T | T     |     |     |

and filling in the `¬ A` column gives:

| A | B | A ∨ B | ¬ A | ... |
|---|---|-------|-----|-----|
| F | F | F     | T   |     |
| F | T | T     | T   |     |
| T | F | T     | F   |     |
| T | T | T     | F   |     |

Notice that in this step we have had to repeat the same work twice: the value of `¬ A` only depends on the value of `A`, but we had to write down the answer twice for each possible value of `B`. Nevertheless, we need to compute the value of `¬ A` for every possible valuation for the table to work.

Now we have done all the subformulas of the formula we want, we add a final column for the whole formula.

| A | B | A ∨ B | ¬ A | (A ∨ B) ∧ ¬ A |
|---|---|-------|-----|---------------|
| F | F | F     | T   |               |
| F | T | T     | T   |               |
| T | F | T     | F   |               |
| T | T | T     | F   |               |

Now we fill in this column by identifying the topmost connective in
the formula, in this case `∧`, and then using the truth table for
that connective with the
truth values we have worked out for each subformula in columns 3 and
4.

Note that now the truth values may not appear in the same order as they do in the tables defining the connectives. For each line, we have to make sure we look up the right row in the table for the connective. Doing this for `∧` with columns 3 and 4 gives:

| A  | B  | A ∨ B | ¬ A | (A ∨ B) ∧ ¬ A  |
|----|----|-------|-----|----------------|
| F  | F  | F     | T   | F              |
| F  | T  | T     | T   | T              |
| T  | F  | T     | F   | F              |
| T  | T  | T     | F   | F              |

Which is the complete truth table for this formula.

### Summary

Steps for writing out a truth table for a formula `P`:

1. Identify all the atomic propositions in the formula `P` and write those down as the first `n` columns.

2. Write down all the possible values of the atoms in these columns. You should have `2ⁿ` rows for `n` atoms, with no repeats.

3. Identify all the subformulas of `P` (i.e., the subtrees) and write them down as extra columns.

4. For each subformula, identify the connective that is being used and the columns that describe the inputs to that connective. For each line and column, use the lookup table for that connective to fill in the column.

5. Finally, add a column for the whole formula at the end and fill in the column in the same way as for the subformulas.

## Satisfiability

A formula `P` is *satisfiable* if there exists at least one valuation `v` that makes it true. In other words, there is at least one valuation `v` such that `〚P〛v = T`. A valuation that makes a formula true is called a *satisfying valuation* (or *satisfying assignment*).

If we think of valuations as "possible states of the world", then a formula `P` being satisfiable means that there is at least one state of the world where this formula is true. By encoding "real-world" problems as logical formulas, finding satisfying valuations amounts to finding solutions to those problems, as we shall see in [Part 1 : Logical Modelling](logical-modelling-intro.html).

If you are asked to show that a formula is satisfiable, then what you have to do is find a valuation `v` (i.e., a value for each of the atoms) that makes the formula true. There are several ways to find such a valuation. There are specialised programs, called *SAT Solvers* whose job is to find satisfying assignments for very large formulas. [SAT Solvers](sat-solvers.html) have their own page.

One systematic way to check that a formula is satisfiable by hand is to write out its truth table. **If there is at least one line where the formula is given the truth value `T`, then the formula is satisfiable**.

Let's see an example. Here is the truth table for the formula `(A ∨ B) ∧ ¬ A` that we worked out in the previous section:

| A  | B  | A ∨ B | ¬ A | (A ∨ B) ∧ ¬ A  |
|----|----|-------|-----|----------------|
| F  | F  | F     | T   | F              |
| F  | T  | T     | T   | T              |
| T  | F  | T     | F   | F              |
| T  | T  | T     | F   | F              |

Looking at this table, we can see that there is at least one row where the whole formula is assigned the value `T` (the second one). In this case the valuation is `{A ↦ F; B ↦ T}`. So we can say that this valuation is a satisfying valuation for the formula `(A ∨ B) ∧ ¬ A`.

If we change the formula by adding `∧ ¬ B`, then we get the formula `(A ∨ B) ∧ ¬ A ∧ ¬ B`, and a different truth table:

| A | B | A ∨ B | ¬ A | (A ∨ B) ∧ ¬ A | ¬ B | (A ∨ B) ∧ ¬ A ∧ ¬ B |
|---|---|-------|-----|---------------|-----|---------------------|
| F | F | F     | T   | F             | T   | F                   |
| F | T | T     | T   | T             | F   | F                   |
| T | F | T     | F   | F             | T   | F                   |
| T | T | T     | F   | F             | F   | F                   |

Now none of the rows has a `T` in the final column. Therefore we say that this formula is **not** satisfiable.

## Validity

A formula `P` is *valid* if **all valuations `v` make it true**. In other words, if for all valuations `v`, we have `〚P〛v = T`, then `P` is valid. Valid formulas are also called *tautologies*.

We can think of a valid formula as something that is true no matter what state of the world we are in. Validity is therefore a kind of "dual" to satisfiability: valid formulas must always hold, satisfiable formulas must never not hold. We will exploit this relationship between validity and satisfiability below.

If you are asked to show a formula is valid, then you can use a truth table. For validity, we must have that every row of the table has `T` in the final column. Going back to our example formula `(A ∨ B) ∧ ¬ A`, we have the truth table:

| A  | B  | A ∨ B | ¬ A | (A ∨ B) ∧ ¬ A  |
|----|----|-------|-----|----------------|
| F  | F  | F     | T   | F              |
| F  | T  | T     | T   | T              |
| T  | F  | T     | F   | F              |
| T  | T  | T     | F   | F              |

Looking at the table, we can see that this formula is not valid: rows 1, 3 and 4 are all `F` in the final column. All rows must end with `T` for a formula to be valid.

If we modify the formula to be `((A ∨ B) ∧ ¬ A) → B`, then we get the truth table:

| A | B | A ∨ B | ¬ A | (A ∨ B) ∧ ¬ A | ((A ∨ B) ∧ ¬ A) → B |
|---|---|-------|-----|---------------|---------------------|
| F | F | F     | T   | F             | T                   |
| F | T | T     | T   | T             | T                   |
| T | F | T     | F   | F             | T                   |
| T | T | T     | F   | F             | T                   |

The formula `((A ∨ B) ∧ ¬ A) → B` is valid, because every row's final column is `T`. Intuitively, we can see why: an implication `P → Q` is true if, whenever `P` is true, then `Q` is true. Looking at the previous truth table above, we can see that whenever `(A ∨ B) ∧ ¬ A` is true, then `B` is true. Therefore, the formula `((A ∨ B) ∧ ¬ A) → B` is valid.

Validity defines when a formula is "true" in itself. More generally, we will want to know what it means for a formula *under some assumptions*. This is the idea behind [entailment](entailment.html).

## Relationship between Satisfiability and Validity

The following relationship between satisfiability and validity is often useful. Especially when we have [SAT solvers](sat-solvers.html) for automatically determining whether or not a formula is satisfiable.

> A formula `P` is valid exactly when `¬ P` is **not** satisfiable.

We can see this is the case by thinking about generic truth tables for `P` and `¬ P`. If `P` is valid, then all rows will be `T`:

| ... | P   |
|-----|-----|
| ... | T   |
| ... | T   |
| ... | ... |
| ... | T   |

If add a column to represent `¬ P`, then it will always be `F`, by the definition of `¬`: `¬ T = F`.

| ... | P   | ¬P  |
|-----|-----|-----|
| ... | T   | F   |
| ... | T   | F   |
| ... | ... | ... |
| ... | T   | F   |

Since `¬ P` is false for all valuations it is *not* satisfiable. So `P` being valid implies that `¬ P` is not satisfiable.

In the opposite direction, if `¬ P` were satisfiable, then there would be a row where `¬ P` is `T`. The same row would therefore have `P` being `F`, again because `¬ T = F`. Therefore, `P` would not be valid. So `¬ P` being satisfiable means `P` is not valid.
