[Contents](contents.html)

# Converting to CNF

As we have seen, [SAT Solvers](sat-solvers.html) take their input in *Conjunctive Normal Form* (CNF).

Some problems, like the [Package Installation Problem](packages.md), are naturally expressed in CNF, but others are not. Therefore, it is vital to be able to convert any Propositional Logic formula into one in CNF.

We look at two techniques.

The first is "multiplying out", which uses equivalences between formulas to rewrite any formula to an equivalent one in CNF. This technique is simple, but can often generate formulas that are exponentially larger than the original.

The second technique is known as the "Tseytin" transformation. This works by translating a formula into a collection of equations that are then translated into clauses. The Tseytin transformation does not suffer the exponential blowup problem of the naive technique.

[The Slides used in the two videos below](week03-slides.pdf).

## Multiplying Out

```youtube
GZMQSBfWd1c
```

### Summary

The "slow" way of converting to CNF consists of the following steps:

1. Convert all `P → Q` to `¬ P ∨ Q`

2. Convert to *Negation Normal Form* (NNF) by pushing all the negations down to the atomic propositions using the following equivalences:

   ```
      P         ≡ ¬ ¬ P
      ¬ (P ∧ Q) ≡ ¬ P ∨ ¬ Q
      ¬ (P ∨ Q) ≡ ¬ P ∧ ¬ Q
   ```

   The second and third equivalences are usually called the *De Morgan* laws, after the 19th Century logician [Augustus De Morgan](https://en.wikipedia.org/wiki/De_Morgan\%27s_laws).

3. The formula now consists of only `∧`s and `∨`s of (possibly negated) atomic propositions. We now rewrite to CNF by "pushing" `∨`s into `∧`s, using the equivalence:

   ```
     P ∨ (Q ∧ R) ≡ (P ∨ Q) ∧ (P ∨ R)
   ```

   You can think of this as analogous to "multiplying out the brackets" in normal algebra: `x(y+z) = xy + xz`.

### Exercises

(to do on paper)

1. Convert the following formula to CNF by first converting to NNF
   and then to CNF.

   ```
      (a ∧ b ∧ c) ∨ ¬ (¬ d ∨ e)
   ```

2. Also convert the formula to DNF (*Disjunctive Normal Form*).

3. How would you make a linear time SAT solver that works on formulas in DNF?  Why is not in general a feasible approach?

## Tseytin Transformation

```youtube
tx3tgpzZPqo
```

### Summary

1. Convert all `P \to Q` to `¬ P ∨ Q`.

2. Convert the formula into equations. This means that we take all the non-atomic subformulas of the original formula, name them all `x₁, x₂, ` etc. and then use the top level connective of the subformula and the names of the sub-subformulas to make each equation. Here is an example, for the formula `a ∨ ¬ (¬ b ∨ c)`, we have the following equations, where `x₁` is the name given to the whole formula:

   ```
   x₁ = a ∨ x₂
   x₂ = ¬ x₃
   x₃ = x₄ ∨ c
   x₄ = ¬ b
   ```

   If we repeatedly use these equations, starting with `x₁`, we can see that they build up the original formula:

   ```
   x₁ = a ∨ x₂ = a ∨ ¬ x₃ = a ∨ ¬ (x₄ ∨ c) = a ∨ ¬ (¬ b ∨ c)
   ```

3. Take each equation `x = y □ z` or `x = □ y` and turn it into clauses:

   1. If `x = y ∧ z`, add the clauses

      ```
      (¬ y ∨ ¬ z ∨ x) ∧ (y ∨ ¬ x) ∧ (z ∨ ¬ x)
      ```

   2. If `x = y ∨ z`, add the clauses

      ```
      (y ∨ z ∨ ¬ x) ∧ (¬ y ∨ x) ∧ (¬ z ∨ x)
      ```

   3. If `x = ¬ y`, add the clauses

      ```
      (¬ y ∨ ¬ x) ∧ (y ∨ x)
      ```

   For the equations for the example formula above, we get the following clauses:

   | Clauses                                      | Where from?           |
   |----------------------------------------------|-----------------------|
   | `(a ∨ x₂ ∨ ¬ x₁) ∧ (¬ a ∨ x₁) ∧ (¬ x₂ ∨ x₁)` | (*for* `x₁ = a ∨ x₂`) |
   | `(¬ x₃ ∨ ¬ x₂) ∧ (x₃ ∨ x₂)`                  | (*for* `x₂ = ¬ x₃`)   |
   | `(x₄ ∨ c ∨ ¬ x₃) ∧ (¬ x₄ ∨ x₃) ∧ (¬ c ∨ x₃)` | (*for* `x₃ = x₄ ∨ c`) |
   | `(¬ b ∨ ¬ x₄) ∧ (b ∨ x₄)`                    | (*for* `x₄ = ¬ b`)    |

### Exercises

(to do on paper)

1. Convert this formula to CNF using the Tseytin transformation:

   ```
   (a ∧ b) ∨ (c ∧ d)
   ```

2. Explain what the relationship between the values of `x`, `y` and `z` are when we have a valuation that makes all the clauses for the Tseytin translation of `∧` satisfied. Similarly for `∨` and `¬`.

3. What is the relationship between the Tseytin transformed formula
   and the original in terms of satisfiability?

4. Let's say that we have an equation like `x = x₁ ∧ x₂ ∧ ... ∧ xₖ`. How could we convert this to fewer clauses than the approach described above?  Similarly for `x = x₁ ∨ ... ∨ xₖ`.

---

[Contents](contents.html)
