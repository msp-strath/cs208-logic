[Contents](contents.html)

# Introduction to Logical Modelling

These pages are an introduction to Logical Modelling with SAT solvers, and the Logical Modelling tool that we will be using to experiment with the technique.

The Logical Modelling tool runs in your browser. Its purpose is to allow you to write logical constraints to represent problems and get the computer to solve them for you.

## What is Logical Modelling?

Logical Modelling is a technique for solving problems where:

1. Potential solutions to a problem can be encoded using a fixed set of boolean variables (the number of variables may depend on the actual problem to be solved, but we assume that the size of answer can be predicted from each instance of the problem).
2. The conditions that we want the solutions to satisfy are expressible as logical formulas.

If both of these assumptions are satisfied, then we can use a computer to automatically solve these problems for us. Example problems of this kind include:

1. Resource allocation problems, where we have (for example) `N` tasks to assign to `M` machines with some constraints on which tasks can run on which machines.
2. Package installation problems, where some packages are incompatible with others, or some packages depend on others.
3. Circuit checking, such as checking to see if two circuits are equivalent.
4. Checking access control rules.
5. Puzzle games, like Sudoku.

It can take some ingenuity to come up with ways of encoding potential solutions into Boolean variables. However, there are a number of techniques that we can use over and over again to help us.

## The Logical Modelling Tool

For this introduction, we will use a tool embedded in these pages to describe problems and get the computer to solve them.

Here is a small example to play with. You can edit the code to see what happens.

```lmt
// Define two atoms
atom a
atom b

define my_constraints {
  (a | b) &    // a OR b must be TRUE
  (~a | ~b)    // NOT (a AND b) must be TRUE
}

allsat (my_constraints)
  { "a" : a, "b" : b }
```

The example explained:

1. The lines `atom a` and `atom b` declare two new atomic propositions `a` and `b`, which we will use. Remember that atom propositions are things that can be either true or false.
2. The `define my_constraints` defines a new collection of constraints called `my_constraints`. This consists of two logical constraints:
   1. At least one of `a` and `b` must be true
   2. At most one of `a` and `b` must be true (expressed as "at least one is false")
3. Finally the `allsat (my_constraints)` asks the computer to compute all possible values of `a` and `b` that satisfy the constraints. The `{ "a" : a, "b" : b }` specifies that we would like the result to be formatted as a record with two fields `"a"` and `"b"` that contain the values of the atoms `a` and `b` respectively.

Click on **Run** to run the example. There should be two answers, one with `a` true and `b` false, and one the other way round.

For a longer introduction to the tool and how to use it see [The Wizard's Pets](wizards-pets.html).


---

[Contents](contents.html)
