# Topic 1.2: Deductive Proof

We now look at the general idea of deductive systems, collections of inference rules that allow us to derive new facts from existing ones.

This is a radically different approach to the “enumerate all possible truth values” approaches we have taken so far by writing out [truth tables](truth-tables.md) and using them to deduce [entailments](entailment.md).

Instead, we derive conclusions from assumptions by using rules. This is much easier than writing out truth tables. Another benefit is that by choosing different rules we can get different logics, and even special purpose logics.

## What is Deductive Proof? {id=proof:what-is}

**Proof rules** describe which deductions we can make from zero or more *premises* to a *conclusion*. They are usually named (here with “Name”):

```rules-display
(config
 (rule
  (name "Name")
  (premises premise-1 premise-2 ---- premise-n)
  (conclusion conclusion)))
```

The rule is read top to bottom: if we can prove all the premises (possibly using other rules), then we can use this rule to deduce the conclusion. Often, we will write a collection of rules as one rule by putting in *variables* (usually *X*, *Y*, *Z*) to stand for other symbols. See below for multiple examples of this. Rules (or rule collections) are usually given names, which are written to the right of the premises (sometimes off the end of the line).

Rules with no premises are called axioms, and are needed to be able to prove anything. The axioms are things that we can assume without proof.

Proofs are constructed from rules by arranging them into trees, which we usually construct bottom up, applying rules to transform a goal statement to be proved into (hopefully) simpler subgoals that will eventually be proved by means of axioms. The rest of this page uses a small proof editor to interactively build proofs.

## Example: Mammalian Biology {id=proof:biology-example}

### Rules {id=proof:biology-example:rules}

Here are the proof rules used for a small mammalian biology proof system. There are four axioms A1-A4 that tell us basic facts about bears and coconuts, and two rules R1 and R2 that allow us to make further deductions.

```rules-display
(config
 (rule
  (name "R1")
  (premises (furry X) (makes-milk X))
  (conclusion (mammal X)))

 (rule
  (name "A1")
  (premises)
  (conclusion (furry bear)))

 (rule
  (name "A2")
  (premises)
  (conclusion (makes-milk bear)))

 (rule
  (name "R2")
  (premises (is-covered-in-fibres X))
  (conclusion (furry X)))

 (rule
  (name "A3")
  (premises)
  (conclusion (is-covered-in-fibres coconut)))

 (rule
  (name "A4")
  (premises)
  (conclusion (makes-milk coconut))))
```

### Example 1 {id=proof:biology-example:example1}

