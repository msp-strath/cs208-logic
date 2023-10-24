# Arithmetic and Induction

Now we can talk about [equality](equality.html) in our proof system, we can start to talk about useful things like numbers and arithmetic, and make statements like the fact that addition is commutative (i.e., it doesn't matter which way round we add things):

```formula
∀ x. ∀ y. add(x,y) = add(y,x)
```

However, we cannot yet prove statements like this. To be able to prove such statements, we use a collection of axioms set out by [Giuseppe Peano](FIXME) in the 19th century.

## Video

```
FIXME: CS208-W9P2.mp4
```

## Representing numbers

### Exercises

## Axioms of Addition

### Exercises

## Axioms of Multiplication

### Exercises

## Induction

One of these axioms is the principle of induction, which states that to prove a property `P(x)` for all numbers `x`, we have to prove `P(0)` (the base case), and to prove `P(n+1)` assuming `P(n)` (the step case).

### Proofs by Induction in the Proof Tool

### Exercises on Induction
