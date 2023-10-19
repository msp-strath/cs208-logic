# Interactive Lecture Notes

This page links to the interactive notes and exercises for Logic part of CS208 Logic & Algorithms.

Comments and queries to [Robert Atkey](mailto:robert.atkey@strath.ac.uk) ([Web page](https://bentnib.org)).

## Part 1: Logical Modelling

In Part 1, we use logical modelling to describe and solve problems.

1. [Introduction](logical-modelling-intro.html) to Logical Modelling and the Logical Modelling tool.
2. [The Wizard's Pets](wizards-pets.html), introducing some common kinds of constraints through a toy example.
3. [Patterns](patterns.html) for writing logical constraints.
4. [A fruity exercise](fruit-exercise.html) for you to do.
5. [The Package Installation Problem](packages.html).
6. [SAT solvers](sat.html), the underlying technology.
7. [How to handle bigger problems](domains-and-parameters.html) with domains and parameters.
8. [Resource allocation problems](resource-alloc.html), which are a kind of graph colouring problem. (*under construction*)
9. [Converting to CNF](converting-to-cnf.html). SAT solvers take their input in CNF. Some problems are naturally in CNF (like the Packages or Resource Allocation problems above), but sometimes we need to convert any formula to one in CNF.
10. [Circuits, Gates and Formulas](circuits.html), where we look at encoding logic gates as clauses, using the Tseytin transformaion. We can then get the solver to answer questions about circuits.

**Coursework:** [Coursework 1 is here](coursework1.html).

## Part 2: Deductive proof and Predicate Logic

In Part 2, we strive for truth through proof. We will be primarily using an proof editor to construct natural deduction proofs. Exercises with fixed things to prove are embedded in each of the pages. You can also enter your own things to prove [on this page](prover.html).

1. [Introduction to Deductive Proof](proof-intro.html), which describes the general idea of proof systems, and introduces a small example of a proof system inspired by biology.
2. [Natural Deduction and the rules for And](natural-deduction-intro.html). Natural Deduction is a style of proof system that places a particular emphasis on how assumptions are used, and on how the rules for each connective come in introduction and elimination pairs.
3. [Proof rules for Implication](proof-implication.html). Implication allows us to make conditional statements that we prove by temporarily making assumptions.
4. [Proof rules for Or and Not](proof-or.html), which complete the rules for the connectives of Propositional Logic.
5. [Soundness and Completeness, and some Philosophy](sound-complete-meaning.html). The system so far is sound, but is it complete? Should it be complete?
6. [Introducing Predicate Logic] as an expressive language for making statements in a formalised way. By selecting our vocabulary carefully, we can use Predicate Logic as a modelling tool to describe many situations.
7. [Upgrading Natural Deduction for Predicate Logic]. Before we look at proof for Predicate Logic, we need to upgrade our Natural Deduction system to handle assumptions about entities as well as propositions. This also brings to the matters of *scope* and *substitution*.
8. [Proof rules for Predicate Logic]. Natural deduction rules for “for all” and “exists” allow us to construct proofs of Predicate Logic formulas.
9. [Predicate Logic Semantics]. A break from proof for a bit to consider what Predicate Logic formulas are talking about. It is not just about true/false anymore, but about relationships between individuals.
11. [Equality]. How do we prove that one thing is equal to another thing? And what can we prove if we know that one thing is equal to another thing?
12. [Induction] allows us to prove facts about infinitely many individuals, as long as those individuals are built up in a “well founded” way. We look specifically at induction on natural numbers, which will allow us to prove facts in the theory of arithmetic.
13. [More equality and induction exercises].
14. [Metatheory and Gödel's Incompleteness Theorem]. If we can construct proofs, then could we get a computer to do it? What are the limits of what we can prove?
