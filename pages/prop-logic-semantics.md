# Propositional Logic: Semantics

In the [previous section](prop-logic-syntax.html) I described what logical formulas look like, but not their *semantics*: what the formulas *mean*.

For most of this course, we will define the meaning of a formula to be its *truth value*, assuming that we know truth values of its atoms (a *valuation*).

Once we have defined the meaning of formulas in terms of the truth values of their atoms, we can define several useful properties of formulas in terms of their truth values. The most important property is [entailment](entailment.html), which is a definition of when a collection of assumptions *entails* some conclusion.

## Video

This video covers the material written in words and symbols below.

```youtube
xYxPxZe2n98
```

[Slides (PDF)](week01-slides.pdf)

## Truth Values

For the logic we are studying, we have two *truth values*:

| Value   | Usual Meaning  |
|---------|----------------|
| `T`     | meaning "true" |
| `F`     | meaning "false"|

`T` is sometimes also written as `True`, `⊤`, `1`.

`F`is sometimes also written as `False`, `⊥`, `0`.

Logics with other truth values are also possible. A logic with only one truth value is not very interesting, because all formulas will have the same value so we will have no way of telling them apart. Logics with three or more truth values have been used to model concepts like degrees of truth or missing data. It is also possible to have truth values that are collections of values. For example, the set of states of a system for which the formula is true.

## The meaning of atoms: Valuations

A *valuation* is a mapping from atomic propositions (`A`, `B`, `C`, ...)  to truth values `T` and `F`. I will use the letter `v` and similar (`v₁`, `v₂`, ...) to stand for valuations. I will write `v(A)` to stand for the truth value assigned to `A` by the valuation `v`. As this notation implies, we can think of a valuation as a *function* from atomic propositions to truth values.

Valuations are also sometimes called *assignments* (of truth values to atoms).

Here are some example valuations for the atomic propositions `S` and `R`. If we interpret `S` as "it is sunny" and `R` as "it is raining", then we can regard valuations as possible states of the current weather:

1. `v = { S ↦ T, R ↦ F }`

   "It is sunny (`v(S) = T`). It is not raining (`v(R) = F`)"

2. `v = { S ↦ F, R ↦ T }`

   "It is not sunny (`v(S) = F`). It is raining (`v(R) = T`)"

3. `v = { S ↦ T, R ↦ Y }`

   "It is sunny (`v(S) = T`). It is raining (`v(R) = T`)"

As you can see from the examples, I have written out valuations as lists of atomic propositions paired with their truth value, between curly braces (`{` and `}`). When writing out valuations, it is important to keep the following in mind:

1. Each atom can only be assigned one truth value. A valuation cannot be ambiguous as to which truth value an atom is assigned.

2. Every relevant atom must be assigned some truth value. Relevant here means that it appears somewhere in the formulas we are interested in.

3. Two valuations are equal if they assign the same truth values to the same atoms. In other words, the order that we write them down doesn't matter.

4. If we have `n` atoms (`A₁`, `A₂`, ..., `An`), then there are `2ⁿ` possible valuations assigning truth values to all the atoms. Even for relatively small `n`, `2ⁿ` is a very large number, so trying *all* possible combinations of truth values will be infeasible.

## The meaning of connectives

A valuation `v` describes what truth values to give to atoms. To assign truth values to whole formulas, we need to describe what effect each of the connectives has on truth values. We do this by writing out tables for each of the connectives.

### AND (Conjunction)

Here is the table for `P ∧ Q`. Each row is read as "if `P` is this, and `Q` is that, then `P ∧ Q` has the value in the last column".

| P | Q | P ∧ Q |
|:-:|:-:|:-----:|
| F | F |   F   |
| F | T |   F   |
| T | F |   F   |
| T | T |   T   |

So we read this table as saying `F ∧ F = F`, `F ∧ T = F`, `T ∧ F = F`, and `T ∧ T = T`. A good way to remember this table is that `P ∧ Q` is only `T` when *both* its inputs are `T`.

### OR (Disjunction)

Here is the table for `P ∨ Q`. The table is read in the same way as for `∧`, but the values in the final column are different:

| P | Q | P ∨ Q |
|:-:|:-:|:-----:|
| F | F |   F   |
| F | T |   T   |
| T | F |   T   |
| T | T |   T   |

