# Topic 9 : Using Models

```aside
This page assumes that you have read the [Introduction to Predicate Logic](pred-logic-intro.html) and about the [Semantics of Predicate Logic](pred-logc-semantics.html). You can also read the [proof rules for predicate logic](pred-logic-rules.html) to get a feel for how the quantifiers in predicate logic work.
```

One reason to study the semantics of Predicate Logic is to give us some faith that the proof system we have been using actually means something. Another reason is that it gives us another view of logical formulas that is very useful for many purposes.

## Models and Databases {id=using-models:databases}

The *Relational Model* for databases was introduced by Edgar F. Codd in the paper [*A relational model of data for large shared data banks*](https://dl.acm.org/doi/10.1145/362384.362685), originally written in 1969. You will learn more about the Relational Model in the second half of CS209.

The core idea of the Relational Model is that databases are comprised of *relations* between values. A database that stores banking information could relate account holders to their names and addresses, and also relate account holders to their accounts, and each account to its transactions. The key innovation of the relational model is that these relations are unbiased, unlike the “navigational” or “hierarchical” models that predated it, which allow referencing of transtions *from* accounts, but not (easily) the reverse. This lack of bias makes the relational model very flexible in the face of changing data access requirements.

The connection to Predicate Logic arises from the fact that there is a tight connection between logical concepts and parts of the relational model:

| Logical Concept | Database Concept |
|-----------------|------------------|
| Vocabulary      | Schema           |
| Predicate       | (finite) Tables  |
| Formulas        | Queries          |
| Models          | Databases        |

**Example**. The Structured Query Language (SQL) is the most common language for writing queries on relational databases. A simple SQL query is:
```
SELECT City.X
FROM City, Within
WHERE City.X = Within.X AND Within.Y = "scotland"
```
This query will return all the cities in Scotland in the database. This query is equivalent to asking *“what values of `x` make the following formula true in a model?”*
```formula
ex y. city(x) /\ within(y,z) /\ x = y /\ z = scotland()
```
or, more simply:
```formula
within(x,scotland()) /\ city(x)
```

### Generating Models {id=using-models:generating}

Given a collection of formulas `P1`, ..., `Pn`, it can be useful to generate a model `M` of them. Sometimes it is easier to think about concrete situations rather than abstract properties. Such models can also be used as counterexamples to show that [certain formulas are unprovable](using-models.md#using-models:proof-counter). Finally, it is also possible to use model generation, often combined with some randomness, as a kind of logically guided generative AI.

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

### Proof and Counterexamples {id=using-models:proof-counter}

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
