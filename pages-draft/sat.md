# SAT solvers

As we saw in [the Package Installation Problem](packages.html), if we had a way of efficiently finding satisfying valuations for large logical formulas, we would have a way of efficiently computing working combinations of installed packages. We will see some further examples in later pages.

There are so many problems that would be solvable if there were efficient ways of finding satisfying valuations that considerable effort has been spent on finding ways to do this. Programs that find satisfying valuations are known a SAT solvers.

Unfortunately, there is a stumbling block. The problem of finding satisfying valuations is *NP-complete*.

"NP" refers to the class of problems that are solvable in *Non-deterministic Polynomial time*. These are problems that if we were able to guess the answer (using the non-determinism, which in this context means that if we have a choice we can try both and keep the one that works) then we could check it in polynomial time.

Satisfiability is in this class: if we guess a valuation `v`, we can check it quickly by computing `[[P]]v` using the steps we saw in Week 1.  However, if we can't guess a satisfying valuation there is currently no known *general* strategy better than trying all of them, which takes an amount of time exponential in the size of the input.

The question of whether or not there is a general strategy that works in polynomial time is known as the P = NP problem, which is a famous major unsolved problem in Computer Science. Finding satisfying valuations is also NP-*complete*, which means that a polynomial time solution to this problem would give a polynomial time solution to all NP problems.

Despite there being no known *general* solution that is better than trying every possible valuation, there has been great progress on SAT solvers that do well on problems that arise in the ``real world'' like the ones listed above. Formulas that are generated from real world problems often have a large amount of regularity that it is possible for a SAT solver to exploit to avoid searching every possible valuation.

## Video introduction to SAT Solvers

[Slides for these videos](week02-slides.pdf).

### SAT Solvers, introduction

The first video describes how SAT solvers work:

1. They take input in the form of clauses in *Conjunctive Normal Form* (CNF).
2. They try to find a satisfying valuation by building up *partial valuations*
   1. Initial guesses are made
   2. If these guesses don't work out, then the solver must *backtrack*
3. If the solver finds a satisfying valuation, then it returns `SAT` (and the valuation). If it fails and no more backtracking is available, then it returns `UNSAT`.

```youtube
54uXgP0kEjg
```

### Making SAT Solvers faster with Unit Propagation

The second video describes how to make SAT solvers go faster by using information from the clauses to be solved, in a process called "Unit Propagation". This can considerably speed up a solver:

```youtube
93RGN9PAqQQ
```

## PDF Notes

[Written notes on SAT solvers](sat-solver-notes.pdf). These cover the same material as the videos.

## Further Reading

The videos above describe how a relatively simple SAT solver works. Real ones incorporate many more techniques to heuristically guess which atoms to guess values for next, and to do more learning from conflict states as the search proceeds. Low-level implementation techniques are also very important to achieve good memory efficiency and speed.

The blog post [Understanding SAT by Implementing a Simple SAT Solver in Python](https://sahandsaba.com/understanding-sat-by-implementing-a-simple-sat-solver-in-python.html) describes the implementation of a slightly more complex (and efficient) SAT solver in Python. It gives a flavour of the kinds of data structures used in real SAT solvers.

An example industrial strength SAT solver is [Picosat](http://fmv.jku.at/picosat/). This is a “industrial strength” SAT solver that is also designed to have a small(ish) implementation in C.

There is also a [Python interface](https://github.com/ContinuumIO/pycosat) to Picosat which means that you can build up collections of constraints in a Python program via the API, instead of using a logical modelling tool like we do here. The Pycosat repository gives a [Python implementation](https://github.com/ContinuumIO/pycosat/blob/master/examples/opium.py) of the [Package Installation Problem](packages.html).

[SAT4j](http://sat4j.org/) is a SAT solver written in pure Java that is easy to use from a Java program.

The SAT solver used in the Logical Modelling Tool embedded in these pages is [mSat](https://github.com/Gbury/mSAT) which is written in [OCaml](https://ocaml.org) and compiled to JavaScript for these pages via [Js\_of\_ocaml](https://ocsigen.org/js_of_ocaml/latest/manual/overview).

For more depth and breadth than is imaginable, this sub-sub-sub-section of The Art of Computer Programming covers SAT Solving algorithms in detail: [The Art of Computer Programming: 7.2.2.2 Satisfiability](https://cs.stanford.edu/~knuth/fasc6a.ps.gz) (You will need a program capable of hanlding PostScript files, e.g. `evince` on Linux). Several different algorithms are given and compared on many examples, and their runtime characteristics are studied. *Caution:* reading this requires a lot of time and patience, it is a rewarding but not easy read.
