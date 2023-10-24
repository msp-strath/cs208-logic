This page links to the interactive notes and exercises for Logic part of [CS208 Logic & Algorithms](https://classes.myplace.strath.ac.uk/course/view.php?id=15121), part of the Undergraduate Computer Science degree at the [University of Strathclyde](https://www.strath.ac.uk/science/computerinformationsciences/).

Please send any comments and queries to [Robert Atkey](mailto:robert.atkey@strath.ac.uk) ([Web page](https://bentnib.org)). The source code for these pages in publically available [on Github](https://github.com/bobatkey/interactive-logic-course).

## Introduction

In the first half of the course, we will study Symbolic Logic. Symbolic Logic is a fundamental set of the techniques for describing data and processes. It is useful in computing for describing, building and checking systems. We will look at how to define logic (syntax and semantics), algorithms for computing with logic, and systems for deriving proofs in formal logic. We will also keep in mind the practical uses of logic in Computer Science.

This course follows on from CS103 and CS106 in first year.

Please see the [MyPlace page](https://classes.myplace.strath.ac.uk/course/view.php?id=15121) for information on Lectures, Tutorials, and Assessment.

### Learning Outcomes

By the end of semester 1 of the module you should be able to:

- Understand formulas of Propositional and Predicate Logic
- Use Propositional and Predicate Logic to model problems and their solutions
- Understand how a SAT solver works and how it can be used to solve problems
- Construct proofs in Propositional and Predicate Logic
- Understand the basic metatheory of Propositional and Predicate Logic

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

6. [Introducing Predicate Logic](pred-logic-intro.html) as an expressive language for making statements in a formalised way. By selecting our vocabulary carefully, we can use Predicate Logic as a modelling tool to describe many situations.

7. [Scoping and Substitution]. Before we look at proof for Predicate Logic, we need to upgrade our Natural Deduction system to handle assumptions about entities as well as propositions. This brings us to the matters of *scope* and *substitution*.

8. [Proof rules for Predicate Logic]. Natural deduction rules for “for all” and “exists” allow us to construct proofs of Predicate Logic formulas.

9. [Predicate Logic Semantics]. A break from proof for a bit to consider what Predicate Logic formulas are talking about. It is not just about true/false anymore, but about relationships between individuals.

11. [Equality]. How do we prove that one thing is equal to another thing? And what can we prove if we know that one thing is equal to another thing?

12. [Arithmetic and Induction] allows us to prove facts about infinitely many individuals, as long as those individuals are built up in a “well founded” way. We look specifically at induction on natural numbers, which will allow us to prove facts in the theory of arithmetic.

13. [More equality and induction exercises].

14. [Metatheory and Gödel's Incompleteness Theorem]. If we can construct proofs, then could we get a computer to do it? What are the limits of what we can prove?
