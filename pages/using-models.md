# Topic 9 : Using Models

```aside
This page assumes that you have read the [Introduction to Predicate Logic](pred-logic-intro.html) and about the [Semantics of Predicate Logic](pred-logc-semantics.html). You can also read the [proof rules for predicate logic](pred-logic-rules.html) to get a feel for how the quantifiers in predicate logic work.
```

**DRAFT**

One reason to study the semantics of Predicate Logic is to give us some faith that the proof system we have been using actually means something. Another reason is that it gives us another view of logical formulas that is very useful for many purposes.

Given a collection of formulas `P1`, ..., `Pn`, it can be useful to build a model `M` of them. There are several uses:

1. Building a model of a collection of formulas helps us check to see whether or not the formulas make sense. If we are able to build a model of some axioms that does not match our intuition, then perhaps we have made a mistake in our axioms? Or maybe we have learnt an unexpected fact about our axioms?

2. Building a model that satisfies a collection of axioms but also falsifies another formula is a way of showing that there is no way of proving that formula from the axioms. We will look at this to show that [certain formulas are unprovable](using-models.md#using-models:proof-counter).

3. If we specify some axioms and *part of* a model, we can get the computer to complete the rest of the model for us such that the axioms are validated. This gives a way of solving problems not by explicitly programming a way of solving them, but instead by stating what it is we want solved and getting the computer to do it for us. We will look at several examples below, including [package installations](using-models.md#using-models:packages) and [resource allocation](using-models.md#using-models:resource-alloc).

## Building Models {id=using-models:generating}

Generating small models from collections of formulas is a useful skill for checking that such formulas make sense together, so let's step through an example using the `Places` vocabulary with the following three formulas:

1. ```formula
   ex x. ex y. city(x) /\ city(y) /\ ¬x = y
   ```
2. ```formula
   all x. city(x) -> (ex y. country(y) /\ within(x,y))
   ```
3. ```formula
   all x. ¬(city(x) /\ country(x))
   ```

To construct a model for these formulas, we work through them in turn:

1. We first try the empty model:
   ```
   model M0 for Places {
     universe = { }
	 city = { }
	 country = { }
	 within = { }
   }
   ```
   But this does not satisfy the first formula, although it does satisfy the second and third.
2. The first formula states that at least two cities exist, so we have to add them to the model:

   ```
   model M1 for Places {
     universe = { plockton, auchtermuchty }
	 city = { plockton, auchtermuchty }
	 country = { }
	 within = { }
   }
   ```
3. The model `M1` satisfies the first formula, but not the second, which states that every city is within a country. We can make this formula satisfied by resuing an element of our universe as a country:
   ```
   model M2 for Places {
     universe = { plockton, auchtermuchty }
	 city = { plockton, auchtermuchty }
	 country = { plockton }
	 within = { (auchtermuchty, plockton), (plockton, plockton) }
   }
   ```
4. The model `M2` satisfies the first two formulas, but not the third. The formula states that nothing is both a city and a country, but the model has `plockton` as both. We fix this by introducing a third entity into the universe that is a country, and alter the `within` relation to keep the second formula true:
   ```
   model M3 for Places {
     universe = { plockton, auchtermuchty, scotland }
	 city = { plockton, auchtermuchty }
	 country = { scotland }
	 within = { (auchtermuchty, plockton), (plockton, plockton),
	            (auchtermuchty, scotland), (plockton, scotland) }
   }
   ```
   This model makes all of the formulas true.
5. Finally, we can reduce the size of the model by removing the extra tuples in `within` that are not needed:
   ```
   model M4 for Places {
     universe = { plockton, auchtermuchty, scotland }
	 city = { plockton, auchtermuchty }
	 country = { scotland }
	 within = { (auchtermuchty, scotland), (plockton, scotland) }
   }
   ```

You can test each of these models by typing them into the box below. Edit the `model M { ... }` part to change what exists and what is true. Clicking **Run** will tell you which of the formulas is verified by the model.

```model-checker {id=using-models-generating-places}
vocab Places {
  city/1
  country/1
  within/2
}

model M for Places {
  universe = { }
  city = { }
  country = { }
  within = { }
}

check M |= "ex x. ex y. city(x) /\ city(y) /\ ¬x = y"

check M |= "all x. city(x) -> (ex y. country(y) /\ within(x,y))"

check M |= "all x. ¬(city(x) /\ country(x))"
```

The three formulas listed above have finite models, but not all collections of formulas have finite models. An example is given in the box below, using the `Ordering` vocabulary. The first formula says that at least one thing exists. The second says that the `lessthan` relation “stacks”: if `x < y` and `y < z` then `x < z`. The third says that nothing is less than itself. The fourth says that everything has something greater than it.

The effect of these formulas on the model is:
1. The model cannot be empty.
2. Chains of `lessthan` can be combined
3. ... and circles are not allowed
4. ... and chains go on forever.

*Combined*, these formulas prevent any model from being empty or finite.

```model-checker {id=using-models-generating-order}
vocab Ordering {
  lessthan/2
}

model M for Ordering {
  universe = { }
  lessthan = { }
}

// Something exists
check M |= "ex x. T"

// Transitivity
check M |= "all x. all y. all z. lessthan(x,y) -> lessthan(y,z) -> lessthan(x,z)"

// Irreflexive: nothing is less than itself
check M |= "all x. ¬lessthan(x,x)"

// No maximum: everything has something greater than it
check M |= "all x. ex y. lessthan(x,y)"
```

**Exercise**. Convince yourself that there are no finite models that make all of these formulas true simultaneously. For each three of four of the formulas, write a model that satisfies those formulas.

## (Un)Proof and Counterexamples {id=using-models:proof-counter}

Proof is a way to show that a formula is true in all models. Conversely, we can use models to show that certain formulas are not provable. To do this, it is not enough to simply fail to prove the formula, because it may be the case that a proof exists and we just did not work hard enough to find it.

We can use the soundness of the proof system to show that a certain judgement `P1, ..., Pn ⊢ Q` is **not** provable as follows:

1. Find a model `Mᶜ` that makes all of the `P1`, ..., `Pn` true (meaning `Mᶜ ⊧ Pi`, for all `i`), but does *not* make `Q` true (so `Mᶜ ⊭ Q`).
2. *If* we could prove `P1, ..., Pn ⊧ Q` then, by soundness, for every model `M` if `M ⊧ P1`, ..., and `M ⊧ Pn` then `M ⊧ Q`.
3. We have a model `Mᶜ` that supports `P1`, ..., `Pn`, so if the judgement is provable, we would have `Mᶜ ⊧ Q`.
4. It is contradictory to have both `Mᶜ ⊧ Q` and `Mᶜ ⊭ Q`, so it must be the case that `P1, ..., Pn ⊧ Q` is not provable.

**Example**. It is not possible to prove the formula
```formula
¬ (ex x. country(x))
```
from the assumptions
1. ```formula
   ex x. ex y. city(x) ∧ city(y) ∧ ¬x = y
   ```
2. ```formula
   all x. city(x) -> (ex y. country(y) ∧ within(x,y))
   ```
3. ```formula
   all x. ¬(city(x) ∧ country(x))
   ```
This is because the model we [constructed above](using-models.md#using-models:generating) supports the three listed formulas, but not `¬ (∃ x. country(x))` (because there exists a `country` in the model). Therefore, the argument we just made shows that it is not possible to prove this formula.

**Exercise**: FIXME

## Package Installations {id=using-models:packages}

**FIXME**

## Resource Allocation {id=using-models:resource-alloc}

**FIXME**
