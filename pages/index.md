This page links to the interactive notes and exercises for Logic part of [CS208 Logic & Algorithms](https://classes.myplace.strath.ac.uk/course/view.php?id=15121), part of the Undergraduate BSc (Hons) /MEng Computer Science and BSc (Hons) Software Engineering degrees at the [University of Strathclyde](https://www.strath.ac.uk/science/computerinformationsciences/).

Please send any comments, queries, or corrections to [Robert Atkey](mailto:robert.atkey@strath.ac.uk) ([Web page](https://bentnib.org)). The source code for these pages in available [on Github](https://github.com/msp-strath/cs208-logic).

## Introduction

In the first semester of CS208, we will study Symbolic Logic. Symbolic Logic is a fundamental set of techniques for describing situations, reasoning, data, and processes. It is useful in computing for describing, building, and checking systems, and for solving complicated problems involving many interacting constraints. We will look at how to define logic (syntax and semantics), algorithms for computing with logic, and systems for deriving proofs in formal logic. We will also keep in mind the practical uses of logic in Computer Science.

This course follows on from CS103 and CS106 in first year.

Please see the [MyPlace page](https://classes.myplace.strath.ac.uk/course/view.php?id=15121) (Strathclyde students only) for information on Lectures, Tutorials, and Assessment.

### Learning Outcomes

By the end of semester 1 of the module you should be able to:

- Understand the meaning of formulas of Propositional and Predicate Logic
- Construct proofs of formulas in Propositional and Predicate Logic
- Understand how to specify and verify programs using assertions and loop invariants
- Understand the concept of proof automation and its limits

## Topics

The course is divded into 11 topics, each consuming a week of the course.

### Topic 0: Propositional Logic

Lectures:
- Monday 22nd September

[The slides for this lecture](topic00-slides.pdf)

Topic 0 of this course is a (re)introduction to the basic concepts of Propositional Logic. We look at the syntax of Propositional Logic (what are the formulas?) and the semantics (what do the formulas mean?).

Propositional Logic is concerned with statements that are true or false (e.g., "It is raining", "I am in Glasgow") and their combination by connectives such as 'and', 'or', 'not', and 'implies'. Propositional Logic is not a very expressive logic, for example it is not possible to directly express relationships between things, but it is useful in its own right, as we shall see.

1. [Syntax](prop-logic-syntax.html): what are the valid sequences of symbols that we can write down? Which ones are logical formulas?

2. [Semantics](prop-logic-semantics.html): what do those symbols mean? What do formulas made from the symbols mean?

3. [Truth Tables, Satisfiability, and Validity](truth-tables.html): An effective way to compute the meaning of a logical formula, and two kinds of statements we can make about a formula.

```comment
2. [Beyond the binary: Three-valued Logic](three-valued-logic.html). We will primarily study *two*-valued logic (`true` and `false`), but what if we have more than two truth values?
```

FIXME: tutorial questions

### Topic 1: Deductive Proof

Lectures
- Friday 26th September 2025

[The slides for this lecture](topic01-slides.pdf)

1. [Entailment](entailment.html): A generalised form of validity. What does it mean to say a formula is true under some assumptions?

2. [Introduction to Deductive Proof](proof-intro.html), which describes the general idea of proof systems, and introduces a small example of a proof system inspired by biology.

### Topic 2: Proof for Propositional Logic

Lectures
- Friday 3rd October 2025
- Monday 6th October 2025

[The slides for these lectures](topic02-slides.pdf)

FIXME: Some introductory text

1. [Natural Deduction and the rules for And](natural-deduction-intro.html). Natural Deduction is a style of proof system that places a particular emphasis on how assumptions are used, and on how the rules for each connective come in introduction and elimination pairs.

2. [Proof rules for Implication](proof-implication.html). Implication allows us to make conditional statements that we prove by temporarily making assumptions.

3. [Proof rules for Or and Not](proof-or.html), which complete the rules for the connectives of Propositional Logic.

4. [Soundness and Completeness, and some Philosophy](sound-complete-meaning.html). The system so far is sound, but is it complete? Should it be complete? What does mathematics mean?

### Topic 3: Predicate Logic

Lectures
- Friday 10th October 2025
- Monday 13th October 2025

[Slides for these lectures](topic03-slides.pdf)

1. [Introducing Predicate Logic](pred-logic-intro.html) as an expressive language for making statements in a formalised way. By selecting our vocabulary carefully, we can use Predicate Logic as a modelling tool to describe many situations. FIXME: EXERCISES!

2. [Scoping and Substitution](scope-and-substitution.html). Before we look at proof for Predicate Logic, we need to upgrade our Natural Deduction system to handle assumptions about entities as well as propositions. This brings us to the matters of *scope* and *substitution*.

### Topic 4: Proof Rules for Predicate Logic

Lectures
- Friday 17th October 2025
- Monday 20th October 2025

[Slides for these lectures](topic04-slides.pdf)

1. [Proof rules for Predicate Logic](pred-logic-rules.html). Natural deduction rules for “for all” and “exists” allow us to construct proofs of Predicate Logic formulas.

2. [Equality](equality.html). How do we prove that one thing is equal to another thing? And what can we prove if we know that one thing is equal to another thing?

### Topic 5: Program Specification and Verification

Lectures
- Friday 24th October 2025
- Monday 27th October 2025

1. **Under construction** [Specifying Properties of Programs](properties-of-programs.html). We can use predicate logic to make precise some statements we can make about programs and how they execute.

### Topic 6: Programs with Loops

Lectures
- Friday 31st October 2025
- Monday 3rd November 2025

### Topic 7: Programs with Arrays

Lectures
- Friday 7th November 2025
- Monday 10th November 2025

### Topic 8: Models

Lectures
- Friday 14th November 2025
- Monday 17th November 2025

[Slides for these lectures](topic08-slides.pdf)

1. **Under construction** [Predicate Logic Semantics](pred-logic-semantics.html). A break from proof for a bit to consider what Predicate Logic formulas are talking about. It is not just about true and false anymore, but about relationships between individuals.

### Topic 9: Automation

Lectures
- Friday 21st November 2025
- Monday 24th November 2025

1. Decision Procedures for Propositional Logic
2. Decision Procedures for Predicate Theories

### Topic 10: Undecidability

Lectures
- Friday 28th November 2025

1. [Undecidability of the Halting Problem](halting-problem.html). One of the foundational results of Computer Science is that there is no program which can reliably tell if another program will halt on a given input. This page goes through a formal proof of this fact.

2. [Metatheory and Gödel's Incompleteness Theorem](metatheory-automation.html). If we as humans can construct proofs, then could we get a computer to do it? What are the limits of what we can prove?




## Old Material

The material below is from previous versions of this course, and is kept for reference purposes.

### Logical Modelling

In Part 1, we use logical modelling to describe and solve problems.

1. [Introduction](logical-modelling-intro.html) to Logical Modelling and the Logical Modelling tool.

2. [The Wizard's Pets](wizards-pets.html), introducing some common kinds of constraints through a toy example.

3. [Patterns](patterns.html) for writing logical constraints.

4. [A fruity exercise](fruit-exercise.html) for you to do.

5. [The Package Installation Problem](packages.html).

6. [How to handle bigger problems](domains-and-parameters.html) with domains and parameters.

7. [An exercise on Package Installations](packages-exercise.html).

8. [SAT solvers](sat.html), the underlying technology.

9. [Resource allocation problems](resource-alloc.html), which are a kind of graph colouring problem.

10. [Converting to CNF](converting-to-cnf.html). SAT solvers take their input in CNF. Some problems are naturally in CNF (like the Packages or Resource Allocation problems above), but sometimes we need to convert any formula to one in CNF.

11. [Circuits, Gates and Formulas](circuits.html), where we look at encoding logic gates as clauses, using the Tseytin transformaion. We can then get the solver to answer questions about circuits. We also look at a use of circuits to solve problems that are hard to solve directly.

### Part 2: Deductive proof and Predicate Logic

1. [Arithmetic and Induction](induction.html). Induction allows us to prove facts about infinitely many individuals, as long as those individuals are built up in a “well founded” way. We look specifically at induction on natural numbers, which will allow us to prove facts in the theory of arithmetic as described by Peano's axioms.
