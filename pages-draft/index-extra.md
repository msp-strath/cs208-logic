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
