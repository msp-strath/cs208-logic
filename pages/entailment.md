# Entailment

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

The definition of entailment can be subtle and difficult to understand at first without working through a few examples, so I have written these up below.

## Video

The following video introduces the idea of entailment by examples.

```youtube
70hVzDSQn08
```

[Slides (PDF)](week01-slides.pdf)

## Example Entailments

For Propositional Logic, it is possible to compute entailments by using truth tables. Let's see how to do this by some examples. These examples will also introduce some of the interesting consequences of the definition of entailment.

### “A” entails “A”

Our first example is the entailment `A \models A`. Inituitively, this entailment ought to hold: if we assume `A`, then we should be able to conclude `A`. Let us check this by writing a truth table. We first write out all the possible values of `A`. These are all our different valuations, so we explicitly mark these columns as our valuation:

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

Checking this table, we can see that the entailment holds. In the first row, the assumption is false, so we are OK. In the second row, the assumption is true, but so is the conclusion, so we are OK. After checking every row, we can conclude that `A \models A`.

### “A and B” entails “A”

The entailment `A \land B \models A` is a little more complex because there are two propositional atoms `A` and `B`. I will write out the table all in one go:

| A (valuation) | B (valuation) | A \land B (assumption) | A (conclusion) |
|---------------|---------------|------------------------|----------------|
| F             | F             | F                      | F              |
| T             | F             | F                      | T              |
| F             | T             | F                      | F              |
| T             | T             | T                      | T              |

Again, we check each valuation (row) to see whether whenever all the
assumptions are true, the conclusion is true. For this table:

- In rows 1 and 3: the assumption `A \land B` is false, so it does not matter that the conclusion is false.
- In row 2: the assumption is false and the conclusion is true. Since the assumption is false, we do not actually care what the conclusion is.
- In row 4: the assumption is true, so we need to check the conclusion. The conclusion is also true, so this row is good.

Together, for each row, we have that if the assumption is true, then the conclusion is true. Therefore, the entailment `A \land B \models A` is valid.

### “A or B” does not entail “A”

TBD

| A (valuation) | B (valuation) | A \lor B (assumption) | A (conclusion) |
|---------------|---------------|-----------------------|----------------|
| F             | F             | F                     | F              |
| F             | T             | T                     | F              |
| T             | F             | T                     | T              |
| T             | T             | T                     | T              |

### Implication internalises entailment

TBD

| A (valuation) | B (valuation) | A \to B (assumption) | A (assumption) | B (conclusion) |
|---------------|---------------|----------------------|----------------|----------------|
| F             | F             |                      |                |                |
| F             | T             |                      |                |                |
| T             | F             |                      |                |                |
| T             | T             |                      |                |                |

### Entailment with no assumptions

TBD

### Contradictory assumptions

TBD

| A (valuation) | B (valuation) | A (assumption) | ¬A (assumption) | B (conclusion) |
|---------------|---------------|----------------|-----------------|----------------|
|               |               |                |                 |                |

## Facts about entailment

### Substitution

TBD

### Order does not matter

TBD

### Comma means “And”

TBD

### Adding assumptions does not matter

TBD

### Contradictory assumptions entail everything

TBD

## The Deduction Theorem

TBD

## Relationship between Satisfiability, Validity and Entailment

TBD
