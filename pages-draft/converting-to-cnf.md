# Converting to CNF

As we have seen, [SAT Solvers](sat-solvers.html) take their input in *Conjunctive Normal Form* (CNF).

Some problems, like the [Package Installation Problem](packages.html), are naturally expressed in CNF, but others are not. Therefore, it is vital to be able to convert any Propositional Logic formula into one in CNF.

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

   ```formula
      (a ∧ b ∧ c) ∨ ¬ (¬ d ∨ e)
   ```

   ````details
   Answer...

   The steps go like this, with comments between `{` and `}`s:
   ```
       (a ∧ b ∧ c) ∨ ¬ (¬ d ∨ e) \\
     ≡           { because ¬ (P ∨ Q) ≡ ¬ P ∧ ¬ Q }
	   (a ∧ b ∧ c) ∨ (¬ ¬ d ∧ ¬ e)\\
     ≡           { because ¬ ¬ P ≡ P }
	   (a ∧ b ∧ c) ∨ (d ∧ ¬ e)                         (formula in NNF)
     ≡           { multiply out brackets on the left }
	   (a ∨ (d ∧ ¬ e)) ∧ (b ∨ (d ∧ ¬ e)) ∧ (c ∨ (d ∧ ¬ e))
     ≡           {multiple out brackets on the right (twice)
	   (a ∨ d) ∧ (a ∨ ¬ e) ∧ (b ∨ d) ∧ (b ∨ ¬ e) ∧ (c ∨ d) ∧ (c ∨ ¬ e)
	                                                   (formula in CNF)
   ```

   Note how the duplication of formulas that happens in the “multiplying out” steps causes the number of clauses to increase from two in the original formula to six in the final formula.
   ````

2. Also convert the formula to DNF (*Disjunctive Normal Form*).

   ```details
   Answer...

   The NNF version of the formula is already in DNF.
   ```

3. How would you make a linear time SAT solver that works on formulas in DNF?  Why is not in general a feasible approach?

   ````details
   Answer...

   If the formula is in DNF, then for the whole formula to be satisifable, at least one of the clauses must be satisfiable. So the solver could check each clause in turn. In DNF a clause is a conjunction of literals, we need to check that they can all be true simultaneously, which is checking that we don't have `a` and `¬ a` in the same clause. The first DNF clause that is consistent (doesn't have both `a` and `¬ a`) gives the satisfying valuation. This check itakes time linearly proportional to the number of clauses, so is very fast.

   For instance, the DNF formula above:
   ```formula
   (a ∧ b ∧ c) ∨ (d ∧ ¬ e)
   ```
   Has two solutions, one for each clause: `{a ↦ T, b ↦ T, c ↦ T}` and `{d ↦ T, e ↦ F}`.

   Taking formulas in DNF is not a feasible approach to SAT solving in general because generating DNF formulas from arbitrary formulas can involve an exponential increase in the size of the formula in we use the “multiplying out the brackets approach”. So wouldn't, in the worst case, be able to do better than checking all possible `2^n` valuations of the atomic propositions.

   Could there be a more efficient way of converting to DNF, similar to the Tseytin transformation for CNF? If there were, then we could combine it with the linear time SAT solver procedure for DNF described above to get an efficient SAT solver for any formula, including those in CNF. Since solving SAT for CNF is NP-complete, then this would mean that all NP problems would be efficiently solvable, and so P=NP. However no one has been able to prove one way or the other if P=NP, so currently it is unknown whether or not there is an efficient method for converting to DNF.

   We can think of DNF as listing all the possible answers, whereas CNF lists all the things that must be true about the answer without giving it directly. Intuitively, being given the answer is a lot less work that having to find it. But no one has been able to conclusively prove that this is the case!
   ````

## Tseytin Transformation

```youtube
tx3tgpzZPqo
```

### Summary

1. Convert all `P → Q` to `¬ P ∨ Q`.

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

4. To assert that the whole formula must be true, we also add the clause `x₁`.

### Exercises

(to do on paper)

1. Convert this formula to CNF using the Tseytin transformation:

   ```formula
   (a ∧ b) ∨ (c ∧ d)
   ```

   ````details
   Answer...

   In terms of equations, we get:

   ```
   x₁ = x₂ ∨ x₃
   x₂ = a ∧ b
   x₃ = c ∧ d
   ```

   Applying the translations from equations to clauses, we get:

   ```
     (x₂ ∨ x₃ ∨ ¬x₁) ∧ (¬x₂ ∨ x₁) ∧ (¬x₃ ∨ x₁)   { equation 1 }
   ∧ (¬a ∨ ¬b ∨ x₂) ∧ (a ∨ ¬x₂) ∧ (b ∨ ¬x₂)      { equation 2 }
   ∧ (¬c ∨ ¬d ∨ x₃) ∧ (c ∨ ¬x₃) ∧ (d ∨ ¬x₃)      { equation 3 }
   ∧ x₁                                          { to assert that the whole formula is true }
   ```
   ````

