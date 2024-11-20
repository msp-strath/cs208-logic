# Semantics of Predicate Logic

```aside
This page assumes that you have read the [Introduction to Predicate Logic](pred-logic-intro.html). You can also read the [proof rules for predicate logic](pred-logic-rules.html) to get a feel for how the quantifiers in predicate logic work.
```

Now that we have seen the proof rules for Predicate Logic, we turn to its semantics. The semantics of Predicate Logic is more complex than the semantics of Propositional Logic that we saw in [Week 1](prop-logic-semantics.html).

This page contains two videos introducing the semantics of Predicate Logic, and then an interactive tool that you can use to explore some (finite) models of Predicate Logic formulas.

[Slides for the videos below](week08-slides.pdf)

## Models

To interpret a Predicate Logic formula, we need to upgrade the idea of a valuation (the mapping from atomic propositions to true/false values) to a *model*. Models come in two parts:

1. a collection of all the things that are considered to be in the universe for this model; and
2. the meanings of all the predicate symbols in our vocabulary as relations on the universe.

A useful intuition to think about models is as databases: each predicate symbol is interpreted as a (possibly infinite) table of related elements of the universe.

Models are explained in this video:

```youtube
oxUbCksb-aw
```

```textbox {id=pred-semantics-note1}
Enter any notes to yourself here.
```

## Interpretation of Formulas

Once we have a definition of model, we can interpret Predicate Logic formulas. We do this in the same way as we did for Propositional Logic: by breaking the formula down into its constituent parts, working out their meaning and then combining the meanings together.

Armed with an interpretation of formulas, we can define *entailment* for Predicate Logic. As with Propositional Logic, entailment means that for all models, if all the assumptions are true then the conclusion is true. Now there are infinitely many models, and each model may itself be infinite; so checking them all is no longer feasible. This is why proof for Predicate Logic is more essential than for Propositional Logic.

The interpretation of Predicate Logic formulas in a model, and the definition of entailment in predicate logic, are discussed in this video:

```youtube
NivY9vERSmA
```

```textbox {id=pred-semantics-note2}
Enter any notes to yourself here.
```

## Examples

The following examples all use a tool that can synthesise models of a fixed size for a set of axioms. Click **Run** on each one to see what gets synthesised.

### No axioms

With no axioms and no predicate symbols, there are no constraints on the model. We can have models of any size and there are no predicate symbols to give meaning to.

```model-checker {id=predsem-noaxioms}
vocab EmptyVocab { }

axioms EmptyAxioms for EmptyVocab { }

// This will work for any size
synth EmptyAxioms size 3
```

### Something exists

Even with no predicate symbols, we can still say that something exists

```model-checker {id=presdsem-exists}
vocab EmptyVocab { }

axioms ExistsSomething for EmptyVocab {
  exists-something: "ex x. T"
}

// This won't work when the size is 0
synth ExistsSomething size 1
```

**Exercise** What happens if you say “nothing exists”?

### Only Equality

Even with no predicate symbols in the vocabulary, we can still say some interesting things using just equality.

#### Everything is equal

If we say that everything is equal to everything, then there can only be at most one thing in the model:

```model-checker {id=predsem-allequal}
vocab EmptyVocab { }

axioms AllEqual for EmptyVocab {
  all-equal: "all x. all y. x = y"
}

synth AllEqual size 1
```

**Exercise** What sizes of model support the `all-equal` axiom?

#### Everything is unequal

```model-checker {id=presem-allunequal}
vocab EmptyVocab { }

axioms NothingEqual for EmptyVocab {
  nothing-equal: "all x. x != x"
}

axioms NothingEqualAndThing for EmptyVocab {
  nothing-equal: "all x. x != x",
  something-exists: "ex x. T"
}

// This only has models of size 0
synth NothingEqual size 0

// This has *no* models
synth NothingEqualAndThing size 3
```

With this tool we can only check that individual sizes of model do not exist. To prove that there are *no* models (even infinite ones), we can do a proof that these axioms entail “false” (to do this proof you will need the `refl` command from [the proof rules for equality](equality.html)).

```focused-nd {id=predsem-allunequal-contra}
(config
 (assumptions
  (nothing-equal "all x. ¬(x = x)")
  (something-exists "ex x. T"))
 (goal "F"))
```

#### How to say that two things exist?

Below are several attempts to say that two things exist. Experiment with synthesising models for these axioms to learn exactly what they are expressing.

