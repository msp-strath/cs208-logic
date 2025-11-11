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

Try changing the model and clicking **Run** to see what is allowed. The **Reset** button will reset the text box to the original example.

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

A useful intuition to think about models is as databases: each predicate symbol is interpreted as a (possibly infinite) table of related elements of the universe. For example, the `Places` vocabulary defined above has an associated model that records the countries and some of the cities of the United Kingdom. We can think of `city`, `country`, and `within` as *tables* of data within a database. As we will see below,

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
  universe = { loopville, loopland }
  city = { loopville, loopland }
  country = { loopville, loopland }
  within = { (loopland, loopland) }
}
```

To distinguish “good” models from “bad” models, we need a language to talk about them. This language is [Predicate Logic](pred-logic-intro.md).

## Interpretation of Formulas {id=pred-sem:interp}

Once we have a definition of model, we can interpret Predicate Logic formulas. We do this in the same way as we did for [Propositional Logic](prop-logic-semantics.md): by breaking the formula down into its constituent parts, working out their meaning and then combining the meanings together.

### Meaning of free variables {id=pred-sem:interp:freevars}

To interpret a formula we fix a vocabulary `V` and a model `M` for that vocabulary. The formulas we interpret must be written using the vocabulary `V`.

Formulas can have free variables that are not quantified, as we saw when asking [when two formulas are the same](pred-logic-intro.md#pred-logic:alpha-equiv). For example, the formula
```formula
city(x) /\ within(x,y)
```
has two free variables, `x` and `y`. We can't give this formula a truth value until we know what `x` and `y` mean. Our fixed model `M` tells us what *possible* values `x` and `y` have, and what the truth value of `city` and `within` are for those values. The meaning of the formula varies according the exact values we choose for `x` and `y`.

For example, the `UnitedKingdom` model sets a particular universe. If we set `x` to be `glasgow` and `y` to be `scotland`, then the formula `city(x) /\ within(x,y) = city(glasgow) /\ within(glasgow,scotland)`, which is true in the model. But if we set `x` to be `scotland` and `y` to be `edinburgh`, then the formula ought to be assigned the value `F`, because neither of `city(scotland)` or `within(scotland,edinburgh)` are true.

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

**Example**. In the `UnitedKingdom` model, we have:
```
〚within(x,y)〛([ x ↦ glasgow, y ↦ scotland ]) = T
```
and
```
〚within(x,y)〛([ x ↦ glasgow, y ↦ wales ]) = F
```



The quantifiers are where we extend the assignment `v` to cover the additional variables in the body of the formula. We write `v[x ↦ a]` for the assignment `v` extended to also assign `a` to `x`.

The quantifiers are interpreted as “for all” and “exists” as one might expect:

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

**Example**. In the `UnitedKingdom` model, we have `〚∀x. city(x)〛v = F`, because it is not the case that *for all* possible values of `x` that `city(x)` is true (it is not for `x = scotland`). On the other hand, `〚∃x. city(x)〛v = T`, because there exists at least one city in this model.

If the model is finite, then working out

The propositional connectives are the same as they were for Propositional Logic:
```
 〚 P ∧ Q 〛v = 〚 P 〛v ∧ 〚 Q 〛v
 〚 P ∨ Q 〛v = 〚 P 〛v ∨ 〚 Q 〛v
 〚 ¬ P 〛v   = ¬ 〚 P 〛v
 〚 P → Q 〛v = 〚 P 〛v → 〚 Q 〛v
```

**Examples**.
1.

### Computing the Interpretation of Formulas {id=pred-sem:interp:computing}

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


### Entailment {id=pred-sem:interp:entailment}

With an interpretation of formulas, we can define *satisfiability*, *validity*, and *entailment* for Predicate Logic.

These are essentially the same as for Propositional Logic, except that now we quantify over all *models*.

FIXME: spell out the definitions.

As with Propositional Logic, [entailment](entailment.md) means that for all models, if all the assumptions are true then the conclusion is true. Now there are infinitely many models, and each model may itself be infinite; so checking them all is no longer feasible. This is why proof for Predicate Logic is more essential than for Propositional Logic.

FIXME: some examples and a quiz.

### Proof and Counterexamples {id=pred-sem:interp:proof-counter}

Proof is a way to show that a formula is true in all models. But what if we want to show that a formula is *not* provable? It is not enough to simply fail to prove it, because it may be the case that a proof exists and we are just not perceptive enough to find it.

One way to show that a formula `P` is not provable, assuming the proof system is sound. is to find a model that makes its negation `¬P` true. This is due to the following reasoning:

1. If it were the case that `P` was provable, then it would be true in every model.
2. If `¬P` is true in some model `M`, then it cannot be the case that `P` is true in `M` (because then `¬P` would be false).
3. So `P` is false in `M`, contradicting the assertion that `P` is true in every model, so `P` cannot be provable.

FIXME: do an example

## Logic for Databases {id=pred-sem:databases}

FIXME: If models are databases, then queries are formulas with free variables. The result of a query is the collection of all possible values of the free variables that make the formula true.
