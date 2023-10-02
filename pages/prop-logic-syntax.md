[Contents](contents.html)

# Propositional Logic Syntax

In this course, we will study Symbolic Logic, where we are primarily concerned with statements written out using formal symbols, rather than statements in natural language. In this page, we will introduce the syntax of the logical formulas that we will look at in the first half of the course.

## Video

```youtube
s_JkAMdFT8c
```

## Examples

Here is an example of a formula of Propositional Logic:

```formula
A \/ B \/ ¬ C
```

We read this as "`A` or `B` or not `C`". A more complex example is:

```formula
(A \/ B) -> B
```

We read this as "`A` or `B` implies `B`", or "if `A` or `B`, then `B`". A yet more complex example is:

```formula
(A \/ B) -> (A -> C) -> (B -> D) -> (C /\ D)
```

We read this as "if `A` or `B`, then if `A` implies `C`, then if `B` implies `D`, then `C` and `D`". As you can see writing out the formulas in English becomes very cumbersome and possibly ambiguous. For these two reasons, we use a formal syntax.

## Building Formulas

Logical formulas are built up from *atomic propositions* (or
*atoms*) and *connectives*. In more detail, a propositional
logic formula is either:

1. an *atomic proposition* `A`, `B`, `C`, ...; or
2. built from a *connective*; if `P` and `Q` are formulas, then the
   following are formulas:
   1. `P ∧ Q` - meaning "`P` and `Q`", also called "conjunction";
   2. `P ∨ Q` - meaning "`P` or `Q`", also called "disjunction";
   3. `¬ P` - meaning "not `P`";
   4. `P → Q` - meaning "`P` implies `Q`".

More concisely, formulas `P`, `Q`, etc. are constructed from the following grammar:

```
  P, Q ::= A | P ∧ Q | P ∨ Q | ¬ P | P → Q
```

where `A` stands for any atomic proposition `A`, `B`, `C` ... .

## Tree Representation

TBD

## Linear Representation

TBD

---

[Contents](contents.html)
