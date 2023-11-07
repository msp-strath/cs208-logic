# Propositional Logic Syntax

In this course, we will study Symbolic Logic, where we are primarily concerned with statements written out using formal symbols, rather than statements in natural language. In this page, we will introduce the syntax of the logical formulas that we will look at in the first half of the course.

## Video

```youtube
s_JkAMdFT8c
```

```textbox {id=prop-logic-syntax-note}
Enter any notes to yourself here.
```

[Slides (PDF)](week01-slides.pdf)

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

Graphically, we can think of formulas as trees built from atoms:

```pikchr
arrow down
box "A" fit
```

And formulas:
```pikchr
[
  arrow down
  circle "∧" fit
  arrow down left 0.5cm from previous circle.sw
  arrow down right 0.5cm from previous circle.se
]
move right
[
  arrow down
  circle "∨" fit
  arrow down left 0.5cm from previous circle.sw
  arrow down right 0.5cm from previous circle.se
]
move right
[
  arrow down
  circle "→" fit
  arrow down left 0.5cm from previous circle.sw
  arrow down right 0.5cm from previous circle.se
]
move right
[
  arrow down
  circle "¬" fit
  arrow down left 0cm from previous circle.s
]
```

For example, the tree:

```pikchr
X1: circle "∧" fit
move down left 0.5cm from X1.sw
X2: circle "∨" fit
move down left 0.5cm from X2.sw
A1: box "A" fit
move down right 0.5cm from X2.se
A2: box "B" fit
move down right 0.5cm from X1.se
X3: circle "¬" fit
move down until even with A1.c from X3.s
A3: box with .c at previous.end "A" fit
arrow from X1.sw to X2.n
arrow from X1.se to X3.n
arrow from X2.sw to A1.n
arrow from X2.se to A2.n
arrow from X3.s to A3.n
```
represents the formula:
```formula
(A \/ B) /\ ¬A
```

I will not draw out the tree based representation for each formula explicitly in this course, but it is important to keep in mind that this is what formulas “really are”. The concept of which connective occurs “topmost” in the tree will be important when it comes to working out the [truth values assigned to formulas](prop-logic-semantics.html), [using truth tables](truth-tables.html), and [doing formal proof](natural-deduction-intro.html).


## Linear Representation

Writing formulas as trees is precise, but consumes a lot of space. For conciseness, we write out formulas “linearly” as a sequence of symbols with parentheses, so it looks more like a familiar algebraic notation except with `∧`, `∨` and `¬` instead of `×`, `+` and `-`.

The problem with the linear style is that it can be ambiguous if we do not put the parentheses in the right places. For example, what tree does the following represent?
```
A ∨ B ∧ ¬ A
```
Depending on how we group the connectives, we could have either:
1. This tree:
   ```pikchr
   box "FIXME"
   ```
2. Or this tree:
   ```pikchr
   box "FIXME2"
   ```

We could always put in parentheses around every connective to disambiguate which one we mean.  The first tree can be written `((A ∨ B) ∧ (¬ A))` and the second can be written `(A ∨ (B ∧ (¬ A)))`. However, writing lots of parentheses is messy, and you spend a lot of time counting to make sure you've got enough.

One way to handle ambiguity is to say that “`∧` binds tighter than `∨`”, meaning that we group everything around `∧`s before grouping around `∨`s. Under this rule, the right hand tree is the one meant. This rule is similar to the way that `A + B×C` means `A + (B × C)` in normal algebra, because `×` binds tighter than `+`. You may be familiar with the BODMAS rules: Brackets, Order, Division, Multiplication, Addition, Subtraction, describing the order in which groupings happen. Similar rules are possible for logical formulas.

However, in this course, I will be stricter about where parentheses can and cannot appear. All mixing of connectives is disallowed, and must be disambiguated with parentheses. I will adopt the following conventions:

1. Runs of `∧`, `∨`, `→` group to the right. For example:

   - `P₁ ∧ P₂ ∧ P₃ ∧ P₄` is the same as `P₁ ∧ (P₂ ∧ (P₃ ∧ P₄`

   - `P₁ → P₂ → P₃ → P₄`  is the same as `P₁ → (P₂ → (P₃ → P₄))`

2.  Whenever we have two different binary connectives next to each other, we require parentheses:

	| Example          | ok?                     |
	|------------------|-------------------------|
	| `(P₁ ∨ P₂) ∧ P₃` | good                    |
	| `P₁ ∨ P₂ ∧ P₃`   | bad                     |
	| `P₁ ∧ P₂ → P₃`   | bad (mixes `∧` and `→`) |
	| `(P₁ ∧ P₂) → P₃` | good                    |
	| `P₁ ∧ (P₂ → P₃)` | good                    |

3.  If we have a binary connective inside an `¬`, we require parentheses. So
    ```formula
	¬P ∧ Q
	```
	is not the same as
	```formula
	¬ (P ∧ Q)
	```

3. We don't put parentheses around a `¬`:

   | Example       | ok?  |
   |---------------|------|
   | `¬ (P ∧ Q)`   | good |
   | `(¬ (P ∧ Q))` | bad  |
