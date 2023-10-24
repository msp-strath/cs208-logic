# Equality

## Introduction to Equality in Logic

Equality (`s = t`) is a fundamental relationship between entities. In logical terms, it expresses the fact that there is no way to tell two things apart *within the logic*. As we shall see below, if `s = t` in the logic, then there is no way write a property that is true for `s` but not true for `t` (and vice versa).

## Syntax and proof rules for Equality

In the syntax, equality is a binary predicate symbol that is usually written infix: `t1 = t2`.

For doing proofs about equality, we could think about just adding some axioms that describe it. It is possible to define what it means to be an *equivalence relation* (i.e., a relation that acts like equality) by the following three properties. Here we do this for some binary relation `≈` to emphasise that these laws are not enough to define proper equality.

1. **Reflexivity**: everything is equal to itself; `t ≈ t`, for all terms `t`.
2. **Symmetry**: if `s ≈ t` then `t ≈ s`, for all terms `s` and `t`.
3. **Transitivity**: if `s ≈ t` and `t ≈ u`, then `s ≈ u`.

These can be written as formulas to give three axioms of an equivalence relation:

1. ∀ x. x ≈ x
2. ∀ x. ∀ y. x ≈ y → y ≈ x
3. ∀ x. ∀ y. ∀ z. x ≈ y → y ≈ z → x ≈ z

These three axioms are the minimum for a relation `≈` to be considered some form of equivalence. However, they are not enough to properly define equality because they do not specify the effect that two things being equal has on everything else in the system.

Specifically, equality has the following special property, usually attributed to  the philosopher Leibniz:

> If `t1 = t2` then *everything* that is true about `t1` is true about `t2`.

Or, in more symbols:

> If `t1 = t2` and `P[x ↦ t1]` then `P[x ↦ t2]`.

This property is known as “substitutivity” or, more philosophically, as “indiscernability of equivalents”. It can be read in two ways:

1. If two things are equal, there is no way to write a formula that is true about one and false about the other.
2. If two things are equal, then we can replace one with the other wherever we want with no effect on what is true; i.e., we can substitute one for the other.

Because it applies for all formulas `P` We can't express this property as an axiom in our system, so we add it as a new rule.

This rule, with reflexivity, is enough to prove the other two properties *symmetry* and *transitivity* for equality.

Equality and its proof rules are explained in more depth in this video:

[Slides for the video (PDF)](week09-slides.pdf)

```
FIXME: CS208-W9P1
```

```textbox
Enter any notes to yourself here.
```

## What things are equal?

One consequence of treating equal things as always substitable for one another is that what we consider to be equality depends on exactly what and how we are modelling. What is considered equal for one application domain might not make sense for another.

Sentences involving quotation in Natural Language are a rich source of tricky examples. For example the sentence “‘Edinburgh’ has 9 letters” might be considered true, but if we were to also consider “Edinburgh” to be equal to “The capital of Scotland”, then we would be able to derive the obviously false fact that “‘The capital of Scotland’ has 9 letters”.

The fundamental problem here is that the statement “‘X’ has N letters” states facts about individuals that are not preserved by our notion of equality. The relation “‘X’ has N letters” makes distinctions between individuals (in this case, it looks at their descriptive names) which are not preserved if we consider “Edinburgh” as just a different name for the capital of Scotland. To fix this example, we need to make sure that our predicates and our equalities are consistent, either by not admitting that “Edinburgh” and “The Capital of Scotland” are equal, or by not allowing statements of the form “‘X’ has N letters” in our vocabulary.

This kind of example crops up in Computer Science whenever we have to make a distinction between the *description* of a process (i.e., the program that implements it) and the *observable behaviour* of a process. In some cases equality should track the implementation (e.g., a text editor application should treat different program texts differently), and in others it should track the behaviour (e.g., an optimising compiler is allowed to change the implementation if it preserves the behaviour).

FIXME: do an exercise on this.

## Using Equality in the Proof Editor

The following video demonstrates the use of the proof rules for equality in the proof editor. Watch the video before attempting the exercises below.

```
FIXME: CS208-W9P3
```

```textbox
Enter any notes to yourself here.
```

## Exercises

```details
Proof commands...

```

FIXME: week 9 exercises

FIXME: have an exercise that shows that making inconsistent assumptions about intensionality of equality is bad.
