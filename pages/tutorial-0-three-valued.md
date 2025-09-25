# Tutorial 0: Three-valued Logic

```aside
This page assumes that you have read and understood the pages on the [syntax](prop-logic-syntax.html) and [semantics](prop-logic-semantics.html) of Propositional Logic, and understood [truth tables](truth-tables.html).
```

Propositional Logic, as we introduced it in [the page on semantics](prop-logic-semantics.html), is *two valued* with the values `True` and `False`. But why should we restrict to only two values? Why should the connectives be defined the way they are?

One way to explore alternative logics is to think about having different truth values instead of just `True` and `False`. By doing this we can learn more about how the two-valued logic works and what principles are universally valid and which aren't.

For this page, we are going to keep the same [syntax](prop-logic-syntax.html) as Propositional Logic, and think about how to extend the semantic of it to alternative sets of truth values.

## One truth value?

Could we have only one truth value? `True` for instance? (It doesn't matter what we call it.)

Having only one truth value leads to a logic that isn't very useful. Every formula gets the same (unique) truth value, so every formula is valid and every formula is satisfiable. Every formula has the same meaning, and so the logic becomes useless as a way of telling the difference between statements expressed as logical formulas.

## Three truth values

Having three truth values leads to a more interesting situation.

Three-valued logic is used in the databse query language SQL, where logical values can be `TRUE`, `FALSE`, or `NULL`. The value `NULL` is used in databases to indicate missing or unknown information. Unlike `null` in Java, it is not necessarily an error to use it.

Three-valued logic is sometimes called “Kleene's 3-valued logic”, after the American logician Stephen Kleene, or “Łukasiewicz logic”, after the Polish logician Jan Łukasiewicz. The Kleene and Łukasiewicz logics differ in how they handle implication, as we will see below.

Let's write the three truth values as:

| Value | Meaning                      |
|-------|------------------------------|
| T     | “true”                       |
| I     | “indeterminate” or “unknown” |
| F     | “false”                      |

### Meanings of the Connectives

We now have to extend the meanings of the connectives to the cases when one or both of the inputs are `I`. Let's try doing this for `∧` by using our intuition about what the connectives mean.

#### And, Or, and Not

It makes sense for the connectives to behave the same on `T` and `F`, so we can fill in part of a table for `∧`:

| P ∧ Q | F | I | T |
|-------|---|---|---|
| F     | F |   | F |
| I     |   |   |   |
| T     | F |   | T |

What goes in the blank spaces? If the `I` truth value means “unknown”, then we can use this intuition to fill in the other spaces. It is also helpful to remember that `∧` is commutative (`x ∧ y = y ∧ x`) so the table must be symmetric across the top-left to bottom-right diagonal.

For `∧`, it is true only when both sides are true. So if one is *definitely* `F` the answer must be `F`. We can use this fact to fill in a bit more of the table:

| P ∧ Q | F | I | T |
|-------|---|---|---|
| F     | F | F | F |
| I     | F |   |   |
| T     | F |   | T |

It also makes sense that `I ∧ I = I`, so we can fill in the middle square. Finally, we need a value for `T ∧ I`. Because `I` is *unknown*, we don't know if it is safe to say that this is definitely `T` or `F`, so we have to go with `I`. We can also think that it is always the case in two-valued logic that `T ∧ x = x ∧ T = x` for any `x`.

This completes the table:

| P ∧ Q | F | I | T |
|-------|---|---|---|
| F     | F | F | F |
| I     | F | I | I |
| T     | F | I | T |

We can go through a similar process to work out a table for `∨`:

| P ∨ Q | F | I | T |
|-------|---|---|---|
| F     | F | I | T |
| I     | I | I | T |
| T     | T | T | T |

Note, that the fact that `F ∨ x = x ∨ F = x` in two-valued logic also helps us fill in the table.

The `¬` connective is easier. If we use the answers for `T` and `F` from two-valued logic, then there is only one realistic choice for `I`:

| P | ¬P |
|---|----|
| F | T  |
| I | I  |
| T | F  |

Using the truth tables above, we can now use the recipe for assigning meaning to formulas that we saw before in the [semantics for Propositional Logic](prop-logic-semantics.html). Valuations now assign `T`, `I`, or `F` to each atomic proposition.

##### Exercises

1. **Excluded Middle** What are all the truth values of `A ∨ ¬A`? How does this compare to its truth values in two-valued logic?

   ```textbox {id=three-valued-1}
   ```

   ```details
   Answer...

   The truth table for this formula is:

   | A | A ∨ ¬A |
   |---|--------|
   | F |   T    |
   | I |   I    |
   | T |   T    |

   For the two-valued semantics:

   | A | A ∨ ¬A |
   |---|--------|
   | F | T      |
   | T | T      |

   In the two-valued regime, this formula is always true so it is *valid*. With three-values, it is only true in the case that the value of `A` is fully determined. We say that the three-valued logic lacks the property of *excluded middle*, where
   ```

2. **Principle of Contradiction** What are all the truth values of `A ∧ ¬A`? How does this compare to its truth values in two-valued logic?

   ```textbox {id=three-valued-2}
   ```

   ```details
   Answer...

   | A | A ∧ ¬A |
   |---|--------|
   | F | F      |
   | I | I      |
   | T | F      |

   For the two-valued semantics:

   | A | A ∧ ¬A |
   |---|--------|
   | F | F      |
   | T | F      |

   In the two-valued system, this formula is always false, so it is never satisfiable. When coupled with the usual semantics of implication, this means that `(A ∧ ¬A) → B` is true for any `B` in two-valued logic.

   In the three-valued logic, we will have two different definitions of implication below. For Kleene's implication, `(A ∧ ¬A) → B` is not true when `A` and `B` are `I`. For Łukasiewicz's implication, `(A ∧ ¬A) → B` is also not valid, because it is `I` when `A = I` and `B = F`.
   ```

3. Check that the following equivalences that hold in two-valued logic also hold in three-valued logic:

   1. `¬¬P = P` (*Double Negation Elimination*)
   2. `¬(P ∧ Q) = ¬P ∨ ¬Q` (*de Morgan 1*)
   3. `¬(P ∨ Q) = ¬P ∧ ¬Q` (*de Morgan 2*)

   (Remember that two formulas are equivalent if they have the same truth value for all valuations).

   ```textbox {id=three-valued-3}
   ```

   ```details
   Answer...

   All of these equivalences hold, which can be seen by writing out the truth tables:

   1. For Double Negation Elimination:

      | P | ¬P | ¬¬P |
	  |---|----|-----|
	  | T | F  |  T  |
	  | I | I  |  I  |
	  | F | T  |  F  |

	  The first and last columns are always the same, so the formulas `P` and `¬P` are equivalent.

   2. For de Morgan 1:

      | P | Q | P ∧ Q | ¬P | ¬Q | ¬(P ∧ Q) | ¬P ∨ ¬Q |
	  |---|---|-------|----|----|----------|---------|
	  | F | F | F     | T  | T  | T        | T       |
	  | F | I | F     | T  | I  | T        | T       |
	  | F | T | F     | T  | F  | T        | T       |
	  | I | F | F     | I  | T  | T        | T       |
	  | I | I | I     | I  | I  | I        | I       |
	  | I | T | I     | I  | F  | I        | I       |
	  | T | F | F     | F  | T  | T        | T       |
	  | T | I | I     | F  | I  | I        | I       |
	  | T | T | T     | F  | F  | F        | F       |

     The last two columns are the same in every row, so these formulas are equivalent.

   3. For de Morgan 2:

      | P | Q | P ∨ Q | ¬P | ¬Q | ¬(P ∨ Q) | ¬P ∧ ¬Q |
	  |---|---|-------|----|----|----------|---------|
	  | F | F | F     | T  | T  | T        | T       |
	  | F | I | I     | T  | I  | I        | I       |
	  | F | T | T     | T  | F  | F        | F       |
	  | I | F | I     | I  | T  | I        | I       |
	  | I | I | I     | I  | I  | I        | I       |
	  | I | T | T     | I  | F  | I        | I       |
	  | T | F | T     | F  | T  | F        | F       |
	  | T | I | T     | F  | I  | F        | F       |
	  | T | T | T     | F  | F  | F        | F       |

     The last two columns are the same in every row, so these formulas are equivalent.
   ```

4. In the language with only atomic propositions, `∧`, `∨` and `¬`, can you write down any *valid* formulas with the three-valued semantics? Just as for two-valued logic, a valid formula is one that has the value `T` for all valuations.

   ```textbox {id=three-valued-4}
   ```

   ```details
   Answer...

   With only  atomic propositions, `∧`, `∨` and `¬` it is **not* possible to write any valid formulas in the three-valued semantics. You can convince yourself of this by looking at the truth tables for the connectives. Notice that in each case, if all of the inputs are `I` then the output is `I`. A formula is valid if it has the value `T` for all valuations. But if the valuation assigns `I` to every atomic proposition, then the value of *any* formula for this valuation must be `I`, and not `T`. So there cannot be a formula that gets the value `T` for all valuations, and so there are no valid formulas built from atomic propositions, `∧`, `∨` and `¬` in three-valued logic.

   Is this a problem? Could we fix it?
   ```

#### Why are these “correct”?

Above, we used an “intuitive” idea of what the connectives mean and how to interpret `I` to fill in the tables. But is there a more systematic way of working it out?

Another way to understand these tables is to think of the truth values as being ordered as `F < I < T` (or you could think of `0 < ½ < 1`). Graphically, we can draw this like so, where up the diagram means higher in the ordering:

```pikchr
circle "T" fit
line down from previous circle.s
circle "I" fit
line down
circle "F" fit
```

Then `P ∧ Q` takes the *minimum* of the values (so the “worst” result wins), and `P ∨ Q` takes the *maximum* of the values (so the “best” result wins). Intuitively, for any logic, `P ∧ Q` is always the “sceptical” operator and `P ∨ Q` is the “optimistic” operator.

Negation swaps the order, leaving `I` in the middle.

The interpretation of `∧` and `∨` as maximum and minimum respectively works for ordinary two-valued logic too, with the ordering `F < T`. Ordering truth values and using minimum and maximum for `∧` and `∨` is a general technique for extending logic to more than two truth values.

##### Exercises

What if we had *four* truth values ordered like this:

```pikchr
T: circle "T" fit
move down left 0.5cm from T.sw
I: circle "I" fit
move down right 0.5cm from T.se
B: circle "B" fit
move down left 0.5cm from B.sw
F: circle "F" fit

line from T.sw to I.ne
line from T.se to B.nw
line from I.se to F.nw
line from B.sw to F.ne
```

These logic is called “Belnap logic”, and is sometimes interpreted with `I` as “neither true nor false” and `B` as “both true and false”. It has been proposed for use in systems where contradictory information may be recieved from multiple sources.

What would be the interpretations of `∧` and `∨`, assuming `∧` is minimum and `∨` is maximum?

What is a sensible interpretation of `¬`? Try thinking about the double negation and de Morgan properties above to help you. Or try staring at the diagram of truth values.

```textbox {id=three-valued-5}
```

```details
Answer ...

If you follow the interpretation of `P ∧ Q` as “minimum” then you are forced to have the following table:

| P ∧ Q | F | I | B | T |
|-------|---|---|---|---|
| F     | F | F | F | F |
| I     | F | I | F | I |
| B     | F | F | B | B |
| T     | F | I | B | T |

The only difficult case is for `I ∧ B` (and, symmetrically, `I ∧ B`), where we have to work out if both `I` and `B` are true. Since `B` is both true and false, then we have enough evidence to make the whole thing false.

The table for `P ∨ Q` is:

| P ∨ Q | F | I | B | T |
|-------|---|---|---|---|
| F     | F | I | B | T |
| I     | I | I | T | T |
| B     | B | T | B | T |
| T     | T | T | T | T |

This is similar to the table for `P ∧ Q` except that `F` and `T` change places and the combination `I ∨ B` is now optimistically chosen to be `T`.

Negation is more straightforward, swapping `T` and `F` and leaving `B` and `I` unchanged:

| P | ¬P |
|---|----|
| F | T  |
| I | I  |
| B | B  |
| T | F  |

You can picture this by flipping the diagram of truth values from top to bottom.

It also works to have negation swap `I` and `B` as well, but this is less easy to motivate in terms of the meanings described above. If `I` means “neither true nor false”, then swapping `True` and `False` ought to mean that `¬I = I`, and similarly for `B`.

Another way to think about four truth values is to think of the truth values as *pairs* of `True` and `False` values. A pair `(A,X)` has a “positive” truth value (`A`) and a negative truth value (`X`). Negation is then defined as swapping `A` and `X`. Can you see how to do the other connectives and to define the ordering in terms of the usual ordering on `True` and `False`?
```

#### Kleene's Implication

We have not yet defined an the semantics of an implication connective on three truth values.

One way to define implication for the three-valued logic is to look at how it is defined for two-valued logic. In two-valued logic, we have that implication is equivalent to `¬P ∨ Q`: `P` implies `Q` exactly when either `P` is false or `Q` is true. Since we have defined `¬` and `∨` we can write down the truth table for `¬P ∨ Q` in three-valued logic:

| P | Q | ¬P | ¬P \/ Q |
|---|---|----|---------|
| F | F | T  | T       |
| F | I | T  | T       |
| F | T | T  | T       |
| I | F | I  | I       |
| I | I | I  | I       |
| I | T | I  | T       |
| T | F | F  | F       |
| T | I | F  | I       |
| T | T | F  | T       |

We can write this more concisely as a square, with `P` in the left column and `Q` along the top:

| P → Q | F | I | T |
|-------|---|---|---|
| F     | T | T | T |
| I     | I | I | T |
| T     | F | I | T |

##### Exercises

As an implication, Kleene's definition behaves very strangely.




1. Is it the case that `P → P` is valid?

   ```textbox {id=three-valued-6}
   ```

   ```details
   Answer...

   No. For example, if `P = I`, then `P → P = I`, which is not `T`.

   We might expect that `P → P` ought to be true, since it says that anything implies itself, but this definition does not make it true. This is related to the fact that
   ```

2. Is it the case that if `P → Q` and `Q → R` are true, then `P → R` is true?

   ```textbox {id=three-valued-7}
   ```

   ````details
   Answer...

   This is actually always the case, which can be checked by writing out a very large truth table.

   ```details
   I can handle the truth (table)

   | P | Q | R | P → Q | Q → R | P → R |
   |---|---|---|-------|-------|-------|
   | F | F | F | T     | T     | T     |
   | F | F | I | T     | T     | T     |
   | F | F | T | T     | T     | T     |
   | F | I | F | T     | I     | T     |
   | F | I | I | T     | I     | T     |
   | F | I | T | T     | T     | T     |
   | F | T | F | T     | F     | T     |
   | F | T | I | T     | I     | T     |
   | F | T | T | T     | T     | T     |
   | I | F | F | I     | T     | I     |
   | I | F | I | I     | T     | I     |
   | I | F | T | I     | T     | T     |
   | I | I | F | I     | I     | I     |
   | I | I | I | I     | I     | I     |
   | I | I | T | I     | T     | T     |
   | I | T | F | T     | F     | I     |
   | I | T | I | T     | I     | I     |
   | I | T | T | T     | T     | T     |
   | T | F | F | F     | T     | F     |
   | T | F | I | F     | T     | I     |
   | T | F | T | F     | T     | T     |
   | T | I | F | I     | I     | F     |
   | T | I | I | I     | I     | I     |
   | T | I | T | I     | T     | T     |
   | T | T | F | T     | F     | F     |
   | T | T | I | T     | I     | I     |
   | T | T | T | T     | T     | T     |

   To check that the claim holds, we just need to check that for every row where the final value is *not* `T`, at least one of the two columns before it is not `T`.
   ```

   One might also hope that it is true that `((P → Q) ∧ (Q → R)) → (Q → R)` is true, but, as we saw above, when all the atomic propositions have the value `I`, the whole formula will have the value `I`.
   ````

3. What does the analogue of Kleene implication look like for the 4-valued logic you defined above?

   ```textbox {id=three-valued-8}
   ```

   ```details
   Answer...

   Working this out as we did for the three-valued logic gives:

   | P → Q | F | I | B | T |
   |-------|---|---|---|---|
   | F     | T | T | T | T |
   | I     | I | I | T | T |
   | B     | B | T | B | T |
   | T     | F | I | B | T |

   Just as for the three-valued logic, we do have that `P → P` is valid, because neither `I` nor `B` imply themselves.
   ```

#### Łukasiewicz's Implication

Łukasiewicz's implication is defined by the following table, where the left column is the `P` and the top row is the `Q`. It differs from Kleene's implication only in saying that `I` implies `I` is `T`.

| P ⊸ Q | F | I | T |
|-------|---|---|---|
| F     | T | T | T |
| I     | I | T | T |
| T     | F | I | T |

This fixes the problem with `P → P`, because now the top-left to bottom-right diagonal is always `T`.

The downside is that the implication in this logic is very different to the implication in two-valued logic. In fact, we get a completely new logic that loses the connection between `∧` and `∨` and implication. We will see a similar situation when we consider [Intuitionistic Logic](sound-complete-meaning.html), which retains a connection between `∧` and implication, but not with `∨`.

## Further Reading

- The [Wikipedia page](https://en.m.wikipedia.org/wiki/Three-valued_logic) on three-valued logic describes the Kleene and Łukasiewicz variants and some more besides.
- The general field is known as “multi-valued logic”, and the technical material can get quite deep. A useful variant is when we have *infinitely many* truth values: all real numbers between `0` and `1`. This is known as “fuzzy logic” and has been proposed for use in situations truth is fuzzy. For example, the statement “Bob is tall” isn't a `True`/`False` statement, but one that relies on a fuzzy idea of what tall means. Closely related are probabilistic logics, where the number indicates the probability that we consider this thing to be true.
- A good introduction to these kinds of logics is Graham Priest's book [An Introduction to Non-Classical Logic](https://www.cambridge.org/core/books/an-introduction-to-nonclassical-logic/61AD69C1D1B88006588B26C37F3A788E).
- We will look at another “non-classical” but **not** many-valued logic when we consider the [soundness and completeness](sound-complete-meaning.html) of our proof system.
