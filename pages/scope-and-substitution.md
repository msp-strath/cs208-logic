[Contents](contents.html)

# Scope and Substitution

To use Natural Deduction for [Predicate Logic](pred-logic-intro.html) we need to upgrade our ideas of judgement to track which variables are in scope during a proof. We also need to be able to correctly substitute terms into formulas with free variables.

[Slides for the videos (PDF)](week07-slides.pdf)

## Managing which variables are in scope

The key difference between Propositional Logic and Predicate Logic is that the latter allows us to name individuals `x`, `y` and so on. To upgrade Natural Deduction to handle Predicate Logic, we need to make sure that we keep track of the names that we are using in our proofs, making sure that our terms and formulas are well-scoped. This is the subject of Video 7.1 this week.

### Video

```
FIXME: CS208-W7P1.mp4
```

### Exercises

FIXME: scope exercises: true/false questions

## Substitution

Next, we will look at the important concept of subsitution. Substitution is how we go from a general statement like "for all x, if x is human, then x is mortal" to a specific statement "if socrates is human, then socrates is mortal".

Substitution is not much more than simply “plugging in values”, like you may be used to in formulas in mathematics, but gets a little more subtle when we have formulas that bind variables in them, as we see in this video:

### Video

```
FIXME: CS208-W7P2.mp4
```

### Exercises

FIXME: substitution exercises