```model-checker {id=presem-allunequal-proof}
vocab EmptyVocab { }

axioms ExistsTwoThingsBroken for EmptyVocab {
  exists-two-things: "ex x. ex y. T"
}

axioms ExistsTwoThings for EmptyVocab {
  exists-two-separate-things: "ex x. ex y. x != y"
}

axioms ExistAtMostTwoThings for EmptyVocab {
  exists-at-most-two-things:
     "ex x. ex y. all z. x = z \/ y = z"
}

axioms ExistsExactlyTwoThings for EmptyVocab {
  exists-exactly-two-things:
     "ex x. ex y. x != y /\ (all z. x = z \/ y = z)"
}

// What sizes does this work for?
synth ExistsTwoThingsBroken size 2

// What sizes does this work for?
synth ExistsTwoThings size 2

// What sizes does this work for?
synth ExistAtMostTwoThings size 2

// What sizes does this work for?
synth ExistsExactlyTwoThings size 2
```

### Unary Predicates

With unary predicates, we can talk about “types” of things and the relationships between them. The following example uses “humans” and “mortals”, and the relationship that all humans are mortal:

```model-checker {id=predsem-humansandmortals}
vocab HumansAndMortals {
  human/1,
  mortal/1
}

axioms HM1 for HumansAndMortals {
  all-humans-are-mortal: "all x. human(x) -> mortal(x)"
}

axioms HM2 for HumansAndMortals {
  all-humans-are-mortal: "all x. human(x) -> mortal(x)",
  exists-a-human: "ex x. human(x)"
}

// There are no models of this
axioms HM3 for HumansAndMortals {
  all-humans-are-mortal: "all x. human(x) -> mortal(x)",
  exists-immortal-humman: "ex x. human(x) /\ ¬mortal(x)"
}

synth HM1 size 3
synth HM2 size 3
synth HM3 size 3
```

As above, we can check that `HM3` has no models for each size `0`, `1`, `2`, `3`, ..., but to prove that there are no models of these axioms (i.e., these axioms are inconsistent), we have to do a proof that assuming both of these axioms entails “false”:

```focused-nd {id=predsem-unary-contra}
(config
 (assumptions
  (all-humans-are-mortal "all x. human(x) -> mortal(x)")
  (exists-immortal-human "ex x. human(x) /\ ¬mortal(x)"))
 (goal F))
```

**Exercise** How would you say that there exists a mortal that is not human? Is adding this axiom to `HM2` consistent?

### Relations

Relations are predicates that have two or more arguments. They are used to express relationships between things.

#### Less than

“Less than” is a relationship between two things that is characterised by being *transitive* and *irreflexive*. Transitive means that if `x` is less than `y` and `y` is less than `z`, then `x` is less than `z`. Irreflexive means that nothing is less than itself.

```model-checker {id=predsem-lessthan}
vocab LessThan {
  lt/2
}

axioms LessThanAx for LessThan {
  transitive:
    "all x. all y. all z. lt(x,y) -> lt(y,z) -> lt(x,z)",
  irreflexive: "all x. ¬lt(x,x)"
}

synth LessThanAx size 4

// If we also add the axiom that everything
// has something it is less than, then there
// are no finite models
axioms LessThanInfAx for LessThan {
  transitive:
    "all x. all y. all z. lt(x,y) -> lt(y,z) -> lt(x,z)",
  irreflexive: "all x. ¬lt(x,x)",
  infinite: "all x. ex y. lt(x,y)"
}

// There are no finite models of these axioms
synth LessThanInfAx size 4
```

The `infinite` axiom here, when coupled with the `irreflexive` axiom, is an example of an axiom that forces all models to be infinite. Unlike the examples above where there were no finite or infinite models, these do have infinite models, so it is not possible to prove “false” from these axioms.

**Exercise** What happens if you comment out the `irreflexive` axiom? Are there finite models then?

#### Less than or equal

“Less than or equal” is axiomatised by *reflexivity*, *transitivity* and *antisymmetry**. Transitivity is the same as for “less than”. Reflexivity says that everything is “less than or equal” to itself. Anti-symmetry says that if `x` is less than or equal to `y` and `y` is less than or equal to `x`, then they are equal.

```model-checker {id=predsem-leq}
vocab LEQ {
  le/2
}

axioms LEQAx for LEQ {
  reflexivity:
    "all x. le(x,x)",
  transitivity:
    "all x. all y. all z. le(x,y) -> le(y,z) -> le(x,z)",
  antisymmetry:
    "all x. all y. le(x,y) -> le(y,x) -> x = y"
}

synth LEQAx size 5
```

**Exercise** Can you add an axiom that makes the `le` relation minimal (so it only relates things to themselves)?

**Exercise** This axiomatisation of “less than or equal” generates *forests*. How can you make it generate models where everything is in a line?

### Checking models

As well as synthesising models, we can get the computer to check them.

### Going further

We have only scratched the surface of the kinds of things that can be expressed using Predicate Logic, and what kinds of models can be captured using axiomatisations. Try using the model synthesiser tool below to try different vocabularies and axiomisations and generate models for them:

```model-checker {id=predsem-custom}
vocab V {
   // what predicate symbols are in the vocabulary?
}

axioms A for V {
   // what axioms do they satisfy?
}

// synthesise models of them
synth A size 4
```
