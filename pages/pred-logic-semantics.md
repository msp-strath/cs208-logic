# Semantics of Predicate Logic

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

### Only Equality

```model-checker
vocab EmptyVocab {}

axioms AllEqual for EmptyVocab {
  all-equal: "all x. x = x"
}

axioms NothingEqual for EmptyVocab {
  nothing-equal: "all x. x != x"
}

axioms ExistsSomething for EmptyVocab {
  exists-something: "ex x. T"
}

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

synth ExistAtMostTwoThings size 3
```

### Unary Predicates

```model-checker
vocab UnaryVocab {

}
```

### Relations