A good way to remember this table is that `P ∨ Q` is only `T` when *at least one* of its inputs are `T`.

### NOT (Negation)

Here is the table for `¬ P`. In this case, there is only one input:

| P | ¬ P |
|:-:|:---:|
| F |  T  |
| T |  F  |

A good way to remember this table is that `¬ P` is true only when `P` is false (and vice versa).

### IMPLIES (Implication)

Finally, this is the table for `P → Q`.

| P | Q | P → Q |
|:-:|:-:|:-----:|
| F | F |   T   |
| F | T |   T   |
| T | F |   F   |
| T | T |   T   |

A good way to remember this table is that `P → Q` means "if `P` is true then `Q` is true". So the only time it is false is when `P` is true but `Q` is false.

Another way to remember this table is that `P → Q` is true when the value of `P` is less than or equal to the value of `Q`. So you could read `P → Q` as `P ≤ Q`.

## The meaning of formulas

Given a formula `P` and a valuation `v`, we assign a truth value to `P` by working our way up the tree described by the formula `P` from the atoms at the leaves. I will write `〚P〛v` for "the truth value assigned to `P` with the valuation `v`". The `〚...〛` notation is used to stand for "the semantics of ...". Here I am using it to define the semantics of formulas in terms of their truth values, given a valuation of their atoms.

At the leaves, we have atoms that are given truth values by the
valuation:

```
   〚A〛v = v(A)
```

For formulas built from connectives, we assign truth tables by taking the truth values assigned to their subformulas (i.e., subtrees) and combining them using the tables for each of the connectives. In symbols, we have:

```
 〚 P ∧ Q 〛v = 〚 P 〛v ∧ 〚 Q 〛v
 〚 P ∨ Q 〛v = 〚 P 〛v ∨ 〚 Q 〛v
 〚 ¬ P 〛v   = ¬ 〚 P 〛v
 〚 P → Q 〛v = 〚 P 〛v → 〚 Q 〛v
```

This definition may look odd because it looks like we are defining `∧` to mean `∧`, `∨` to mean `∨` and so on. This is only a coincidence of notation though: the connectives inside the `〚...〛` brackets are the *syntax* of propositional logic, just symbols. The connectives outside the `〚...〛` refer to the *meanings* of the connectives as defined by the truth tables above.

### Example

Let's say that we wish to work out the truth value
assigned to the formula `(A ∨ B) ∧ ¬ A` under the valuation
`{A ↦ F; B ↦ T}`. In symbols, we want to
work out the value of:

```
  〚(A ∨ B) ∧ ¬ A〛({A ↦ F; B ↦ T})
```

Since the valuation `{A ↦ F; B ↦ T}` is quite long, I will just write it as `v` for short.

We compute the value of `〚(A ∨ B) ∧ ¬ A〛v` by
repeatedly applying the equations above, working from the topmost
connective to the leaves of the tree described by the formula. This
gives the following steps:

```
      〚(A ∨ B) ∧ ¬ A〛v
    = 〚A ∨ B〛v ∧ 〚¬ A〛v
    = (〚A〛v ∨ 〚B〛v) ∧ ¬ 〚A〛v
    = (v(A) ∨ v(B)) ∧ ¬ v(A)
```

These steps are independent of what the valuation `v` is.

Now we
replace each of the `v(...)`s with the value assigned to that atom
by `v`:

```
      ... continuing the above ...
    = (F ∨ T) ∧ ¬ F
```

Now we use the tables above to compute the value of this
expression. Let's do the "`∨`" first (using
`F ∨ T = T`):

```
    .. continuing ...
    = T ∧ ¬ F
```

then the "`¬`" (using `¬ F = T`):

```
    .. continuing ...
    = T ∧ T
```

Finally, the "`∧`" (using `T ∧ T = T`):

```
    .. continuing ...
    = T
```

By all these steps, we have worked out that:

```
  〚(A ∨ B) ∧ ¬ A〛({A ↦ F; B ↦ T}) = T
```

Of course, it is not always necessary to carry out all these steps explicitly by hand. However, it is important to notice that there is a difference between the symbols of formal logic and their meaning. Using the `〚...〛` brackets moves us from the syntax to the semantics. The special status of syntax will become more important when we look at deductive proof systems for logic.

In the [next section](truth-tables.html), we look at using truth tables to compute the semantics of formulas systematically for all valuations of their atoms.
