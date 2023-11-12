# Equality

Equality (`s = t`) is a fundamental relationship between entities. When we state an equality `s = t`, we are saying that there is no way to tell the two individuals `s` and `t` apart from the point of view of the logical setting we are working in.

## Syntax and Proof Rules for Equality

In the syntax, equality is a binary predicate symbol that is usually written infix: `t1 = t2`.

### Equivalence Relations

For doing proofs about equality, we could think about just adding some axioms that describe it. It is possible to define what it means to be an *equivalence relation* (i.e., a relation that acts like equality) by the following three properties. Here we do this for some binary relation `≈` to emphasise that these laws are not enough to define proper equality.

1. **Reflexivity**: everything is equal to itself; `t ≈ t`, for all terms `t`.
2. **Symmetry**: if `s ≈ t` then `t ≈ s`, for all terms `s` and `t`.
3. **Transitivity**: if `s ≈ t` and `t ≈ u`, then `s ≈ u`.

These can be written as formulas to give three axioms of an equivalence relation:

1. reflexivity: ∀ x. x ≈ x
2. symmetry: ∀ x. ∀ y. x ≈ y → y ≈ x
3. transitivity: ∀ x. ∀ y. ∀ z. x ≈ y → y ≈ z → x ≈ z

There's not much one can prove directly from these axioms without making further assumptions. One thing that can be proved is that, even without reflexivity, if `x` is equal to something, then it must be equal to itself:

```focused-nd {id=equality-equivrelation}
(config
 (assumptions (symmetry "all x. all y. equiv(x,y) -> equiv(y,x)")
			  (transitivity "all x. all y. all z. equiv(x,y) -> equiv(y,z) -> equiv(x,z)"))
 (goal "all x. (ex y. equiv(x,y)) -> equiv(x,x)"))
```

(A binary relation that only has symmetry and transitivity is called a *partial equivalence relation*. They are useful for describing the semantics of programming languages.)

### Equality

These three axioms are the minimum for a relation `≈` to be considered some form of equivalence. However, they are not enough to properly define equality because they do not specify the effect that two things being equal has on everything else in the system.

Specifically, equality has the following special property, usually attributed to  the philosopher Leibniz:

> If `t1 = t2` then *everything* that is true about `t1` is true about `t2`.

Or, in more symbols:

> If `t1 = t2` and `P[x ↦ t1]` then `P[x ↦ t2]`.

This property is known as “substitutivity” or, more philosophically, as “indiscernability of equivalents”. It can be read in two ways:

1. If two things are equal, there is no way to write a formula that is true about one and false about the other.
2. If two things are equal, then we can replace one with the other wherever we want with no effect on what is true; i.e., we can substitute one for the other.

Because it applies for all formulas `P` We can't express this property as an axiom in our system, so we add it as a new rule.

This rule, when combined with reflexivity, is enough to prove the other two properties *symmetry* and *transitivity* for equality.

Equality and its proof rules are explained in more depth in this video:

[Slides for the video (PDF)](week09-slides.pdf)

```youtube
9sy3j34bMvY
```

```textbox {id=equality-notes1}
Enter any notes to yourself here.
```

### What things are equal?

One consequence of treating equal things as always substitable for one another is that what we consider to be equality depends on exactly what and how we are modelling. What is considered equal for one application domain might not make sense for another.

Sentences involving quotation in Natural Language are a rich source of tricky examples. For example the sentence “‘Edinburgh’ has 9 letters” might be considered true, but if we were to also consider “Edinburgh” to be equal to “The capital of Scotland”, then we would be able to derive the obviously false fact that “‘The capital of Scotland’ has 9 letters”.

The fundamental problem here is that the statement “‘X’ has N letters” states facts about individuals that are not preserved by our notion of equality. The relation “‘X’ has N letters” makes distinctions between individuals (in this case, it looks at their descriptive names) which are not preserved if we consider “Edinburgh” as just a different name for the capital of Scotland. To fix this example, we need to make sure that our predicates and our equalities are consistent, either by not admitting that “Edinburgh” and “The capital of Scotland” are equal, or by not allowing statements of the form “‘X’ has N letters” in our vocabulary.

This kind of example crops up in Computer Science whenever we have to make a distinction between the *description* of a process (i.e., the program that implements it) and the *observable behaviour* of a process. In some cases equality should track the implementation (e.g., a text editor application should treat different program texts differently), and in others it should track the behaviour (e.g., an optimising compiler is allowed to change the implementation if it preserves the behaviour). In philosophical jargon, these two aspects are referred to the *intension* (how a thing is built) and *extension* (how a thing acts) of an object.

## Using Equality in the Proof Editor

