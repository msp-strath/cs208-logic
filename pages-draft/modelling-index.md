# Pages on Slakemoth, the Logical Modelling Tool

We use logical modelling to describe and solve problems.

1. [Introduction](logical-modelling-intro.md) to Logical Modelling and the Logical Modelling tool.

2. [The Wizard's Pets](wizards-pets.md), introducing some common kinds of constraints through a toy example.

3. [Patterns](patterns.md) for writing logical constraints.

4. [A fruity exercise](fruit-exercise.md) for you to do.

5. [The Package Installation Problem](packages.md).

6. [How to handle bigger problems](domains-and-parameters.md) with domains and parameters.

7. [An exercise on Package Installations](packages-exercise.md).

8. [SAT solvers](sat.md), the underlying technology.

9. [Resource allocation problems](resource-alloc.md), which are a kind of graph colouring problem.

10. [Converting to CNF](converting-to-cnf.md). SAT solvers take their input in CNF. Some problems are naturally in CNF (like the Packages or Resource Allocation problems above), but sometimes we need to convert any formula to one in CNF.

11. [Circuits, Gates and Formulas](circuits.md), where we look at encoding logic gates as clauses, using the Tseytin transformaion. We can then get the solver to answer questions about circuits. We also look at a use of circuits to solve problems that are hard to solve directly.
