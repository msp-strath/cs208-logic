This page links to the interactive notes and exercises for Logic part of [CS208 Logic & Algorithms](https://classes.myplace.strath.ac.uk/course/view.php?id=15121), part of the Undergraduate BSc (Hons) and MEng Computer Science and BSc (Hons) Software Engineering degrees at the [University of Strathclyde](https://www.strath.ac.uk/science/computerinformationsciences/).

Please send any comments, queries, or corrections to [Robert Atkey](mailto:robert.atkey@strath.ac.uk) ([Web page](https://bentnib.org)). The source code for these pages is available [on Github](https://github.com/msp-strath/cs208-logic).

## Introduction {id=index:introduction}

In the first semester of CS208, we will study Symbolic Logic. Symbolic Logic is a fundamental set of techniques for describing situations, reasoning, data, and processes. It is useful in computing for describing, building, and checking systems, and for solving complicated problems involving many interacting constraints. We will look at how to define logic (syntax and semantics), algorithms for computing with logic, and systems for deriving proofs in formal logic. We will also keep in mind the practical uses of logic in Computer Science.

This course follows on from CS103 and CS106 in first year.

Please see the [MyPlace page](https://classes.myplace.strath.ac.uk/course/view.php?id=15121) (Strathclyde students only) for information on Lectures, Tutorials, and Assessment.

## Learning Outcomes {id=index:learning-outcomes}

By the end of semester 1 of the module you should be able to:

- Understand the meaning of formulas of Propositional and Predicate Logic
- Construct proofs of formulas in Propositional and Predicate Logic
- Understand how to specify and verify programs using assertions and loop invariants
- Understand the concept of proof automation and its limits

## Topics {id=index:topics}

The course is split into 11 topics, numbered 0 to 10. Each topic corresponds to roughly a week's worth of the course.

The pages linked to below contain the lecture notes, covering the material introduced in the lectures. They also contain interactive exercises for you to do.

-  Topic 0 is a (re)introduction to the basic concepts of **Propositional Logic**.

   We look at the syntax of Propositional Logic (what are the formulas?) and the semantics (what do the formulas mean?).

   Propositional Logic is concerned with statements that are true or false (e.g., “It is raining”, “I am in Glasgow”) and their combination by connectives such as 'and', 'or', 'not', and 'implies'. Propositional Logic is not a very expressive logic, for example it is not possible to directly express relationships between things, but it is useful in its own right, as we shall see.

   1. [Syntax](prop-logic-syntax.md): what are the valid sequences of symbols that we can write down? Which ones are logical formulas?

   2. [Semantics](prop-logic-semantics.md): what do those symbols mean? What do formulas made from the symbols mean?

   3. [Truth Tables, Satisfiability, and Validity](truth-tables.md): Truth tables are an effective way to compute the meaning of a logical formula. Satisfiability and Validity are two categorisations we can make about a formula.

   4. An [extended exercise sheet on Three-valued logic](tutorial-0-three-valued.md).

   [The lecture slides for this topic](topic00-slides.pdf).

-  Topic 1 is **Entailment** and **Deduction**.

   1. [Entailment](entailment.md): A generalised form of validity. What does it mean to say a formula is true under some assumptions?

   2. [Introduction to Deductive Proof](proof-intro.md), which describes the general idea of proof systems, and introduces a small example of a proof system inspired by biology.

   [The lecture slides for this topic](topic01-slides.pdf).

-  Topic 2 is **Proof for Propositional Logic**.

   [Natural Deduction](natural-deduction-intro.md). Natural Deduction is a style of proof system that places a particular emphasis on how assumptions are used, and on how the rules for each connective come in introduction and elimination pairs.

   [The lecture slides for this topic](topic02-slides.pdf).

- Topic 3 is **Predicate Logic**.

  [Introducing Predicate Logic](pred-logic-intro.md) as an expressive language for making statements in a formalised way. By selecting our vocabulary carefully, we can use Predicate Logic as a modelling tool to describe many situations. The syntax of Predicate Logic is more complex that that of Proposition Logic, so this page introduces it, with the concepts of free and bound variables and substitution.


   [The lecture slides for this topic](topic03-slides.pdf).

-  Topic 4 is **Proof for Predicate Logic**.

   [Proof rules for Predicate Logic](pred-logic-rules.md). Natural deduction rules for “for all” and “exists” allow us to construct proofs of Predicate Logic formulas. Also, how do we prove that one thing is equal to another thing? And what can we prove if we know that one thing is equal to another thing?

   [The lecture slides for this topic](topic04-slides.pdf).


-  Topic 5 is **Specification and Verification**.

   [Specification and Verification](specify-verify.md) introduces the topic of how we say what we want programs to do, and how we might go about proving those things. We look at a simple model of programs in which we can state some properties of programs.

   The [page on Hoare Logic](hoare-logic.md) introduces Hoare Logic, a logic for proving specifications of programs, demonstrates its use on programs without loops.

   [The lecture slides for this topic](topic05-slides.pdf).

-  Topic 6 will be **Programs with Loops**.

-  Topic 7 will be **Programs with Arrays**.

-  Topic 8 will be **Semantics of Predicate Logic**.

-  Topic 9 will be **Automating Logic**.

-  Topic 10 will be **Undecidability**.

## Further Reading {id=index:further-reading}

TBD...