The following video demonstrates the use of the proof rules for equality in the proof editor. Watch the video before attempting the exercises below.

```youtube
pTVnIz0TqsA
```

```textbox {id=equality-notes2}
Enter any notes to yourself here.
```

## Exercises

````details
Proof commands...

The blue boxes represent parts of the proof that are unfinished.  The comments (in green) tells you what the current goal is. Either the goal is unfocused:

```
{ goal: <some formula> }
```

or there is a formula is focus:

```
{ focus: <formula1>; goal: <formula2> }
```

The commands that you can use differ according to which mode youare in. The commands correspond directly to the proof rules given in the videos.

#### Unfocused mode

These rules can be used when there is no formula in the focus. These rules either act on the conclusion directly to break it down into simpler sub-goals, or switch to focused mode (the `use` command).

- `introduce H` can be used when the goal is an implication ‘P → Q’. The name `H` is used to give a name to the new assumption P. The proof then continues proving Q with this new assumption. A green comment is inserted to say what the new named assumption is.
- `introduce y` can be used when the goal is a *for all* quantification ‘∀x. Q’. The name `y` is used for the assumption of an arbitrary individual that we have to prove ‘Q’ for. The proof then continues proving ‘Q’. A green comment is inserted to say that the rest of this branch of the proof is under the assumption that there is a named entity.
- `split` can be used when the goal is a conjunction “P ∧ Q”. The proof will split into two sub-proofs, one to prove the first half of the conjunction “P”, and one to prove the other half “Q”.
- `true` can be used when the goal to prove is ‘T’ (true). This  will finish this branch of the proof.
- `left` can be used when the goal to prove is a disjunction ‘P ∨ Q’. A new sub goal will be created to prove ‘P’.
- `right` can be used when the goal to prove is a disjunction ‘P ∨ Q’. A new sub goal will be created to prove ‘Q’.
- `not-intro H` can be used when the goal is a negation ‘¬P’. The name `H` is used to give a name to the new assumption P. The proof then continues proving F (i.e. False) with this new assumption. A green comment is inserted to say what the new named assumption is.
- `exists "t"` can be used when the goal is an *exists* quantification ‘∃x. Q’. The term `t` which must be in quotes, is used as the existential witness and is substituted for `x` in Q. The proof then continues proving ‘Q[x:=t]’,
- **NEW** `refl` can be used when the goal is ‘t = t’ for some term ‘t’. Note that the terms on each side of the equality must be exactly the same. If this command is applicable, then this branch of the proof is complete.
- `use H` can be used whenever there is no current focus. `H` is the name of some assumption that is available on this branch of the proof. Named assumptions come from the original statement to be proved, and uses of `introduce H`, `cases H1 H2`, `not-intro H`, and `unpack y H`.

#### Focused mode

These rules apply when there is a formula in focus. These rules either act upon the formula in focus, or finish the proof when the focused formula is the same as the goal.

- `done` can be used when the formula in focus is exactly the same  as the goal formula. This will finish this branch of the proof.
- `apply` can be used when the formula in focus is an implication ‘P → Q’. A new subgoal to prove ‘P’ is generated, and the focus becomes ‘Q’ to continue the proof.
- `first` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘P’, the first part of the conjunction, and the proof continues.
- `second` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘Q’, the second part of the conjunction, and the proof continues.
- `cases H1 H2` can be used then the formula in focus is a disjunction ‘P ∨ Q’. The proof splits into two branches, one for ‘P’ and one for ‘Q’. The two names `H1` and `H2` are used to name the new assumption on the two branches. Green comments are inserted to say what the new named assumptions are.
- `false` can be used when the formula in focus is ‘F’ (false). The proof finishes at this point, no matter what the conclusion is.
- `not-elim` can be used when the formula in focus is a negation  ‘¬P’. A new subgoal is generated to prove ‘P’ in order to generate a contradiction.
- `inst "t"` can be used when the formula in focus is of the form ‘∀x. P’. The term t (which must be in quotes) is substituted in the place of x in the formula after the quantifier and the substituted formula ‘P[x:=t]’ remains in focus.
- `unpack y H` can be used when the formula in focus is of the form ‘∃x. P’. The existential is “unpacked” into the assumption of an entity `y` and its property ‘P[x:=y]’, which is named `H`. Green comments are inserted to say what the assumption ‘`H`’ is.
- **NEW** `rewrite->` can be used when the formula in focus is an equality ‘t1 = t2’. Every occurrence of ‘t1’ in the goal is rewritten to ‘t2’. (The rewrite goes left to right.)
- **NEW** `rewrite<-` can be used when the formula in focus is an equality ‘t1 = t2’. Every occurrence of ‘t2’ in the goal is rewritten to ‘t1’. (The rewrite goes right to left.)
````

