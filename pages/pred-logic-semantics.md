# Semantics of Predicate Logic

Now that we have seen the proof rules for Predicate Logic, we turn to the semantics of Predicate Logic.

The semantics of Predicate Logic is a little more complex than the semantics of Propositional Logic that we saw in Week 1. To interpret a Predicate Logic formula, we need to upgrade the idea of a valuation (the mapping from atomic propositions to true/false values) to a *model*. Models come in two parts:

1. a collection of all the things that are considered to be in the universe for this model; and
2. the meanings of all the predicate symbols in our vocabulary as relations on the universe.

A useful intuition to think about models is as databases: each predicate symbol is interpreted as a (possibly infinite) table of related elements of the universe.</p>

Once we have a definition of model, we can interpret Predicate Logic formulas. We do this in the same way as we did for Propositional Logic: by breaking the formula down into its constituent parts, working out their meaning and then combining the meanings together.

Armed with an interpretation of formulas, we can define <em>entailment</em> for Predicate Logic. As with Propositional Logic, entailment means that for all models, if all the assumptions are true then the conclusion is true. Now there are infinitely many models, and each model may itself be infinite; so checking them all is no longer feasible. This is why proof for Predicate Logic is more essential than for Propositional Logic.

## Videos

[Slides for the videos below](week08-slides.pdf)

### Models

```
FIXME: CS208-W8P1.mp4
```

### Interpretation of Formulas

```
FIXME: CS208-W8P2.mp4
```

## Widget test:

### “Less than or equal to”

```model-checker
vocab V1 {le/2}

axioms A for V1 {
  refl : "all x. le(x,x)",
  trans : "all x. all y. all z. le(x,y) -> le(y,z) -> le(x,z)"
  //antisym: "all x. all y. le(x,y) -> le(y,x) -> x = y"
}

synth A size 4
```

### “Less than”

```model-checker
vocab V {
  path/2
}

axioms A for V {
  trans       : "all x.all y. all z. path(x,y) -> path(y,z) -> path(x,z)",
  irreflexive : "all x. ¬(path(x,x))",

  symmetry    : "all x. all y. path(x,y) -> path(y,x)"
//  step        : "all x. ex y. path(x,y)"
}

synth A size 4
```

### Monoid

```model-checker
vocab V { op/3, unit/1 }

axioms MONOID for V {
  defined : "all x. all y. ex z. op(x,y,z)",
  functional :
    "all x. all y. all z1. all z2.
       op(x,y,z1) -> op(x,y,z2) -> z1 = z2",
  commutative : "all x. all y. all z. op(x,y,z) -> op(y,x,z)",
  unit_defined : "ex x. unit(x)",
  unit_unique : "all x. all y. unit(x) -> unit(y) -> x = y",
  unit : "all x. all y. all z. unit(y) -> op(x,y,z) -> x = z",
  assoc1 : "all a. all b. all c. all d.
    (ex ab. op(a,b,ab) /\ op(ab,c,d)) ->
    (ex bc. op(b,c,bc) /\ op(a,bc,d))",
  assoc2 : "all a. all b. all c. all d.
    (ex bc. op(b,c,bc) /\ op(a,bc,d)) ->
    (ex ab. op(a,b,ab) /\ op(ab,c,d))",

  idem : "¬(all x. op(x,x,x))"
}

synth MONOID size 2
```

## Plan:

1. Videos:
2. Link to slides
3. Model checking example
4. Model generation:
   1. preorder vs partial order
   2. less-than, where adding symmetry breaks it
