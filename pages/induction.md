# Induction and Arithmetic

Now we can talk about [equality](equality.html) in our proof system, we can start to talk about useful things like numbers and arithmetic, and make statements like the fact that addition is commutative (i.e., it doesn't matter which way round we add things):

```formula
∀ x. ∀ y. add(x,y) = add(y,x)
```

However, we cannot yet prove statements like thisTo be able to prove such statements, we use a collection of axioms set out by [Giuseppe Peano](FIXME) in the 19th century.

One of these axioms is the principle of induction, which states that to prove a property `P(x)` for all numbers `x`, we have to prove `P(0)` (the base case), and to prove `P(n+1)` assuming `P(n)` (the step case).

In Video 9.2 we take a look at Peano's axioms and see how to add the Principle of Induction to our proof system. Video 9.4 demonstrates proof by induction in the interactive prover.

## Videos

## Exercises
