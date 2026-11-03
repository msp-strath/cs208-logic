# Topic 8 : Semantics of Predicate Logic

```aside
This page assumes that you have read the [Introduction to Predicate Logic](pred-logic-intro.html). You can also read the [proof rules for predicate logic](pred-logic-rules.html) to get a feel for how the quantifiers in predicate logic work.
```

The semantics of Predicate Logic is more complex than the [semantics of Propositional Logic](prop-logic-semantics.md) due to the additional layers of terms and quantifiers. In compensation it is much more useful.

To interpret a Predicate Logic formula we need to upgrade the idea of a valuation (the mapping from atomic propositions to true/false values) to a [*model*](pred-logic-semantics.md#pred-sem:models). Models come in two parts:

1. a collection of all the things in the universe, which may be infinite; and
2. the meanings of all the predicate symbols in our vocabulary as collections of related elements of the universe.

We will see the [definition of model below](pred-logic-semantics.md#pred-sem:models) with examples.

A useful intuition to think about models is as databases: the universe is the collection of all things that can be in the fields of a database, and each predicate symbol is interpreted as a (possibly infinite) table of related elements of the universe.

Once we have a definition of model we can [interpret Predicate Logic formulas](pred-logic-semantics.md#pred-sem:interp). We do this in the same way as we [did for Propositional Logic](prop-logic-semantics.md), by breaking the formula down into its constituent parts, working out their meaning separately, and then combining the meanings together.

With an interpretation of formulas we can define [entailment for Predicate Logic](pred-logic-semantics.md#pred-sem:entailment). As with Propositional Logic, entailment means that, for all models, if all the assumptions are true then the conclusion is true. For Predicate Logic, there are infinitely many models and each one may itself be infinite; so checking them all one by one in a truth table is no longer possible. This is why proof for Predicate Logic is more essential than for Propositional Logic.

The semantics of Predicate Logic demonstrates the tight connection between Logic and Databases. We can think of the semantics of a formula as a database table representing all the values of its variables that make it true. [Database queries are essentially the same thing as logical formulas](using-models.md#using-models:databases).

## Vocabularies {id=pred-sem:vocabs}

When we introduced the [syntax of Predicate Logic](pred-logic-intro.md), we said that formulas are built from collections of *function symbols* and *relation symbols* that are fixed in advance. Collectively these are called a *vocabulary* and form part of what we will call a *theory*. Every time we discuss the meaning of formulas, we must be clear about the vocabulary we are working in.

To keep things simple we will ignore function symbols and assume that our vocabularies only have relation symbols.

````details
Is ignoring function symbols okay?

Is this a simplification too far? It is not, because we can always translate a formula that uses function symbols into one that doesn't by introducing extra relation symbols and additional axioms:

1. For every function symbol `f` that takes `n` arguments, we assume a relation symbol `Rf` that takes `n + 1` arguments. The idea is that `Rf(x,y,z)` represents `f(x,y) = z`.
2. Every use of function symbols can now be turned into a formula with extra existential quantification. For example, `P(f(x,y),g(z))` would turn into the formula:
   ```formula
   ex t1. ex t2. P(t1,t2) /\ Rf(x,y,t1) /\ Rg(z,t2)
   ```
3. We also add assumptions that state that each `Rf` relation acts like a function:
   1. For every input `x,y` there exists an output `z`
   2. These outputs are unique.

The resulting formula with the additional assumptions is provable exactly when the original was, so we have not lost anything. Predicate logic without function symbols is as expressive as with, although formulas do become much lengthier.
````

To have a way to unambiguously write down vocabularies, we use the notation `predicate <relation-name>/n`, where `<relation-name>` is the name of the relation and `n` is a number indicating the number of arguments this symbol has for each relation in the vocabulary. We will write vocabularies as `theory <NAME> { <relation-symbols> }`.

For example, for the theory of humanity and mortality where `human` and `mortal` are both relation symbols that take one argument, we write this as:
```
theory Mortality {
  predicate human/1
  predicate mortal/1
}
```
A theory for talking about things that are less than other things would have a predicate `lt` (“lessthan”) that takes two arguments:
```
theory Ordering {
  predicate lt/2
}
```
A theory for talking about places including cities and countries and whether or not they are within each other would have a vocabulary like:
```
theory Places {
  predicate city/1
  predicate country/1
  predicate within/2
}
```

Equality is a `2`-ary predicate symbol `=/2`. We will always include equality in our vocabularies without mentioning it, due to the way it is [treated specially](pred-logic-rules.md#pred-logic:equality) in logic. Disequality `x != y` is treated as an abbreviation for `¬ (x = y)`.

## Models {id=pred-sem:models}

To interpret a Predicate Logic formula, we need to give a meaning to the predicate symbols in our vocabulary. This is analogous to the [valuations](prop-logic-semantics.md#prop-logic:semantics:valuations) we used in the semantics of Propositional Logic to determine the meaning of each atomic proposition. For predicate logic, instead of each symbol just being `True` or `False` in itself, we now need to say for which individuals it is `True` or `False`.

But to even say that, we first need to say what the possible individuals are. The collection of all possible individuals is called the **universe** of a model. This collection may be finite or infinite, or even empty. (Note that some other presentations of Predicate Logic do not allow empty universes, but we do here.)

Then for each predicate symbol `pred/n`, we must say for which of the values of the universe it is true. When writing down models, we do not usually explicitly say for which values the predicate is false; anything that we do not list is regarded as false.

For example, the `Mortality` vocabulary could have a model with three entities in the universe: `jason`, `zeus`, and `wuffles` (the dog). The `human/1` predicate contains `jason`, and the `mortal/1` predicate contains `jason` and `wuffles` (the dog). Clicking **Run** checks the given model against the vocabulary.

```model-checker {id=predsem-greekmyth-model}
theory Mortality {
  predicate human/1
  predicate mortal/1
}

model GreekMyth for Mortality {
  universe = { jason, zeus, wuffles }
  human = { jason }
  mortal = { jason, wuffles }
}
```

**Exercise**. Try changing the model and clicking **Run** to see what is allowed. For instance, try removing `wuffles` from the universe. The **Reset** button will reset the text box to the original example.

The `Mortality` vocabulary has only `1`-ary predicates. In general, predicates have more than one argument, which we write as multiple values in parentheses separated by commas. The elements of a predicate's definition are usually called *tuples*: they are fixed size collections of elements where the order matters. If the number of elements is `n`, then they are called `n`-tuples. Programming Languages like Python and Haskell have tuples as built-in datatypes.

For example, in the `Ordering` vocabulary, the `lt/2` predicate has arity `2` so we write its elements as pairs `(x,y)`:

```model-checker {id=predsem-ordering-model}
theory Ordering {
  predicate lt/2
}

model Line for Ordering {
  universe = { low, medium, high }
  lt = { (low, medium), (low, high), (medium, high) }
}

model Circle for Ordering {
  universe = { north, south }
  lt = { (north, south), (south, north) }
}
```

**Exercise**. Try changing these models to see what is allowed. For instance, try entering a 1-tuple or a 3-tuple in the definition of `lt` to see what happens.

The `Circle` model for `Ordering` is not necessarily what we might think of as an ordering with our intuitive idea of what `lessthan` might mean. We will discuss this further below.

In general, it is also possible for models to be infinite, although the tool used here cannot handle this. For example, the `Ordering` vocabulary could have a universe the contains all the numbers `0, 1, 2, 3, 4, ...` with `(x,y)` in `lessthan` exactly when `x < y`.

Altogether, a **model** consists of:

1. The *universe*: a collection of all the things that are considered to exist;
2. For each predicate symbol `pred/n` a collection of `n`-tuples of elements of the universe for which `pred` is considered to be true.

A useful intuition to think about models is as databases: each predicate symbol is interpreted as a (possibly infinite) table of related elements of the universe. For example, the `Places` vocabulary defined above has an associated model that records the countries and some of the cities of the United Kingdom. We can think of `city`, `country`, and `within` as *tables* of data within a database.

```model-checker {id=predsem-places-model-uk}
theory Places {
  predicate city/1
  predicate country/1
  predicate within/2
}

model UnitedKingdom for Places {
  universe = { england, scotland, wales, northern-ireland,
               london, edinburgh, cardiff, belfast, birmingham,
               liverpool, swansea, glasgow, derry }
  city = { london, edinburgh, cardiff, belfast, birmingham,
           liverpool, swansea, glasgow, derry }
  country = { england, scotland, wales, northern-ireland }
  within = { (london, england),
             (edinburgh, scotland),
             (cardiff, wales),
             (belfast, northern-ireland),
             (birmingham, england),
             (liverpool, england),
             (swansea, wales),
             (glasgow, scotland),
             (derry, northern-ireland) }
}
```

Once we understand how to [interpret formulas in models](pred-logic-semantics.md#pred-sem:interp), we will be able to *query* models by asking which formulas are true in that model. [There is a close connection](using-models.md#using-models:databases) between databases queries in a language like SQL and logical formulas.

The predicate names we use in our vocabularies are just names. This means that there can exist models for vocabularies that may not match our intuitions about what the names mean.

The `Circle` model for the `Ordering` theory is an example of a model that doesn't match what we might mean as `lessthan` because it says that `north` is less than `south`, but also that `south` is less than `north`. Another example in the `Places` theory. We may intuitively assume that cities and countries are distinct categories, and that a country is not within itself, but there is nothing stopping a model of the `Places` theory from violating these properties, as this `LoopLand` model shows:

```model-checker {id=predsem-places-model-loopland}
theory Places {
  predicate city/1
  predicate country/1
  predicate within/2
}

model LoopLand for Places {
  universe = { loopland }
  city = { loopland }
  country = { loopland }
  within = { (loopland, loopland) }
}
```

To distinguish “good” models from “bad” models, we need a language to state properties of models. This language is [Predicate Logic](pred-logic-intro.md). For a fixed vocabulary, formulas using that vocabulary can be interpreted in models for that vocabulary and we can ask whether they are True or False in each model.

## Interpretation of Formulas {id=pred-sem:interp}

To interpret a formula we fix a vocabulary and a model `M` for that vocabulary. The formulas we interpret must be written using the vocabulary.

We do this using the same strategy we used for [Propositional Logic](prop-logic-semantics.md). We break the formula down into its constituent parts, work out their meanings separately, and then combine the meanings together. The subtlety in interpreting Predicate Logic formulas is that the collection of free variables varies across different subformulas within the same formula. Propositional Logic formulas do not have free variables, so this problem does not arise.

### Meaning of free variables {id=pred-sem:interp:freevars}

Formulas can have free variables that are not quantified, as we saw when asking [when two formulas are the same](pred-logic-intro.md#pred-logic:alpha-equiv). For example, the formula
```formula
city(x) /\ within(x,y)
```
has two free variables, `x` and `y`. Even if we have a model that tells us when `city` and `within` are true, We can't give this formula a truth value until we know what `x` and `y` mean. Our fixed model `M` tells us what *possible* values `x` and `y` have, and what the truth value of `city` and `within` are for those values. The meaning of the formula varies according the exact values we choose for `x` and `y`.

For example, the `UnitedKingdom` model sets a particular universe. If we set `x` to be `glasgow` and `y` to be `scotland` from that universe, then the formula
```formula
city(x) /\ within(x,y)
```
has the meaning of
```formula
city(glasgow) /\ within(glasgow,scotland)
```
which is true in the model because `glasgow` is in the `city` predicate's interpretation and `(glasgow,scotland)` is in the `within` predicate's interpretation. But if we set `x` to be `scotland` and `y` to be `edinburgh`, then the formula ought to be assigned the value `F`, because neither `city(scotland)` nor `within(scotland,edinburgh)` are true in the model.

In general, for a formula `P` with free variables `x1, x2, ..., xn` we need an assignment `v` that tells us for each variable `xi` what element of the universe should be used to interpret it.

If `v` is an assignment of individuals to variables, we write `v(x)` for the value assigned to `x`. For example, if `v = [ x ↦ glasgow, y ↦ scotland ]`, then `v(x) = glasgow` and `v(y) = scotland`.

### Interpreting Formulas {id=pred-sem:interp:formulas}

Given a formula `P` with a valuation `v` that assigns elements of the universe to `P`'s free variables, we can work out the meaning `P` by breaking it down into its component parts, working out the truth values of them and then combining the truth values.

Remember that we are fixing a vocabulary `V` and a model `M`.

The two basic formulas are:

1. Uses of predicate symbols `R(x1,...,xn)`. In this formula, the variables `x1`,...,`xn` are free, so we have an `n`-tuple `(v(x1), ..., v(xn))` created by using the current assignment `v` to work out what each variable means. If this tuple is in the interpretation of the predicate symbol `R` in the model, then the formula `R(x1,...,xn)` is True. Otherwise it is False.

2. Equalities `x = y`. In this formula, the variables `x` and `y` are free. The formula is True if `v(x)` is actually equal to `v(y)` and False otherwise.

```details
Exercise: What about x != y?

What about the basic formula `x != y`?

This is True if `v(x)` and `v(y)` are *unequal* and False if they are equal. Exactly the negation of the meaning of `x = y`.
```

In symbols, using the double square (“Scott”) bracket notation (similar to the interpretation of [Propositional Logic](prop-logic-semantics.md#prop-logic:semantics:formulas)) to describe the meaning of syntax, we have:

```
〚R(x1,...,xn)〛v = T if (v(x1), ..., v(xn)) ∈ R
                  = F otherwise

〚x = y〛v        = T if v(x) = v(y)
                  = F otherwise
```

-  **Example**. In the `UnitedKingdom` model, we have:
   ```
   〚within(x,y)〛([ x ↦ glasgow, y ↦ scotland ]) = T
   ```
   and
   ```
   〚within(x,y)〛([ x ↦ glasgow, y ↦ wales ]) = F
   ```
- **Example**. In the `LoopLand` model, we have:
  ```
  〚within(x,x)〛([ x ↦ loopland ]) = T
  ```
  because `(loopland, loopland)` is in the interpretation of the `within` predicate in that model.

The quantifiers are where we extend the assignment `v` to cover the additional variables in the body of the formula. We write `v[x ↦ a]` for the assignment `v` extended to assign `a` to `x` and to assign `v(y)` to every `y` not equal to `x`. (This *updating* operation is similar to the [array set operation](hoare-arrays.md#hoare-arrays:axioms)).

The quantifiers are interpreted by checking the truth values of the subformulas for all elements of the universe. The quantifiers differ in whether the subformula has to be true for all elements or for some element:

1. If the formula is `∀x. P` for the assignment `v`, then it is true if `P` is true for the assignment `v[x ↦ a]` **for all** values `a` in the universe. Otherwise, it is false.
2. If the formula is `∃x. P` for the assignment `v`, then it is true if `P` is true for the assignment `v[x ↦ a]` **for some** value `a` in the universe. Otherwise, it is false.

In symbols, using the double bracket notation:
```
〚∀x. P〛v = T   if for all 'a' in the universe, 〚P〛(v[x ↦ a]) = T
           = F    otherwise

〚∃x. P〛v = T   if for some 'a' in the universe, 〚P〛(v[x ↦ a]) = T
           = F    otherwise
```

These definitions may seem like they are doing nothing more than defining the “for all” quantifier in terms of our prior understanding of “for all things”, but the key point is that the variables *only take values from the universe*. As far as the interpretations of formulas in a particular model is concerned, it is only the values in the universe of the model that matter.

- **Example**. In the `UnitedKingdom` model, we have `〚∀x. city(x)〛v = F`, because it is not the case that *for all* possible values of `x` that `city(x)` is true (it is not true for `x = scotland`). On the other hand, `〚∃x. city(x)〛v = T`, because there exists at least one city in this model (e.g., `x = swansea`).

The propositional connectives are the same as they were for [Propositional Logic](prop-logic-semantics.md#prop-logic:semantics:connective-meanings):
```
 〚 P ∧ Q 〛v = 〚 P 〛v and 〚 Q 〛v
 〚 P ∨ Q 〛v = 〚 P 〛v or 〚 Q 〛v
 〚 ¬ P 〛v   = not 〚 P 〛v
 〚 P → Q 〛v = 〚 P 〛v  implies 〚 Q 〛v
```

- **Examples** In the `Places` vocabulary and the `UnitedKingdom` model, the formula
  ```formula
  city(x) /\ within(x,y)
  ```
  has different interpretations depending on the assignment it is valued at. We compute the meaning by breaking down the formula:

  1. If `v` is `[ x ↦ edinburgh, y ↦ scotland ]`, then:
     ```
       〚 city(x) ∧ within(x,y) 〛v
	 = 〚 city(x) 〛v and 〚 within(x,y) 〛v
	 = (edinburgh ∈ city) and ((edinburgh, scotland) ∈ within)
	 = T and T
	 = T
	 ```
  2. If `v` is `[ x ↦ edinburgh, y ↦ birmingham ]`, then:
     ```
       〚 city(x) ∧ within(x,y) 〛v
	 = 〚 city(x) 〛v and 〚 within(x,y) 〛v
	 = (edinburgh ∈ city) and ((edinburgh, birmingham) ∈ within)
	 = T and F
	 = F
	 ```

   If we keep `v` as `[ x ↦ edinburgh, y ↦ birmingham ]` but change the `∧` to `∨`, then:
   ```
	 〚 city(x) ∨ within(x,y) 〛v
   = 〚 city(x) 〛v or 〚 within(x,y) 〛v
   = (edinburgh ∈ city) or ((edinburgh, birmingham) ∈ within)
   = T or F
   = T
   ```

For a closed formula (one with no free variables), we can value it in any model for its vocabulary. For example, the formula
```formula
all x. ¬(city(x) /\ country(x))
```
Is valued as `True` in the `UnitedKingdom` model, but as `False` in the `LoopLand` model.

Whether or not a closed formula is true in a model is a useful property because it tells use something about that model. So we use the special notation
```
    M ⊧ P
```
to indicate when a formula `P` is true in a model `M`. We write `M ⊭ P` when `P` is not true when evaluated in `M`.

So we have `UnitedKingdom ⊧ ∀x. ¬(city(x) ∧ country(x))` and `LoopLand ⊭ ∀x. ¬(city(x) ∧ country(x))`.

### Exercises {id=pred-sem:interp:exercises}

1. Compute the truth value of the formula
   ```formula
   all x. city(x) \/ country(x)
   ```
   in the `UnitedKingdom` model and in the `LoopLand` model.

   ````details
   Solution

   In the `UnitedKingdom` model, we go through each of the possible values of `x` to see whether or not `city(x) \/ country(x)` is true. If they are all true, then the formula is true.

   | Value of `x`       | city(x) | country(x) | city(x) \/ country(x) |
   |--------------------|---------|------------|-----------------------|
   | `england`          | F       | T          | T                     |
   | `scotland`         | F       | T          | T                     |
   | `wales`            | F       | T          | T                     |
   | `northern-ireland` | F       | T          | T                     |
   | `london`           | T       | F          | T                     |
   | `edinburgh`        | T       | F          | T                     |
   | `cardiff`          | T       | F          | T                     |
   | `belfast`          | T       | F          | T                     |
   | `birmingham`       | T       | F          | T                     |
   | `liverpool`        | T       | F          | T                     |
   | `swansea`          | T       | F          | T                     |
   | `glasgow`          | T       | F          | T                     |
   | `derry`            | T       | F          | T                     |

   By looking at the last column, we can see that the formula `city(x) \/ country(x)` is true  for all possible values of `x`, so the formula `all x. city(x) \/ country(x)` is true.

   In the `LoopLand` model, the table is much shorter:

   | Value of `x` | city(x) | country(x) | city(x) \/ country(x) |
   |--------------|---------|------------|-----------------------|
   | `loopland`   | T       | T          | T                     |

   Again, by looking at the last column, we can see that the formula `city(x) \/ country(x)` is true  for all possible values of `x`, so the formula `all x. city(x) \/ country(x)` is true in this model as well.
   ````

2. Compute the truth value of the formula
   ```formula
   ex x. city(x) /\ country(x) /\ within(x,x)
   ```
   in the `UnitedKingdom` model, and in the `LoopLand` model.

   ```details
   Solution

   In the `UnitedKingdom` model, this formula is not true. To show this conclusively, we check it for every possible value of `x`:

   | Value of `x`       | city(x) | country(x) | within(x,x) | city(x) ∧ country(x) ∧ within(x,x) |
   |--------------------|---------|------------|-------------|------------------------------------|
   | `england`          | F       | T          | F           | F                                  |
   | `scotland`         | F       | T          | F           | F                                  |
   | `wales`            | F       | T          | F           | F                                  |
   | `northern-ireland` | F       | T          | F           | F                                  |
   | `london`           | T       | F          | F           | F                                  |
   | `edinburgh`        | T       | F          | F           | F                                  |
   | `cardiff`          | T       | F          | F           | F                                  |
   | `belfast`          | T       | F          | F           | F                                  |
   | `birmingham`       | T       | F          | F           | F                                  |
   | `liverpool`        | T       | F          | F           | F                                  |
   | `swansea`          | T       | F          | F           | F                                  |
   | `glasgow`          | T       | F          | F           | F                                  |
   | `derry`            | T       | F          | F           | F                                  |

   There does not exist a single row where the last column is `T`, so the whole formula is false.

   In the `LoopLand` model, the table looks like:

   | Value of `x` | city(x) | country(x) | within(x) | city(x) ∧ country(x) ∧ within(x,x) |
   |--------------|---------|------------|-----------|------------------------------------|
   | `loopland`   | T       | T          | T         | T                                  |

   The single row in this table has `T` in the last column, so the formula is true.
   ````

3. Compute the truth value of the formula
   ```formula
   all x. city(x) -> (ex y. country(y) /\ within(x,y) /\ x != y)
   ```
   in the `UnitedKingdom` and `LoopLand` models.

   ````details
   Solution...

   This formula is more complex than the ones above because it has two quantifiers. For the `UnitedKingdom` model. We could make a table that has all 13*13 = 169 combinations, and check that for every one in the first column there exists one in the second column that makes the rest of the formula true. Fortunately, we can make things simpler for ourselves by noticing that the first part of the formula `all x. city(x) → ...` restricts the `x`s to those for which `city(x)` is true. The second part of the formula starts with `ex y. country(y) ∧ ... `, which means that we have to show that (for each `x` that is a city) that there exists a country `y`. Finally, the formula ends with `within(x,y) ∧ x != y`, which states the relationship that must hold between `x` and `y`.

   For the `UnitedKingdom` model, this means that the reasoning we have to do is to go through each city, and find a country it is within and not equal to it?

   1. If the city is `london`, `birmingham`, or `liverpool`, then we can choose `england`
   2. If the city is `edinburgh` or `glasgow`, then we can choose `scotland`
   3. If the city is `cardiff` or `swansea`, then we can choose `wales`
   4. If the city is `belfast` or `derry`, then we can choose `northern-ireland`

   This covers all the cities, so the formula is true.

   For the `LoopLand` model, there is only one city, `loopland`. We can choose a country it is within, again `loopland`. However, it is not the case that `loopland != loopland`. Since this was the only choice we could have made, the formula is false.
   ````

## Entailment {id=pred-sem:entailment}

We defined **entailment** in [Propositional Logic](entailment.md) as a relation between a collection of assumptions and a conclusion:
```
   P1, ..., Pn ⊧ Q
```
This relation “holds” or “is valid” if for all valuations, if all the assumptions are true, then the conclusion is true.

For Predicate Logic we use the same idea, except that instead of valuations we use models.

**Definition** (Entailment). When `P1`, ..., `Pn`, and `Q` are closed Predicate Logic formulas in some vocabulary `V`, we say that the entailment `P1, ..., Pn ⊧ Q` holds if *for all models* `M`, if for all `i`, `M ⊧ Pi`, then `M ⊧ Q`.

Checking entailment for Propositional Logic was possible by checking every possible valuation (although to do this naively would take `2^n` steps to check every valuation). Checking entailment for Predicate Logic is not possible by this simple enumeration technique because there are infinitely many possible models (e.g., all models with size 0, all models with size 1, size 2, ..., and infinite models), and individual models may themselves be infinite. This is why using proof to establish entailment is essential.

## Soundness and Completeness {id=pred-sem:sound-complete}

We now have two definitions that describe when a conclusion follows from some assumptions: proof and entailment. In the [proof rules for Predicate Logic](pred-logic-rules.md), we developed a system for proving judgements of the form:
```
   P1, ..., Pn ⊢ Q
```
that say that `Q` is provable from the assumptions `P1`, ..., `Pn`.

Using models and interpretations, we have another definition of *semantic entailment*, [defined above](pred-logic-semantics.md#pred-sem:entailment):
```
   P1, ..., Pn ⊧ Q
```

As with [Propositional Logic](natural-deduction-intro.md#natural-deduction:sound-complete), these two definitions are linked by the properties of **soundness** and **completeness**:

1. The proof system is **sound** for this semantics, meaning that if a judgement `P1, ..., Pn ⊢ Q` is provable, then the entailment `P1, ..., Pn ⊧ Q` is valid.

   This property is relatively easy to prove by checking that all of the proof rules preserve valid entailments: for each rule, if the premises are valid entailments, then so is the conclusion. The `done`, `true`, and `refl` rules have no premises, so they get us started.

   A very useful consequence of soundness, other than an assurance that what we prove is actually true, is that we can use it to [show that some formulas are *not* provable](using-models.md#using-models:proof-counter).

2. If we add [excluded middle](natural-deduction-intro.md#natural-deduction:sound-complete) (the rule that says `P ∨ ¬P` for all `P`) to the proof system, then it is also **complete**. This means that if an entailment `P1, ..., Pn ⊧ Q` is valid, then the judgement `P1, ..., Pn ⊢ Q` is provable.

   This property is much harder to prove that soundness. It was original proved by Kurt Gödel and is often called “Gödel's Completeness Theorem” (you may have heard of Gödel's more famous *incompleteness* theorem). The proof works by constructing a special model from the assumptions `P1`, ..., `Pn` that makes the things provable from the assumptions true and nothing else.

The combination of soundness and completeness is quite remarkable. Entailment involves quantification over *all* (infinite many) models, and then *all* (possibly infinitely many) elements of those models, but proofs are things that can be finitely checked.

```details
What about without Excluded Middle?

The proof system without excluded middle is sound and complete for a more sophisticated semantics where truth is computed relative to a “possible world” from a collection of all possible worlds that represent stages of knowledge. The Stanford Encyclopedia of Philosophy has a section on [Semantics of Intuitionistic Logic](https://plato.stanford.edu/entries/logic-intuitionistic/#BasiSema).
```

## Theories {id=pred-sem:theories}

For the `Places` vocabulary, the `UnitedKingdom` model matches what we might think of as a sensible model, but the `LoopLand` model does not. Now that we have a definition of whether or not a formula is true in a model, we can use this to define what “good” models are by requiring that they make a list of formulas true.

We will call the combination of a vocabulary and a list of closed formulas a **theory**. The individual formulas in a theory are called the **axioms** of the theory. A theory defines a collection of models that satisfy its axioms. In this case we can say that such things are *models of the theory*.

Note that two different lists of axioms might define the same collection of models. So we might have two apparently different theories that have exactly the same set of models. Strictly speaking, we ought to refer to lists of formulas as **axiomatisations** that *generate* theories, but for our purposes it is useful to work just with axiomatisations.

### Example: Places Theory {id=pred-sem:theories:places}

The `Places` theory with some reasonable axioms might be written with three axioms

1. Everything is a city or a country:
   ```formula
   all x. city(x) \/ country(x)
   ```
2. Nothing is both a city and a country:
   ```formula
   all x. ¬(city(x) /\ country(x))
   ```
3. Cities are within countries
   ```formula
   all x. city(x) -> (ex y. country(y) /\ within(x,y))
   ```

The `UnitedKingdom` model is a model of these axioms. The `LoopLand` model is not. Click **Run** to check them. What happens if you alter the models?

```model-checker {id=predsem-places-theory}
theory Places {
  predicate city/1
  predicate country/1
  predicate within/2

  axiom everything-city-or-country :
    "all x. city(x) \/ country(x)"

  axiom nothing-city-and-country :
    "all x. ¬(city(x) /\ country(x))"

  axiom cities-within-countries :
    "all x. city(x) -> (ex y. country(y) /\ within(x,y))"
}

model UnitedKingdom for Places {
  universe = { england, scotland, wales, northern-ireland,
               london, edinburgh, cardiff, belfast, birmingham,
               liverpool, swansea, glasgow, derry }
  city = { london, edinburgh, cardiff, belfast, birmingham,
           liverpool, swansea, glasgow, derry }
  country = { england, scotland, wales, northern-ireland }
  within = { (london, england),
             (edinburgh, scotland),
             (cardiff, wales),
             (belfast, northern-ireland),
             (birmingham, england),
             (liverpool, england),
             (swansea, wales),
             (glasgow, scotland),
             (derry, northern-ireland) }
}

model LoopLand for Places {
  universe = { loopland }
  city = { loopland }
  country = { loopland }
  within = { (loopland, loopland) }
}
```

### Example: Mortality Theory {id=pred-sem:theories:mortality}

```model-checker {id=predsem-computing-greek}
theory Mortality {
  predicate human/1
  predicate mortal/1

  axiom all-humans-are-mortal :
    "all x. human(x) -> mortal(x)"
}

model GreekMyth for Mortality {
  universe = { jason, zeus, wuffles }
  human = { jason }
  mortal = { jason, wuffles }
}
```

**Exercise**. Add the axiom `all-mortals-are-human` to the `Mortality` theory:
```formula
all x. mortal(x) -> human(x)
```
Notice that the `GreekMyth` model is no longer valid for this theory. What modifications to the model are needed to make the model match the theory?

```details
Solution

To make both formulas true, you need to make the elements of `human` and `mortal` the same. So you could add `wuffles` to `human`, or remove `wuffles` from `mortal`.
```

### Example: Theories with No Models {id=pred-sem:theories:empty-theories}

It is possible for a theory to be *inconsistent*, which means that it has no models. The simplest example is one that has `F` (False) as an axiom. Since `F` is never True, this axiom cannot be true for any model. There is no universe that you can construct that will make `F` true:

```model-checker {id=theory-empty}
theory Inconsistent {
  axiom false-is-true : "F"
}

model M for Inconsistent {
  universe = { }
}
```

Inconsistent theories are bad because they have no models, so they have nothing that they are actually talking about. Anything that we prove from the axioms of an inconsistent theory is worthless because there are no models for it to be true in.

In the previous example, it was relatively easy to spot that the theory was inconsistent. But it is possible for collections of axioms that are individually okay to combine to form a theory that is inconsistent in ways that are non-obvious.

As an example, let's assume that we want to add city-states to our `Places` theory (Inverness has decided to declare independence from Scotland, but wants to remain in the UK). We add the axiom that says that there must be something which is both a city and a country:
```formula
ex x. city(x) /\ country(x)
```
But now there are no models of this theory! Clicking **Run** will report that neither `UnitedKingdom` nor `LoopLand` are models.

```model-checker {id=theory-empty-places}
theory Places2 {
  predicate city/1
  predicate country/1
  predicate within/2

  axiom everything-city-or-country :
    "all x. city(x) \/ country(x)"

  axiom nothing-city-and-country :
    "all x. ¬(city(x) /\ country(x))"

  axiom cities-within-countries :
    "all x. city(x) -> (ex y. country(y) /\ within(x,y))"

  axiom city-and-country :
    "ex x. city(x) /\ country(x)"
}

model UnitedKingdom for Places2 {
  universe = { england, scotland, wales, northern-ireland,
               london, edinburgh, cardiff, belfast, birmingham,
               liverpool, swansea, glasgow, derry }
  city = { london, edinburgh, cardiff, belfast, birmingham,
           liverpool, swansea, glasgow, derry }
  country = { england, scotland, wales, northern-ireland }
  within = { (london, england),
             (edinburgh, scotland),
             (cardiff, wales),
             (belfast, northern-ireland),
             (birmingham, england),
             (liverpool, england),
             (swansea, wales),
             (glasgow, scotland),
             (derry, northern-ireland) }
}

model LoopLand for Places2 {
  universe = { loopland }
  city = { loopland }
  country = { loopland }
  within = { (loopland, loopland) }
}
```

Of course, the fact that we aren't able to find a model for this theory is not a *proof* that there isn't one. We might just have not been able to think of one. To conclusively prove that there is no model for this theory, we need to show that it is possible to prove `F` from the axioms. We can do this for this the theory `Places2`:

```focused-nd {id=predsem-computing-contra}
(config
 (assumptions
  (city-and-country "ex x. city(x) /\ country(x)")
  (nothing-city-and-country "all x. ¬(city(x) /\ country(x))"))
 (goal "F")
 (solution (Rule(Use city-and-country)((Rule(ExElim x H)((Rule(Use nothing-city-and-country)((Rule(Instantiate(Var x))((Rule NotElim((Rule(Use H)((Rule Close())))))))))))))))
```

### Example: Everything is Equal {id=pred-sem:theories:no-preds}

Models for the theory with the axiom that “all things are equal” are either:

1. Empty; or
2. Have exactly one thing in the universe

```model-checker {id=predsem-everything-equal}
theory AllEqual {
  axiom all-equal : "all x. all y. x = y"
}

model Nothingness for AllEqual {
  // All of nothing is equal (are equal?)
  universe = { }
}

model Unity for AllEqual {
  // Adding things to the universe makes it not a model
  universe = { a }
}
```

### Example: Less Than Theory {id=pred-sem:theories:less-than}

More usefully, the theory of “less than” is described using two axioms:

1. If `x` is less than `y` and `y` is less than `z`, then `x` is less than `z` (transitivity):
   ```formula
   all x. all y. all z. lt(x,y) -> lt(y,z) -> lt(x,z)
   ```
2. Nothing is less than itself:
   ```formula
   all x. ¬lt(x,x)
   ```

**Exercise** The `Line` model from above is a model of this theory, but the `Circle` model is not. The `Circle` model fails `transitivity`. Make the `transitivity` axiom succeed for `Circle` by adding tuples to the `lt` definition. Can you make it also support `irreflexive` without removing anything?

```model-checker {id=theory-lessthan}
theory Ordering {
  predicate lt/2
  axiom transitivity:
    "all x. all y. all z. lt(x,y) -> lt(y,z) -> lt(x,z)",
  axiom irreflexive: "all x. ¬lt(x,x)"
}

model Line for Ordering {
  universe = { low, medium, high }
  lt = { (low, medium), (low, high), (medium, high) }
}

model Circle for Ordering {
  universe = { north, south }
  lt = { (north, south), (south, north) }
}
```

The `Ordering` theory prevents interpretations of `lt` that contain the kinds of cycles that the `Circle` model demonstrates.

Another axiom we could add to the `Ordering` theory is that everything has something it is less than:
```formula
all x. ex y. lt(x,y)
```
If we add this formula to the theory, we get a theory that is still *consistent* (it has models), but all models are either empty or infinite. This is because combination of prohibiting cycles, but always requiring a next element, forces any model that has at least one thing to have another thing, and another thing, and another thing, ...

``````comment

### Example: Number Theory {id=pred-sem:theories:numbers}

```model-checker {id=theory-numbers}
theory Number {
  predicate zero/1
  predicate succ/2
  predicate add/3
  predicate mul/3

  axiom unique-zero :
    "ex z. zero(z) /\ (all z'. zero(z') -> z = z')"
  axiom unique-succ :
    "all x. ex y. succ(x,y) /\ (all y'. succ(x,y') -> y = y')"
  axiom succ-injective :
    "all x1. all x2. all y. succ(x1,y) -> succ(x2,y) -> x1 = x2"

  axiom never-zero-and-succ :
    "all x. ¬(zero(x) /\ (ex y. succ(y,x)))"
  axiom all-zero-or-succ :
    "all x. zero(x) \/ (ex y. succ(y,x))"

  axiom unique-add :
    "all x. all y. ex z. add(x,y,z) /\ (all z'. add(x,y,z') -> z = z')"
  axiom add-zero :
    "all x. all y. zero(x) -> add(x,y,y)"
  axiom add-succ :
    "all x. all y. all z. all z'.
	  succ(x,x') -> add(x,y,z) -> succ(z,z') ->
	  add(x',y,z')"

  axiom unique-mul :
    "all x. all y. ex z. mul(x,y,z) /\ (all z'. mul(x,y,z') -> z = z')"
  axiom mul-zero :
    "all x. all y. all z. zero(x) -> zero(z) -> mul(x,y,z)"
  axiom mul-succ :
    "all x. all y. all z. all z'.
 	    succ(x,x') ->
	    mul(x,y,z) ->
		add(y,z,z') ->
		mul(x',y,z')"
}
```

``````

``````comment

```model-checker {id=pred-sem:theories:categories}
theory Category {
  predicate identity/1
  predicate compose/3

  axiom compose-unique :
    "all f. all g. all fg1. all fg2.
	  compose(f, g, fg1) -> compose(f, g, fg2) -> fg1 = fg2"

  // Every morphism has a left and right identity

  axiom identity-left1 :
    "all g. all h. (ex f. identity(f) /\ compose(f,g,h)) -> g = h"
  axiom identity-left2 :
    "all g. all h. g = h -> (ex f. identity(f) /\ compose(f,g,h))"

  axiom assoc1 :
    "all f. all g. all h. all k.
	  (ex fg. compose(f, g, fg) /\ compose(fg, h, k)) ->
	  (ex gh. compose(f, gh, k) /\ compose(g, h, gh))"
  axiom assoc2 :
    "all f. all g. all h. all k.
	  (ex gh. compose(f, gh, k) /\ compose(g, h, gh)) ->
	  (ex fg. compose(f, g, fg) /\ compose(fg, h, k))"
}
```

``````

## The Theory of Theories {id=pred-sem:theory-of-theories}

We have now seen several theories. The theory of theories in Predicate Logic is very rich, and is one of the core areas of the modern study of logic. We have seen that by imposing different axioms, we can restrict the range of possible models to those that are “meaningful” for the application we have in mind.

In the [next topic](using-models.md) we will see some theories that describe situations of practical interest. It is also possible to use Predicate Logic to define theories for using in Mathematics, such as the [Peano Axioms for number theory](induction.md), and [Set Theory](pred-logic-rules.md#pred-logic:set-theory).

As [we will see](using-models.md), if we can define a theory and get the computer to generate models for it, then we can use this to get the computer to solve problems for us, *just by writing down what it means to be the solution*.

There are many other questions about theories that are of interest that unfortunately we do not have time to cover in this course:

1. If we have two theories given by collections of axioms, do they define the same collections of models? Or does one theory “contain” another? Or are they unrelated?

2. Which collections of models can be defined using finite sets of axioms? Perhaps surprisingly, there are collections of models that cannot be described using finite sets of axioms in Predicate Logic. One example is the set of models over the vocabulary `edge/2` and `reachable/2`, where `reachable(x,y)` is true if there is a sequence of `edge(x1,y1)` that link `x` and `y` and *nothing else*. For this kind of problem we want the *least* (i.e., with the fewest things true) model, and we might want to make sure that there is a *unique* such model. Database query languages like [Datalog](https://en.wikipedia.org/wiki/Datalog) are based on the fact that finding the least model of a collection of formulas in restricted form can be done efficiently.

3. Given a theory, we can ask whether or not it is *complete*, which is a different concept to whether or not a proof system is complete. A *theory* is complete if for any formula `P`, either `P` or `¬P` provable from the axioms of the theory. By soundness and completeness, this is equivalent to asking whether `P` holds in all models of the theory. Note that this is not the same as excluded middle -- we are asking for a *proof* of `P` or *proof* of `¬P`, not a proof of `P ∨ ¬P`.

   If a theory is complete we can write a program to solve problems in this theory for us by searching in parallel for a proof of `P` and a proof of `¬P`. Since one of these is provable, at leasy one of the searches will eventually terminate. If the theory is not inconsistent, then exactly one will terminate, telling us the whether or not `P` is a consequence of the theory.

   This gives us a way of getting a computer to reliably and precisely tell us the answers to any question we might have about a complete theory. Unfortunately, Gödel's *Incompleteness Theorem* states that any theory that includes [Peano's Axioms for the theory of addition and multiplication](induction.md) must be incomplete. This includes pretty much any theory that is strong enough to express general mathematical statements, since any such theory ought to include basic addition and multiplication. A related result is that deciding whether or not a computer program will halt on a given input is [not possible](halting-problem.md).