### Exercise 1 : Symmetry

```focused-nd {id=equality-symmetry}
(config
 (goal "all x. all y. x = y -> y = x"))
```

### Exercise 2 : Transitivity

```focused-nd {id=equality-transitivity}
(config
 (goal "all x. all y. all z. x = y -> y = z -> x = z"))
```

### Exercise 3 : Abelian Groups

A [abelian group](https://en.wikipedia.org/wiki/Abelian_group) is a generalisation of the ideas of addition and multiplication of numbers. We assume there is an operation ‘combine’ that combines two things (e.g., adding or multiplying), an operation ‘inv’ that takes the inverse of a thing (e.g., negation or reciprocal), and a value ‘emp’ that has no effect when combined with something else (e.g., zero for addition, or one for multiplication). What makes an abelian group *abelian* and not just a group is that it does not matter what order things are combined in: ‘combine(x,y) = combine(y,x)’.

The axioms of an abelian group are:

1. combine-assoc : ∀x. ∀y. ∀z. combine(x, combine(y, z)) = combine(combine(x, y), z)

   This axiom states that if you have three things to combine together, then it does matter which order you do the ‘combine’ operations in, the answers are always the same. Axioms like this are usually called *associativity*, or *assoc* for short.
2. combine-comm : ∀x. ∀y. combine(x, y) = combine(y, x)

   This axiom states that combining ‘x’ with ‘y’ is the same as combining ‘y’ with ‘x’, just as it is for normal addition and multiplication. Axioms like this are usually called *commutativity*, or *comm* for short.
3. combine-inv : ∀x. combine(x, inv(x)) = emp

   This axiom states that combining something with its inverse is equal to the empty thing. E.g., `x + (-x) = 0` for addition on numbers.
4. combine-emp : ∀x. combine(x, emp) = x

   This axiom states that combining ‘x’ with ‘emp’ is the same as ‘x’.

#### Exercise 3.1

‘emp’s in the middle of a combination can always be removed:

```focused-nd {id=equality-abelian1}
(config
 (assumptions-name "abelian group")
 (assumptions
  (combine-assoc "∀x. ∀y. ∀z. combine(x, combine(y, z)) = combine(combine(x, y), z)")
  (combine-comm "∀x. ∀y. combine(x, y) = combine(y, x)")
  (combine-inv "∀x. combine(x, inv(x)) = emp")
  (combine-emp "∀x. combine(x, emp) = x"))
 (goal "all x. all y. combine(x, combine(emp, y)) = combine(x,y)"))
```

#### Exercise 3.2

The ‘combine-emp’ axiom works the other way round as well:

```focused-nd {id=equality-abelian2}
(config
 (assumptions-name "abelian group")
 (assumptions
  (combine-assoc "∀x. ∀y. ∀z. combine(x, combine(y, z)) = combine(combine(x, y), z)")
  (combine-comm "∀x. ∀y. combine(x, y) = combine(y, x)")
  (combine-inv "∀x. combine(x, inv(x)) = emp")
  (combine-emp "∀x. combine(x, emp) = x"))
 (goal "all x. combine(emp, x) = x"))
```

#### Exercise 3.3

The ‘combine-inv’ axiom works the other way round as well:

```focused-nd {id=equality-abelian3}
(config
 (assumptions-name "abelian group")
 (assumptions
  (combine-assoc "∀x. ∀y. ∀z. combine(x, combine(y, z)) = combine(combine(x, y), z)")
  (combine-comm "∀x. ∀y. combine(x, y) = combine(y, x)")
  (combine-inv "∀x. combine(x, inv(x)) = emp")
  (combine-emp "∀x. combine(x, emp) = x"))
 (goal "all x. combine(inv(x), x) = emp"))
```

### Exercise 4

This example demonstrates what can go wrong if we have a mismatch between the properties we assume of things, and what things are equal. Two things can be equal only if we do not talk about any properties that may separate them. Here is the example with letter counts from above:

```focused-nd {id=equality-intensional1}
(config
 (assumptions-name "Edinburgh Facts")
 (assumptions
  (edinburgh-has-nine-letters           "has-nine-letters(edinburgh())")
  (capital-of-scotland-not-nine-letters "¬has-nine-letters(capital-of-scotland())")
  (edinburgh-is-capital-of-scotland     "edinburgh() = capital-of-scotland()"))
 (goal "F"))
```

More generally, if we have two things that have different properties (one is `P` and one is not `P`), then they must be not equal:

```focused-nd {id=equality-intensional2}
(config
 (goal "all x. all y. P(x) -> ¬P(y) -> ¬(x = y)"))
```