Enter the name of the rule you want to apply in the input box and press enter (for example, A1 for the “furry(bear)” axiom. If the rule does not apply, because the conclusion of the rule does not match the statement to be proved, the system will not let you apply it. Continue until the proof has no more branches that need proof.

```rules {id=rules-example1}
(config
 (rule
  (name "R1")
  (premises (furry X) (makes-milk X))
  (conclusion (mammal X)))

 (rule
  (name "A1")
  (premises)
  (conclusion (furry bear)))

 (rule
  (name "A2")
  (premises)
  (conclusion (makes-milk bear)))

 (rule
  (name "R2")
  (premises (is-covered-in-fibres X))
  (conclusion (furry X)))

 (rule
  (name "A3")
  (premises)
  (conclusion (is-covered-in-fibres coconut)))

 (rule
  (name "A4")
  (premises)
  (conclusion (makes-milk coconut)))

 (goal (mammal bear)))
```

If you get stuck, click on a statement in the proof tree to reset it to that point.

### Example 2 {id=proof:biology-example:example2}

```rules {id=rules-example2}
(config
 (rule
  (name "R1")
  (premises (furry X) (makes-milk X))
  (conclusion (mammal X)))

 (rule
  (name "A1")
  (premises)
  (conclusion (furry bear)))

 (rule
  (name "A2")
  (premises)
  (conclusion (makes-milk bear)))

 (rule
  (name "R2")
  (premises (is-covered-in-fibres X))
  (conclusion (furry X)))

 (rule
  (name "A3")
  (premises)
  (conclusion (is-covered-in-fibres coconut)))

 (rule
  (name "A4")
  (premises)
  (conclusion (makes-milk coconut)))

 (goal (mammal coconut)))
```

## Example: Arithmetic {id=proof:arithmetic-example}

We can also represent arithmetic on whole numbers as proof rules. For the purposes of this proof system we use a representation of whole numbers starting from 0 in *unary*. This means that we represent 0 as the symbol “z” and every other number *n* as *n* uses of the successor function “s”. For example, *5* is represented as “s(s(s(s(s(z)))))”. Think of using “s” as adding one (or taking the *s*uccessor of a number).

We have two judgement forms:
1. If we can prove add(x,y,z) then that means that x + y = z.
2. If we can prove mul(x,y,z) then that means that x * y = z.

The rules are:

```rules-display
(config
 (rule
  (name "add z")
  (premises)
  (conclusion (add z Y Y)))

 (rule
  (name "add s")
  (premises (add X Y Z))
  (conclusion (add (s X) Y (s Z))))

 (rule
  (name "mul z")
  (premises)
  (conclusion (mul z Y z)))

 (rule
  (name "mul s")
  (premises (mul X Y W) (add W Y Z))
  (conclusion (mul (s X) Y Z))))
```

The best way to see how these rules is to use them. As above, type the name of the rule into the box to use it.

### Addition by repeated succession {id=proof:arithmetic-example:addition}

Addition works by stripping *s*uccessors from the first number and the third number until we get down to *z*ero in the first number and the second and third are equal (because 0 + y = y).

Let's try 2 + 2 = 4:

```rules {id=rules-adding-example1}
(config
 (rule
  (name "add z")
  (premises)
  (conclusion (add z Y Y)))

 (rule
  (name "add s")
  (premises (add X Y Z))
  (conclusion (add (s X) Y (s Z))))

 (goal (add (s (s z))
            (s (s z))
			(s (s (s (s z)))))))
```

And 3 + 2 = 5:

```rules {id=rules-adding-example2}
(config
 (rule
  (name "add z")
  (premises)
  (conclusion (add z Y Y)))

 (rule
  (name "add s")
  (premises (add X Y Z))
  (conclusion (add (s X) Y (s Z))))

 (goal (add (s (s (s z)))
            (s (s z))
			(s (s (s (s (s z))))))))
```

Note that if we try to prove an equation that doesn't hold, such as 2 + 2 = 2, then we will not be able to complete the proof:

```rules {id=rules-adding-example3}
(config
 (rule
  (name "add z")
  (premises)
  (conclusion (add z Y Y)))

 (rule
  (name "add s")
  (premises (add X Y Z))
  (conclusion (add (s X) Y (s Z))))

 (goal (add (s (s z))
            (s (s z))
			(s (s z)))))
```

The **soundness** property of this system is that if we can prove add(x,y,z) then it is actually the case that x + y = z. This system is also **complete**, meaning that if x + y = z, then it is possible to prove add(x,y,z). (Note that this only holds for numbers we can represent using *z*ero and *s*uccessor, the system has nothing to say about negative numbers, or fractions, or any other kind of number.)

### Multiplication by repeated addition {id=proof:arithmetic-example:multiplication}

Multiplication is the process of repeated addition. We use the first number to tell us how many times to repeat the addition of the second number:

For example, 2 * 3 = 0 + 3 + 3 = 6:

```rules {id=rules-multiplication-example1}
(config
 (rule
  (name "add z")
  (premises)
  (conclusion (add z Y Y)))

 (rule
  (name "add s")
  (premises (add X Y Z))
  (conclusion (add (s X) Y (s Z))))

 (rule
  (name "mul z")
  (premises)
  (conclusion (mul z Y z)))

 (rule
  (name "mul s")
  (premises (mul X Y W) (add W Y Z))
  (conclusion (mul (s X) Y Z)))

 (goal (mul (s (s z)) (s (s (s z))) (s (s (s (s (s (s z)))))))))
```

And 3 * 2 = 0 + 2 + 2 + 2 = 6:

```rules {id=rules-multiplication-example2}
(config
 (rule
  (name "add z")
  (premises)
  (conclusion (add z Y Y)))

 (rule
  (name "add s")
  (premises (add X Y Z))
  (conclusion (add (s X) Y (s Z))))

 (rule
  (name "mul z")
  (premises)
  (conclusion (mul z Y z)))

 (rule
  (name "mul s")
  (premises (mul X Y W) (add W Y Z))
  (conclusion (mul (s X) Y Z)))

 (goal (mul (s (s (s z))) (s (s z)) (s (s (s (s (s (s z)))))))))
```

As for addition, the **soundness** property of this system is that if we can prove mul(x,y,z) then it is actually the case that x * y = z. And this system is also **complete**, meaning that if x * y = z, then it is possible to prove mul(x,y,z). (Again, this only holds for whole numbers starting from *0*).

## Example: Haggis Migration {id=proof:haggis-example}

For many proof systems, there can often be more than one proof for a single statement. One way to think about this is as different "paths" leading to the same conclusion. For some purposes we may only care that the conclusion is reached (so we know that it is justified by our rules). For other purposes, we may care about the exact route taken (often shorter proofs are preferred over longer rules, but sometimes a longer proof may be more meaningful or useful in some way).

Let's take the idea of paths to a conclusion literally, and look at a proof system for describing the migration patterns of haggis. There is one judgement migrates(X,Y), meaning that it is possible for haggis to migrate from X to Y.

Here are the rules:

```rules-display
(config
 (rule
  (name "m1")
  (premises)
  (conclusion (migrates glasgow falkirk)))
 (rule
  (name "m2")
  (premises)
  (conclusion (migrates falkirk aviemore)))
 (rule
  (name "m3")
  (premises)
  (conclusion (migrates aviemore inverness)))
 (rule
  (name "m4")
  (premises)
  (conclusion (migrates glasgow stirling)))
 (rule
  (name "m5")
  (conclusion (migrates stirling inverness)))
 (rule
  (name "link")
  (premises (migrates X Y) (migrates Y Z))
  (conclusion (migrates X Z))))
```

(I am not claiming whether or not this system is sound or complete for real haggis migration patterns.)

There are three proofs of migrates(glasgow, inverness). Can you find them all? If you get stuck, clicking on a part of the proof tree resets the proof to that point.


**Proof 1:**

```rules {id=rules-haggis-example1}
(config
 (rule
  (name "m1")
  (premises)
  (conclusion (migrates glasgow falkirk)))
 (rule
  (name "m2")
  (premises)
  (conclusion (migrates falkirk aviemore)))
 (rule
  (name "m3")
  (premises)
  (conclusion (migrates aviemore inverness)))
 (rule
  (name "m4")
  (premises)
  (conclusion (migrates glasgow stirling)))
 (rule
  (name "m5")
  (conclusion (migrates stirling inverness)))
 (rule
  (name "link")
  (premises (migrates X Y) (migrates Y Z))
  (conclusion (migrates X Z)))

 (goal (migrates glasgow inverness)))
```

**Proof 2:**

```rules {id=rules-haggis-example2}
(config
 (rule
  (name "m1")
  (premises)
  (conclusion (migrates glasgow falkirk)))
 (rule
  (name "m2")
  (premises)
  (conclusion (migrates falkirk aviemore)))
 (rule
  (name "m3")
  (premises)
  (conclusion (migrates aviemore inverness)))
 (rule
  (name "m4")
  (premises)
  (conclusion (migrates glasgow stirling)))
 (rule
  (name "m5")
  (conclusion (migrates stirling inverness)))
 (rule
  (name "link")
  (premises (migrates X Y) (migrates Y Z))
  (conclusion (migrates X Z)))

 (goal (migrates glasgow inverness)))
```

**Proof 3**

```rules {id=rules-haggis-example3}
(config
 (rule
  (name "m1")
  (premises)
  (conclusion (migrates glasgow falkirk)))
 (rule
  (name "m2")
  (premises)
  (conclusion (migrates falkirk aviemore)))
 (rule
  (name "m3")
  (premises)
  (conclusion (migrates aviemore inverness)))
 (rule
  (name "m4")
  (premises)
  (conclusion (migrates glasgow stirling)))
 (rule
  (name "m5")
  (conclusion (migrates stirling inverness)))
 (rule
  (name "link")
  (premises (migrates X Y) (migrates Y Z))
  (conclusion (migrates X Z)))

 (goal (migrates glasgow inverness)))
```

## Proof Systems for Logic {id=proof:logic}

The systems of proof rules we have looked at above are all for specific cases. In the remainder of the course we will look at a general proof system for Propositional and Predicate Logic. These proof systems are powerful enough that other proof systems can be encoded in them by using implication to move proof rules "into" the logical formulas.

```comment
We will see an example of this when we come to look at [arithmetic](induction.md) inside Predicate Logic.
```

There are many ways of giving proof systems for Propositional and Predicate Logic. We touched on a specific case by enumerating some of the rules of [entailment](entailment.md). It is also possible to design a collection of rules systematically to make sure that it is modular and (relatively) easy to use.

The system that we will use is a variant of Natural Deduction, called [*Focused* Natural Deduction](natural-deduction-intro.md). There are other proof systems such as Sequent Calculus. One of the simplest, in terms of number of rules and *not* in terms of constructing proofs, are “Hilbert” style proof systems which usually only have one rule (“Modus Ponens” or “MP”) and some axioms.

For a minimal logical system that only includes implication the rule and axioms are: (implication is written as implies(a,b) here, due to limitations with the tool).

```rules-display
(config
 (rule
  (name "S")
  (conclusion (implies (implies A (implies B C))
                       (implies (implies A B)
					       (implies A C)))))
 (rule
  (name "K")
  (conclusion (implies A (implies B A))))
 (rule
  (name "MP")
  (premises (implies A B) A)
  (conclusion B)))
```

In more normal notation, the *S* axiom is written (A → B → C) → (A → B) → (A → C) and the *K* axiom is written A → B → A. The rule MP (“[Modus Ponens](https://en.m.wikipedia.org/wiki/Modus_ponens)”) says that if we know A implies B and we know A, then we know B. We can see MP as a way of incorporating the idea of applying a proof rule directly into the logic.

This system has its roots in Gottlob Frege's book [Begriffsschrift](https://en.m.wikipedia.org/wiki/Begriffsschrift) published in 1879, which was the first attempt to write down a systematic proof system for logic by itself. The idea was later developed by David Hilbert and are often called [Hilbert Systems](https://en.m.wikipedia.org/wiki/Hilbert_system). It is closely related to [Combinatory Logic](https://en.m.wikipedia.org/wiki/Combinatory_logic), one of the many systems that can be used to describe what is computable.

This system is surprisingly expressive, and can be extended to all of propositional logic just by adding extra axioms. Even with just these two rules, it is sound and complete for Intuitionistic Logic when the only connective is implication (see the section on [Soundness & Completeness & Philosophy](natural-deduction-intro.md#natural-deduction:sound-complete) for more on Intuitionistic Logic). Because the logic can be easily changed just by using different axioms, systems like these are often used by logicians experimenting with alternative logical systems.

However, actually *constructing* proofs in this system can be very difficult.

As an example, try to prove that “a” implies “a”. Have a look at the [Wikipedia page on Hilbert Systems](https://en.m.wikipedia.org/wiki/Hilbert_system) if you get stuck.

```rules {id=rules-sk}
(config
 (rule
  (name "S")
  (conclusion (implies (implies A (implies B C))
                       (implies (implies A B)
					       (implies A C)))))
 (rule
  (name "K")
  (conclusion (implies A (implies B A))))
 (rule
  (name "MP")
  (premises (implies A B) A)
  (conclusion B))

 (goal (implies a a)))
```

(You'll get at least one of the formulas in the proof being left unresolved as `Xnn`, because the proof isn't enough to fully determine exactly how the variables in the axioms are used.)

This proof system is hard to use because it does not allow for reasoning where we temporarily make assumptions that are only used in parts of the proof. Every statement in the proof needs to explicitly list all of its assumptions. For example, looking at the *S* axiom, we can see that it has the same form as MP, except that (a) it uses implication instead of being a rule, and (b) it has an extra assumption *A* throughout.

[Natural Deduction](natural-deduction-intro.md) is an alternative proof system that incorporates temporary assumptions into the logic directly, making it much easier to use. Natural Deduction is the kind of system we will use in this course.
