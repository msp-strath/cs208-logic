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

-  Topic 6 is **Programs with Loops**.

   [Assertions and Automation](hoare-assert-and-auto.md) introduces some tools for controlling complexity when constructing proofs of programs. In particular, we add human assisted proof automation to our proof tool.

   [Hoare Logic for Loops](hoare-loops.md) introduces the Hoare Logic rule for loops, and the important concept of *loop invariant*.

   There are no lecture slides for this topic.

-  Topic 7 is **Programs with Arrays**.

   [Hoare Logic for Arrays](hoare-arrays.md) describes how to use Hoare Logic to reason about programs that access and update array data structures. In doing so, we come up against the problem of *aliasing*, that complicates reasoning about any program that combines references with mutability.

   There are no lecture slides for this topic. Lectures will all be live coding demonstrations.

-  Topic 8 is **Semantics of Predicate Logic**.

   The [semantics of Predicate Logic](pred-logic-semantics.md) is inevitably more complex than the semantics of Propositional Logic that we looked at in Topic 0. A useful way to think about how formulas are interpreted is in terms of *databases* as you will see in CS209.

   [Lecture slides for this topic](topic08-slides.pdf).

-  Topic 9 is **Automating Logic**.

   [SAT Solvers](sat.md) are a class of tool that can solve very large problems in Propositional Logic, and are used as a foundation for building tools that can solve problems in Predicate Logic. They use heuristic search techniques to try to avoid exponential runtime behaviour.

   [Lecture slides for this topic](topic09-slides.pdf).

-  Topic 10 will be **Undecidability**.

## Further Reading {id=index:further-reading}

The following books and online resources may be useful if you wish to read more about the topics in this course. The links go to either the material itself if is available online, or the author's or the publisher's web pages. You might be able to find them cheaper at well-known online retailers, or in the University library.

Two books that are recommended:

1. [Logic in Computer Science](https://www.cambridge.org/highereducation/books/logic-in-computer-science/9022E2BE5E7C9F20D259F4A83986236C#overview) by Michael Huth and Mark Ryan. The first two chapters cover Propositional Logic and Predicate Logic as we have done them in this course. They also give a natural deduction system for proof, but in a slightly different form to the one used here. Chapter 4 covers Hoare Logic for partial and total correctness. The book also contains chapters on Temporal Logic and Model checking, which we have not had time to cover in this course.

2. [Mechanizing Proof](https://direct.mit.edu/books/monograph/2641/Mechanizing-ProofComputing-Risk-and-Trust) by Donald MacKenzie. This is not a technical book. It is a sociological history of the idea of doing proofs on computers and about computer hardware and software. Recommended to get a perspective on why the world of software is the way it is.

There are many software tools for doing interactive proofs with logic that are like the tool we have used in this course, but which allow much larger . The following links are to material for learning various provers and other logic tools. There are many more.

1. The [Rocq prover](https://rocq-prover.org) (formerly known as Coq) is an industrial strength interative theorem prover that has been used for proofs about software and for research in Computer Science and  Mathematics. A major project in Rocq is the [CompCert](https://compcert.org/) verified C compiler. The free online book [Software Foundations](https://softwarefoundations.cis.upenn.edu/) is an introduction to using Rocq for verifying software.

2. The [Lean prover](https://lean-lang.org) is an interactive theorem prover that is more tightly focused on mathematics. There is currently underway a project to prove [Fermat's Last Theorem](https://github.com/ImperialCollegeLondon/FLT) is Lean.

3. The [Agda prover](https://agda.readthedocs.io/en/v2.8.0/) is another interactive prover than is more like a programming language similar to Haskell that you will using in CS260. The [CS410 Advanced Functional Programming](https://github.com/msp-strath/cs410-advanced-functional-programming/) course in 4th year uses Agda. There is an online introductory textbook [Programming Language Foundations in Agda](https://plfa.github.io/) that serves as a gentle introduction.

4. The [Idris programming language](https://www.idris-lang.org/) is a programming language that has theorem proving features.

5. [Dafny](https://dafny.org/) is a programming language and verification environment that is a fully fleshed out version of the [Hoare Logic](hoare-logic.md) tool that you have been using in this course.

6. [Why3](https://www.why3.org/) is another more capable version of the Hoare Logic tool, focused a bit more on research applications.

7. The book [Software Abstractions](https://softwareabstractions.org/) by Daniel Jackson describes the [Alloy tool](https://alloytools.org/) for building logical models of software systems. If can be used to build and model relatively complex software systems and find design bugs in them.

Formal Logic has its roots in Philosophy. There are many books aimed at Philosophy students that are interesting to read to learn about the assumptions underlying logic. Some good ones are:

1. [The Logic Manual](https://users.ox.ac.uk/~logicman/) by Volker Halbach. This is am introduction to formal logic, intended primarily for Philosophy students. It covers Propostiional and Predicate Logic with Natural Deduction proofs, but does not explore applications to Computer Science. It does discuss the connections between formal logic and natural language.

2. [Logical Methods](https://mitpress.mit.edu/9780262544849/logical-methods/) by [Greg Restall](https://consequently.org/) and Shawn Standefer. Also a textbook introduction to formal logic intended for Philosophy students. Covers more topics that *The Logic Manual*, including Modal Logic.

3. [Proofs and Models in Philosophical Logic](https://www.cambridge.org/core/elements/abs/proofs-and-models-in-philosophical-logic/A1907B05C24E1000270CC5B684FA7AAB) by [Greg Restall](https://consequently.org/). More advanced than *Logical Methods*, and includes topics on “non-classical” logics that reject certain principles from the normal two-valued logic.

4. [forall x: Calgary](https://forallx.openlogicproject.org/) by P. D. Magnus, Tim Button, Robert Trueman, and Richard Zach. This is an open textbook on formal logic, again primarily for Philosophy students. It uses the [Carnap](https://carnap.io/) system for building proofs in a web browser, which is another tool for constructing proofs. See the [Carnap book](https://carnap.io/book).

Finally, the study of logic itself is interesting in its own right, and leads to deep connections to computability and results like Gödel's Incompleteness Theorem. The main textbook for this material is:

1. [Computability and Logic](https://www.cambridge.org/core/books/computability-and-logic/440B4178B7CBF1C241694233716AB271) by George S. Boolos, John P. Burgess, and Richard C. Jeffery.
