# Semantics of Predicate Logic

```aside
This page assumes that you have read the [Introduction to Predicate Logic](pred-logic-intro.html). You can also read the [proof rules for predicate logic](pred-logic-rules.html) to get a feel for how the quantifiers in predicate logic work.
```

The semantics of Predicate Logic is more complex than the [semantics of Propositional Logic](prop-logic-semantics.md), due to the additional layers of terms and quantifiers.

To interpret a Predicate Logic formula, we need to upgrade the idea of a valuation (the mapping from atomic propositions to true/false values) to a [model](pred-logic-semantics.md#pred-sem:models). Models come in two parts: (1) a set of all the things in the universe; and (2) the meanings of all the predicate symbols in our vocabulary as relations on the universe. A useful intuition to think about models is as databases: each predicate symbol is interpreted as a (possibly infinite) table of related elements of the universe.

Once we have a definition of model, we can interpret Predicate Logic formulas. We do this in the same way as we did for Propositional Logic: by breaking the formula down into its constituent parts, working out their meaning and then combining the meanings together.

Armed with an interpretation of formulas, we can define entailment for Predicate Logic. As with Propositional Logic, entailment means that for all models, if all the assumptions are true then the conclusion is true. Now there are infinitely many models, and each one may itself be infinite; so checking them all is no longer feasible. This is why proof for Predicate Logic is more essential than for Propositional Logic.

The semantics of Predicate Logic shows the tight connection between Logic and Databases. We can think of the semantics of a formula as a database table representing all the values of its variables that make it true. Database queries are essentially the same thing as logical formulas.

## Vocabularies {id=pred-sem:vocabs}

When we introduced the [syntax of Predicate Logic](pred-logic-intro.md), we said that formulas are built from collections of *function symbol* and *relation symbols* that are fixed in advance. Collectively, these are called the *vocabulary* we are working in. To describe the meaning of formulas, we will have to assign meanings to be clear about which

To keep things simple on this page, we will ignore function symbols in what follows, and assume that we only have relation symbols.

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

In order to have a way to unambiguously write down vocabularies, we use the notation `relation/n`, where `n` is a number indicating the number of arguments this symbol has. We will write vocabularies as `vocab <NAME> { <relation-symbols> }`. For example, a vocabulary for humanity and mortality where `human` and `mortal` are both relation symbols that take one argument would be:
```
vocab Mortality {
  human/1
  mortal/1
}
```
A vocabulary for talking about things that are less than other things would have a predicate `lessthan` that takes two arguments:
```
vocab Ordering {
  lessthan/2
}
```
A vocabulary for talking about places including cities and countries and whether or not they are within each other would be:
```
vocab Places {
  city/1
  country/1
  within/2
}
```

Equality can be though of as a `2`-ary predicate symbol `=/2`. We will always include **equality** in our vocabularies without mentioning it, due to the way it is [treated specially](pred-logic-rules.md#pred-logic:equality) in logic.

## Models {id=pred-sem:models}

To interpret a Predicate Logic formula, we need to give a meaning to the predicate symbols in our vocabulary. This is analogous to the [valuations](prop-logic-semantics.md#prop-logic:semantics:valuations) we used in the semantics of Propositional Logic, which determined the meaning of each atomic proposition. Instead of just being True or False, we now need to say for which things it is True or False.

To even say that, we first need to say what the possible “things” are. The collection of all possible values that variables can be is called the **universe**. This collection may be finite or infinite, or even empty. (Note that some presentations of Predicate Logic do not include empty universes, but we do here.)

Then for each predicate symbol `pred/n`, we must say for which of the values of the universe it is true. Usually, any values that we do not explicitly say it is true for, we assume it is false.

For example, the `Mortality` vocabulary could have a model with three entities in the universe: `jason`, `zeus`, and `wuffles`. The `human/1` predicate contains `jason`, and the `mortal/1` predicate contains `jason` and `wuffles` (the dog). Clicking **Run** checks the given model against the vocabulary.

```model-checker {id=predsem-greekmyth-model}
vocab Mortality {
  human/1
  mortal/1
}

model GreekMyth for Mortality {
  universe = { jason, zeus, wuffles }
  human = { jason }
  mortal = { jason, wuffles }
}
```

**Exercise**. Try changing the model and clicking **Run** to see what is allowed. The **Reset** button will reset the text box to the original example.

The `Mortality` vocabulary has only `1`-ary predicates. In general, predicates have more than one argument, which we write as multiple values in parentheses. For example, in the `Ordering` vocabulary, the `lessthan/2` predicate has arity `2` so we write its elements as pairs `(x,y)`:

```model-checker {id=predsem-ordering-model}
vocab Ordering {
  lessthan/2
}

model Line for Ordering {
  universe = { low, medium, high }
  lessthan = { (low, medium), (low, high), (medium, high) }
}

model Circle for Ordering {
  universe = { north, south }
  lessthan = { (north, south), (south, north) }
}
```

The `Circle` model for `Ordering` is not necessarily what we might think of as an ordering with our intuitive idea of what `lessthan` might mean. We will discuss this further [below](pred-logic-semantics.md#pred-sem:models:sense).

It is also possible for models to be infinite, although the tool used here cannot handle this. For example, the `Ordering` vocabulary could have a universe the contains all the numbers `0, 1, 2, 3, 4, ...` with `(x,y)` in `lessthan` exactly when `x < y`.

Altogether, a **model** consists of:

1. The *universe*: a collection of all the things that are considered to exist;
2. For each predicate symbol `pred/n` a collection of `n`-tuples of elements of the universe for which `pred` is considered to be true.

### Models as Databases {id=pred-sem:models:databases}

A useful intuition to think about models is as databases: each predicate symbol is interpreted as a (possibly infinite) table of related elements of the universe. For example, the `Places` vocabulary defined above has an associated model that records the countries and some of the cities of the United Kingdom. We can think of `city`, `country`, and `within` as *tables* of data within a database. As we will see below, we will use formulas to query databases.

```model-checker {id=predsem-places-model-uk}
vocab Places {
  city/1
  country/1
  within/2
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

### Not All Models Make Sense {id=pred-sem:models:sense}

The predicate names we use in our vocabularies are just names. This means that there exist models for vocabularies that may not match our intuitions about what the names mean.

The `Circle` model for the `Ordering` vocabulary is an example of a model that doesn't match what we might mean as `lessthan` because it says that `north` is less than `south`, but also that `south` is less than `north`. Another example in the `Places` vocabulary, we may feel like we can assume that cities and countries are distinct categories and that a country is not within itself, but there is nothing stopping a model of the `Places` vocabulary from violating these properties, as the `LoopLand` model shows:

```model-checker {id=predsem-places-model-}
vocab Places {
  city/1
  country/1
  within/2
}

model LoopLand for Places {
  universe = { loopland }
  city = { loopland }
  country = { loopland }
  within = { (loopland, loopland) }
}
```

To distinguish “good” models from “bad” models, we need a language to talk about them. This language is [Predicate Logic](pred-logic-intro.md).

## Interpretation of Formulas {id=pred-sem:interp}

To interpret a formula we fix a vocabulary `V` and a model `M` for that vocabulary. The formulas we interpret must be written using the vocabulary `V`. Once we have our model `M`, we can interpret Predicate Logic formulas in that model.

We do this using the same strategy we used for [Propositional Logic](prop-logic-semantics.md): breaking the formula down into its constituent parts, working out their meaning and then combining the meanings together. The subtlety in interpreting Predicate Logic formulas is that the collection of free variables varies across different subformulas within the same formula.

### Meaning of free variables {id=pred-sem:interp:freevars}

Formulas can have free variables that are not quantified, as we saw when asking [when two formulas are the same](pred-logic-intro.md#pred-logic:alpha-equiv). For example, the formula
```formula
city(x) /\ within(x,y)
```
has two free variables, `x` and `y`. Even if we have a model that tells us when `city` and `within` are true, We can't give this formula a truth value until we know what `x` and `y` mean. Our fixed model `M` tells us what *possible* values `x` and `y` have, and what the truth value of `city` and `within` are for those values. The meaning of the formula varies according the exact values we choose for `x` and `y`.

For example, the `UnitedKingdom` model sets a particular universe. If we set `x` to be `glasgow` and `y` to be `scotland` from that universe, then the formula `city(x) /\ within(x,y) = city(glasgow) /\ within(glasgow,scotland)`, which is true in the model. But if we set `x` to be `scotland` and `y` to be `edinburgh`, then the formula ought to be assigned the value `F`, because neither of `city(scotland)` or `within(scotland,edinburgh)` are true.

In general, for a formula `P` with free variables `x1, x2, ..., xn` we need an assignment `v` of elements of the universe to each `xi`. This is similar to the idea of [valuations](prop-logic-semantics.md#prop-logic:semantics:valuations) in Propositional Logic, except that we are assigning elements of the universe of the model to variables instead of truth values to atomic propositions.

If `v` is a valuation, we write `v(x)` for the value assigned to `x`. For example, if `v = [ x ↦ glasgow, y ↦ scotland ]`, then `v(x) = glasgow`.

### Interpreting Formulas {id=pred-sem:interp:formulas}

Given a formula `P` with a valuation `v` that assigns elements of the universe to `P`s free variables, we can work out the meaning `P` by breaking it down into its component parts, working out the truth values of them and then combining the truth values.

Remember that we are fixing a vocabulary `V` and model `M`.

The two basic formulas are:
1. Uses of predicate symbols `R(x1,...,xn)`. In this formula, the variables `x1`,...,`xn` are free, so we have an `n`-tuple `(v(x1), ..., v(xn))`. If this tuple is in the interpretation of the symbol `R` in the model, then the formula `R(x1,...,xn)` is true. Otherwise it is false.

2. Equalities `x = y`. In this formula, the variables `x` and `y` are free. The formula is true if `v(x)` is actually equal to `v(y)` and false otherwise.

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


The quantifiers are where we extend the assignment `v` to cover the additional variables in the body of the formula. We write `v[x ↦ a]` for the assignment `v` extended to also assign `a` to `x`.

The quantifiers are interpreted by checking the truth values of the subformulas for all elements of the universe. The quantifiers differ in whether the subformula is true for all elements, or for some element:

1. If the formula is `∀x. P` for the assignment `v`, then it is true if `P` is true for the assignment `v[x ↦ a]` **for all** values `a` in the universe. Otherwise, it is false.
2. If the formula is `∃x. P` for the assignment `v`, then it is true if `P` is true for the assignment `v[x ↦ a]` **for some** value `a` in the universe. Otherwise, it is false.

In symbols, using the double bracket notation:
```
〚∀x. P〛v = T   if for all 'a' in the universe, 〚P〛(v[x ↦ a]) = T
         = F    otherwise

〚∃x. P〛v = T   if for some 'a' in the universe, 〚P〛(v[x ↦ a]) = T
         = F    otherwise
```

These definitions may seem pointless, but the key point is that the variables *only take values from the universe*. As far as the interpretations of formulas in a particular model is concerned, it is only the values in the universe that matter.

- **Example**. In the `UnitedKingdom` model, we have `〚∀x. city(x)〛v = F`, because it is not the case that *for all* possible values of `x` that `city(x)` is true (it is not for `x = scotland`). On the other hand, `〚∃x. city(x)〛v = T`, because there exists at least one city in this model.

The propositional connectives are the same as they were for Propositional Logic:
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
  2. But if `v` is `[ x ↦ edinburgh, y ↦ birmingham ]`, then:
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
Is valued as True in the `UnitedKingdom` model, but as False in the `LoopLand` model. Whether or not a closed formula is true in a model is a useful property, so we use the notation
```
    M ⊧ P
```
to indicate when a formula `P` is true in a model `M`. We write `M ⊭ P` when `P` is not true in `M`.

So we have `UnitedKingdom ⊧ ∀x. ¬(city(x) ∧ country(x))` and `LoopLand ⊭ ∀x. ¬(city(x) ∧ country(x))`.

- **Exercise**. Compute the truth value of the formula
  ```formula
  ex x. city(x) /\ country(x) /\ within(x,x)
  ```
  in the `UnitedKingdom` model, and in the `LoopLand` model.

- **Exercise**. Compute the truth value of the formula
  ```formula
  all x. city(x) -> (ex y. ex c. city(y) /\ within(x,c) /\ within(y,c) /\ ¬x=y)
  ```
  in the `UnitedKingdom` model, and in the `LoopLand` model.


### Entailment {id=pred-sem:interp:entailment}

Remember that we defined **entailment** in [Propostiional Logic](entailment.md) as a relation between a collection of assumptions and a conclusion:
```
   P1, ..., Pn ⊧ Q
```
This relation “holds” or “is valid” if for all valuations, if all the assumptions are true, then the conclusion is true.

For Predicate Logic, we use the same idea, except that instead of valuations, we use models.

**Definition** (Entailment). When `P1`, ..., `Pn`, and `Q` are Predicate Logic formulas in some vocabulary `V`, we say that the entailment `P1, ..., Pn ⊧ Q` holds if *for all models* `M`, if for all `i`, `M ⊧ Pi`, then `M ⊧ Q`.

Checking entailment for Propositional Logic is possible by checking every possible valuation, though to do this naively would take `2^n` steps to check every valuation. Checking entailment for Predicate Logic is not possible by this simple enumeration technique because there are infinitely many possible models (e.g., all models with size 0, all models with size 1, size 2, ..., and infinite models), and individual models may themselves be infinite. This is why using proof is essential.

### Soundness and Completeness {id=pred-sem:interp:sound-complete}

We now have two definitions that describe when a conclusion follows from some assumptions. In the [proof rules for Predicate Logic](pred-logic-rules.md), we developed a system for proving judgements of the form:
```
   P1, ..., Pn ⊢ Q
```
that say that `Q` is provable from the assumptions `P1`, ..., `Pn`.

Using models and interpretations, we have another definition of *semantic entailment*, [defined above](pred-logic-semantics.md#pred-sem:interp:entailment):
```
   P1, ..., Pn ⊧ Q
```

As with [Propositional Logic](natural-deduction-intro.md#natural-deduction:sound-complete), these two definitions are linked by the properties of **soundness** and **completeness**:

1. The proof system is **sound** for this semantics, meaning that if a judgement `P1, ..., Pn ⊢ Q` is provable, then the entailment `P1, ..., Pn ⊧ Q` is valid.

   This property is relatively easy to prove by checking that all of the proof rules preserve valid entailments: for each rule, if the premises are valid entailments, then so is the conclusion. The `done`, `true`, and `refl` rules have no premises, so they get us started.

   Note that this is quite remarkable. Entailment is quite a complex property that involves quantification over *all* models, and then *all* elements of those models, but proofs are things that can be finitely checked.

   A very useful consequence of soundness is that we can use it to [show that some formulas are *not* provable](pred-logic-semantics.md#pred-sem:using:proof-counter).

2. If we add excluded middle to the proof system, then it is also **complete**. This means that if an entailment `P1, ..., Pn ⊧ Q` is valid, then the judgement `P1, ..., Pn ⊢ Q` is provable.

   This property is much harder to prove that soundness. It was original proved by Kurt Gödel and is often called “Gödel's Completeness Theorem”. The proof works by constructing a special model from the vocabulary, and completing it under the assumptions.

The proof system without excluded middle *is* complete for a more sophisticated semantics where truth is computed relative to a possible world from a collection of all possible worlds that represent stages of knowledge. The Stanford Encyclopedia of Philosophy has a section on [Semantics of Intuitionistic Logic](https://plato.stanford.edu/entries/logic-intuitionistic/#BasiSema).

## Using Models {id=pred-sem:using}

One reason to study the semantics of Predicate Logic is to give us some faith that the proof system we have been using actually means something. Another reason is that it gives us another view of logical formulas that is very useful for many purposes.

### Computing the Interpretation of Formulas {id=pred-sem:using:computing}

If we have a fixed model `M`, then the first thing we can do is to ask what formulas `P` are true in this model. By doing this, we learn facts about this model. If the model has been constructed from data (see below), then the `P` that are true for it are things that are supported by the data.

The tool embedded in this page can compute whether or not a formula is true in *finite* models. For example, the `GreekMyth` model for the `Mortality` vocabularity supports one of the formulas shown below, but not the other. If you click **Run**, then the output will confirm that the first formula is supported by the model (“Verified”) but the second is not, and a counter example is produced.

```model-checker {id=predsem-computing-greek}
vocab Mortality {
  human/1
  mortal/1
}

model GreekMyth for Mortality {
  universe = { jason, zeus, wuffles }
  human = { jason }
  mortal = { jason, wuffles }
}

check GreekMyth |= "all x. human(x) -> mortal(x)"

check GreekMyth |= "all x. mortal(x) -> human(x)"
```

**Exercise**. Modify the `GreekMyth` model to make both formulas true. What are all the possible ways to modify the model without changing the universe?

```details
Solution

To make both formulas true, you need to make the elements of `human` and `mortal` the same. So the easiest things to do are to add `wuffles` to `human`, or to remove `wuffles` from `mortal`.
```

The next example uses the `UnitedKingdom` model for the `Places` vocabulary. There are five formulas at the end, four of which are supported by the model. Click **Run** to see which.

```model-checker {id=predsem-computing-unitedkingdom}
vocab Places {
  city/1
  country/1
  within/2
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

check UnitedKingdom |= "ex x. country(x)"

check UnitedKingdom |= "ex x. city(x)"

check UnitedKingdom |= "all x. city(x) -> (ex y. country(y) /\ within(x,y))"

check UnitedKingdom |= "ex x. city(x) /\ country(x)"

check UnitedKingdom |= "all x. ¬(city(x) /\ country(x))"
```

**Exercise**. Is it possible to get all of these formulas to be true by changing the model?

````details
Solution

No. The final two formulas contradict each other. The second-to-last formula states that there exists something that is both a city and a country, while the last formula says that everything is not both a city and a country. It is not possible to satisfy both of these simultaneously.

To see this, we can rely on the soundness of our proof system. Assuming these two formulas allows us to prove `F`. Since no models make `F` true, there can be no models that support these two formulas simultaneously.
```focused-nd {id=predsem-computing-contra}
(config
 (assumptions
  (exists-city-and-country "ex x. city(x) /\ country(x)")
  (never-both-city-and-country "all x. ¬(city(x) /\ country(x))"))
 (goal "F")
 (solution (Rule(Use exists-city-and-country)((Rule(ExElim x H)((Rule(Use never-both-city-and-country)((Rule(Instantiate(Var x))((Rule NotElim((Rule(Use H)((Rule Close())))))))))))))))
```
````

### Models and Databases {id=pred-sem:using:databases}

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

### Generating Models {id=pred-sem:using:generating}

Given a collection of formulas `P1`, ..., `Pn`, it can be useful to generate a model `M` of them. Sometimes it is easier to think about concrete situations rather than abstract properties. Such models can also be used as counterexamples to show that [certain formulas are unprovable](pred-logic-semantics.md#pred-sem:using:proof-counter). Finally, it is also possible to use model generation, often combined with some randomness, as a kind of logically guided generative AI.

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

```model-checker {id=pred-sem-generating-places}
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

```model-checker {id=pred-sem-generating-order}
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

### Proof and Counterexamples {id=pred-sem:using:proof-counter}

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
This is because the model we [constructed above](pred-logic-semantics.md#pred-sem:using:generating) supports the three listed formulas, but not `¬ (∃ x. country(x))` (because there exists a `country` in the model). Therefore, the argument we just made shows that it is not possible to prove this formula.
