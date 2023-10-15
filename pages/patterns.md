[Contents](contents.html)

# Logical Modelling Patterns

In the [Wizard's Pets](wizards-pets.html) example, we saw several ways of encoding certain kinds of constraints. Here is a list of some common patterns that come up over and over again.

## At least one

We often want *at least one* thing to be true (e.g., we must take at least one pet from the Wizard). We can encode this constraint by using a logical OR, written in the logical modelling tool with a vertical bar `|`:

```lmt {id=patterns-at-least-one-a}
atom a
atom b
allsat (a | b) { "a": a, "b": b }
```

Clicking **Run** should give three solutions, excluding the case when both `a` and `b` are `false`.

This pattern extends to any number of atoms, if we want at least one of `a`, `b`, or `c` to be true, then we OR them all together:

```lmt {id=patterns-at-least-one-b}
atom a
atom b
atom c
allsat (a | b | c) { "a" : a, "b": b, "c": c }
```

There should be seven solutions.

## Not both of these / at most one

Sometimes we want at most one of two atoms to be true, to express some kind of mutual exclusion. We encode this by saying that at least one them is not `true`:

```lmt {id=patterns-not-both}
atom a
atom b
allsat (~a | ~b) { "a": a, "b": b }
```

Unlike the previous pattern, we can't specify at most one is true of more than three atoms just by combining them with ORs. Try it with the following example:

```lmt {id=patterns-not-both-wrong}
atom a
atom b
atom c
allsat (~a | ~b | ~c)
  { "a" : a, "b": b, "c": c }
```

Instead, we must list each possible pair and say that in each pair at most one can be true:

```lmt {id=patterns-at-most-one-of-three}
atom a
atom b
atom c
allsat ((~a | ~b) & (~a | ~c) & (~b | ~c))
  { "a" : a, "b": b, "c": c }
```

## If this then that

Often, we want `b` to be true if `a` is, to express some form of dependency of `a` on `b`. We do this using the constraint that either `a` is not true (so the dependency is not required), or `b` is true (so the dependency is fulfilled).

Try the following to check that whenever `a` is true, then so is `b`:

```lmt {id=if-this-then-that}
atom a
atom b
allsat (~a | b) { "a": a, "b": b }
```



---

[Contents](contents.html)
