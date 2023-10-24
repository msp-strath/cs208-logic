# Circuits, Gates and Formulas

In [Converting to CNF](converting-to-cnf.html), we saw that logical connectives can be translated into clauses by treating them as equations.

Let's now look at how to do this in the Logical Modelling Tool. We'll use a domain to write down all the variables involved, and a parameterised atom `active(n : var)` which is true if that variable is true, and false otherwise.

## Encoding NOT

We can encode `Out = ¬ In` as clauses like so, using the translation given in [Conversion to CNF](converting-to-cnf.html):

```lmt {id=circuits-not}
domain var { In, Out }

atom active(n : var)

define not(out : var, in : var) {
    (~active(out) | ~active(in))
  & ( active(in) | active(out))
}

allsat(not(Out, In))
  { for(n : var) n : active(n) }
```

Clicking **Run** should give exactly the truth table for NOT.

## Encoding AND

Similarly, we can encode AND as clauses, using the translation given in [Conversion to CNF](converting-to-cnf.html):

```lmt {id=circuits-and}
domain var { In1, In2, Out }

atom active(n : var)

define and(out : var, in1 : var, in2 : var) {
  (~active(out) | active(in1)) &
  (~active(out) | active(in2)) &
  ( active(out) | ~active(in1) | ~active(in2))
}

allsat(and(Out, In1, In2))
  { for(n : var) n : active(n) }
```

Clicking **Run** should give exactly the truth table for AND.

## Encoding OR

And we can encode OR as clauses:

```lmt {id=circuits-or}
domain var { In1, In2, Out }

atom active(n : var)

define or(out : var, in1 : var, in2 : var) {
    (~active(out) | active(in1) | active(in2))
  & ( active(out) | ~active(in1))
  & ( active(out) | ~active(in2))
}

allsat(or(Out, In1, In2))
  { for(n : var) n : active(n) }
```

Clicking **Run** should give exactly the truth table for OR.

## Encoding a Formula

Let's say we want to encode the formula `Out = (¬In1 \/ In2) /\ (¬In2 \/ In1)`, and to find out all the values of `In1` and `In2` that make `Out` true.

To encode the formula as clauses, we break it down into individual components like so:

1. `Out = X1 /\ X2`
2. `X1 = X3 \/ In2`
3. `X3 = ¬In1`
4. `X2 = X4 \/ In1`
5. `X4 = ¬In2`

Now we can encode this formula using variables `In1`, `In2`, `Out`, `X1`, `X2`, `X3`, `X4` and the logic gates defined above. We also assert that `active(Out)` is true to tell the solver that we want to find solutions when `Out` is true. Finally, we print out all solutions, but only to `In1` and `In2`.

```lmt {id=circuits-example}
domain var { In1, In2, Out, X1, X2, X3, X4 }

atom active(n : var)

define not(out : var, in : var) {
    (~active(out) | ~active(in))
  & (active(in) | active(out))
}

define or(out : var, in1 : var, in2 : var) {
    (~active(out) | active(in1) | active(in2))
  & ( active(out) | ~active(in1))
  & ( active(out) | ~active(in2))
}

define and(out : var, in1 : var, in2 : var) {
  (~active(out) | active(in1)) &
  (~active(out) | active(in2)) &
  ( active(out) | ~active(in1) | ~active(in2))
}

define formula {
  and(Out, X1, X2) &
  or(X1, X3, In2) &
  not(X3, In1) &
  or(X2, X4, In1) &
  not(X4, In2)
}

allsat (formula & active(Out))
  { "In1": active(In1), "In2": active(In2) }
```

The results should say that `Out` is true exactly when `In1` is equal to `In2`.
