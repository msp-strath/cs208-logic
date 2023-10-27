# Scope and Substitution

To use Natural Deduction for [Predicate Logic](pred-logic-intro.html) we need to upgrade our ideas of judgement to track which variables are in scope during a proof. We also need to be able to correctly substitute terms into formulas with free variables.

[Slides for the videos (PDF)](week07-slides.pdf)

## Managing which variables are in scope

The key difference between Propositional Logic and Predicate Logic is that the latter allows us to name individuals `x`, `y` and so on. To upgrade Natural Deduction to handle Predicate Logic, we need to make sure that we keep track of the names that we are using in our proofs, making sure that our terms and formulas are well-scoped.

Well-scopedness of terms and formulas means that all the *variables* mentioned in a term or formula are already declared to the left of them in a judgement. This is explained in the following video:

```youtube
uB5NtHCbuJc
```

```textbox {id=scope-subst-note1}
Enter any notes to yourself here.
```

### Exercises

Are these judgements well scoped?

1. ```
   P(a()) |- Q
   ```

   ```selection {id=scope-ex1}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Well Scoped**. The a() names an individual from the vocabulary, and is not a variable.
   ```

2. ```
   Q(z,s(z())) |- P
   ```

   ```selection {id=scope-ex2}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Not Well Scoped**. The variable “z” has not been declared to the left of where it is used.
   ```

3. ```
   x, y, P(x,y), Q(x) |- R
   ```

   ```selection {id=scope-ex3}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Well Scoped**. The variables “x” and “y” have both been declared to the left of where they are used, and there are no other variables.
   ```

4. ```
   x, y, P(x,y), Q(x), R(z) |- S
   ```

   ```selection {id=scope-ex4}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Not Well Scoped**. The variables “x” and “y” have been properly declared, but “z” has not.
   ```

5. ```
   x, y, P(x,y), ∀z. Q(z), R(z) |- S
   ```

   ```selection {id=scope-ex5}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Not Well Scoped**. The “z” in “∀z. Q(z)” is bound by the quantifier, but the “z” in “R(z)” has not been declared.
   ```

6. ```
   x, y, P(x,y), Q(x), ∀z. R(z) |- S
   ```

   ```selection {id=scope-ex6}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Well Scoped**. The “z” in “∀z. R(z)” is bound by the quantifier. The “x” and the “y” have been declared before (i.e., to the left of) use.
   ```

7. ```
   x, P(x,y), y, Q(x) | -R
   ```

   ```selection {id=scope-ex7}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Not Well Scoped**. The “y” in “P(x,y)” is not in scope.
   ```

8. ```
   |- P(x)
   ```

   ```selection {id=scope-ex8}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Not Well Scoped**. The variable “x” has not been declared.
   ```

9. ```
   |- ∀x. P(x)
   ```

   ```selection {id=scope-ex9}
   (config (options ("Well Scoped" "Not Well Scoped")))
   ```

   ```details
   Answer...

   **Well Scoped**. The quantifier “∀x.” binds the use of “x” in “P(x)”.
   ```

10. ```
	x, y |- P(x)
	```

	```selection {id=scope-ex10}
	(config (options ("Well Scoped" "Not Well Scoped")))
	```

	```details
	Answer...

	**Well Scoped**. The variable “x” is used in the conclusion, and has been declared in the context.
	```

11. ```
	x [Q(y)] |- ∀y. P(y)
	```

	```selection {id=scope-ex11}
	(config (options ("Well Scoped" "Not Well Scoped")))
	```

	```details
	Answer...

	**Not Well Scoped**. The formula in focus “Q(y)” uses the variable “y” which has not been declared.
	```


12. ```
	x, P(y) [Q(y)] |- ∀y. P(y)
	```

	```selection {id=scope-ex12}
	(config (options ("Well Scoped" "Not Well Scoped")))
	```

	```details
	Answer...

	**Not Well Scoped**. The assumption “P(y)” uses the variable “y” which has not been declared.
	```

13. ```
	x, y, P(y) [Q(y)] |- ∀y. P(y)
	```

	```selection {id=scope-ex13}
	(config (options ("Well Scoped" "Not Well Scoped")))
	```

	```details
	Answer...

	**Well Scoped**. The assumption “P(y)” uses the variable “y” which has not been declared.
	```

## Substitution

Next is the important concept of subsitution. Substitution is how we go from a general statement like “for all x, if x is human, then x is mortal” to a specific statement "if socrates is human, then socrates is mortal": we *substitute* the specific individual “socrates” for the general variable “x”.

Substitution is not much more than simply “plugging in values”, like you may be used to in formulas in mathematics, but gets a little more subtle when we have formulas that bind variables in them, as we see in this video:

```youtube
Ehan-g6-EVQ
```

```textbox {id=scope-subst-note2}
Enter any notes to yourself here.
```

### Exercises

Compute the results of the following substitutions, being careful with renaming to avoid variable capture.

1.
   ```
   (∀x. P(x) -> Q(x,y))[x := f(x)]
   ```

   ```formulaentry {id=subst-ex1}
   Enter your formula here
   ```

2.
   ```
   (∀x. P(x) -> Q(x,y))[y := f(x)]
   ```

   ```formulaentry {id=subst-ex2}
   Enter your formula here
   ```

3.
   ```
   (P(x) -> (∃x. q(x,y)))[x := g(y)]
   ```

   ```formulaentry {id=subst-ex3}
   Enter your formula here
   ```

4.
   ```
   (p(x) -> (∃y. q(x,y)))[x := g(y)]
   ```

   ```formulaentry {id=subst-ex4}
   Enter your formula here
   ```