2. Explain what the relationship between the values of `x`, `y` and `z` are when we have a valuation that makes all the clauses for the Tseytin translation of `∧` satisfied. Similarly for `∨` and `¬`.

   ````details
   Answer...

   If we have a valuation `v` that makes
   ```
   (¬ y ∨ ¬ z ∨ x) ∧ (y ∨ ¬ x) ∧ (z ∨ ¬ x)
   ```
   satisfied, then it is the case that `〚y ∧ z〛v = 〚x〛v`. In other words, the clauses are satisified whenever the value of `x` is equal to the value of `y ∧ z`. The reverse is also true: if we have a `v` such that `〚y ∧ z〛v = 〚x〛v`, then the clauses above are satisfied.

   Similarly, the clauses for `∨` are satisfied exactly when the value of `x` is equal to the value of `y ∨ z`, and the clauses for `¬` are satisified exactly when `x = ¬ y`.
   ````

3. What is the relationship between the Tseytin transformed formula
   and the original in terms of satisfiability?

   ````details
   Answer...

   If we convert a formula `P` to a collection of clauses `C₁, ..., Cₖ`, with `x₁` as the name of the top-level part of `P`, then the formula
   ```
	 C₁ ∧ ... ∧ Cₖ
   ```
   is satisfied by a valuation `v` exactly when `〚P〛v = 〚x₁〛v`.

   Therefore, if the formula
   ```
   C₁ ∧ ... ∧ Cₖ ∧ x₁
   ```
   is satisfied by a valuation `v`, then `〚P〛v = ⊤`.

   In the other direction, if we have a valuation `v` such that `〚P〛v = ⊤`, then *there exists* a valuation `v₂` such that `〚 C₁ ∧ ... ∧ Cₖ ∧ x₁〛v₂ = ⊤`. The valuation `v₂` extends `v` by adding the truth values for the extra atoms generated during the Tseytin translation.

   Because the original formula `P` and its Tseytin translation are not satisfied by exactly the same valuations, they are not *equivalent*. But because we can translate satisfying valuations in both directions, we can say that they are *equi-satisfiable*.
   ````

4. Let's say that we have an equation like `x = x₁ ∧ x₂ ∧ ... ∧ xₖ`. How could we convert this to fewer clauses than the approach described above?  Similarly for `x = x₁ ∨ ... ∨ xₖ`?

   ````details
   Answer...

   For the equation `x = x₁ ∧ x₂ ∧ ... ∧ xₖ`, we could write:
   ```
   (¬ x₁ ∨ ¬ x₂ ∨ ... ¬ xₖ ∨ x) ∧ (x₁ ∨ ¬ x) ∧ ... ∧ (xₖ ∨ ¬ x)
   ```
   Why? We can compute this in the same way as we did in the videos for the binary equations.

   The equation `x = x₁ ∧ x₂ ∧ ... ∧ xₖ` can be written as an AND of two implications:
   ```
   ((x₁ ∧ x₂ ∧ ... ∧ xₖ) → x) ∧ (x → (x₁ ∧ x₂ ∧ ... ∧ xₖ))
   ```
   We use the equivalence `P → Q ≡ ¬P ∨ Q` to get:
   ```
   (¬(x₁ ∧ x₂ ∧ ... ∧ xₖ) ∨ x) ∧ (¬x ∨ (x₁ ∧ x₂ ∧ ... ∧ xₖ))
   ```
   In the first half, we use the de Morgan law to push the `¬` down through the `∧`s to get:
   ```
   (¬x₁ ∨ ¬x₂ ∨ ... ∨ ¬xₖ ∨ x) ∧ (¬x ∨ (x₁ ∧ x₂ ∧ ... ∧ xₖ))
   ```
   In the second half, we have to “multiply out the brackets” to get:
   ```
   (¬x₁ ∨ ¬x₂ ∨ ... ∨ ¬xₖ ∨ x) ∧ (¬x ∨ x₁) ∧ (¬x ∨ x₂) ∧ ... ∧ (¬x ∨ xₖ)
   ```
   as above.

   Note that this gives us `1+k` clauses. If we did the conversion naively using just binary equations as above, we would end up with many more clauses.

   By similar reasoning, we get the following clauses for `x = x₁ ∨ ... xₖ`:
   ```
   (x₁ ∨ ... ∨ xₖ ∨ ¬ x) ∧ (¬ x₁ ∨ x) ∧ ... ∧ (¬ xₖ ∨ x)
   ```

   In fact, we can take any equation `x = E` and convert it directly to clauses and then use that in the Tseytin conversion. In some cases, this will be more efficient than doing each connective individually.
   ````
