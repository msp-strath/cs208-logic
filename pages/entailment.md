# Entailment

One of the uses of logic (and possibly the most important one) is to identify when conclusions do and do not follow from some assumptions. If a conclusion `Q` follows from some assumptions `P₁, P₂...` (in a rigorous way we define below), we will say that the assumptions `P₁, P₂...` *entails* `Q`. I will also write this in symbols:

```
  P₁, P₂ ... ⊧ Q
```

The assumptions `P₁, P₂...` may be finitely or infinitely many, though we will usually only be interested in finite numbers of assumptions.

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

For Propositional Logic, it is possible to compute entailments by using truth tables. Let's see how to do this by some examples. These examples will also introduce some of the interesting consequences of our definition of entailment.

### A entails A

TBD

### A and B entails A

TBD

### Modus Ponens

TBD

### A non-entailment: A or B does not entail A

TBD

### Entailment with no assumptions

TBD

### Contradictory assumptions

TBD

## Facts about entailment

TBD

## The Deduction Theorem

TBD

## Relationship between Satisfiability, Validity and Entailment

TBD
