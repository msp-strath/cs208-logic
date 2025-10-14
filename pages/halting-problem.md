# The Undecidability of the Halting Problem

```aside
This page assumes that you have understood the [proof rules for quantifiers](pred-logic-rules.html) and [proof rules for equality](equality.html) pages and completed all the exercises there. This page also builds on the [Specification of Program Properties](properties-of-programs.html).
```

One of the foundational results of Computer Science is that there is no program which can reliably tell if another program will halt on a given input.

This page presents a formal proof of this fact.

The unsolvability of the halting problem means that we can't (for most programming languages) write programs that will soundly and completely automatically check a program for some property. E.g.:

1. Will this program ever output 1?
2. Will this program ever output a number between 0 and 100?
3. Will this program ever issue an instruction to launch the nuclear missles?

If we could solve any of these, we can also solve the halting problem by wrapping the program under test with a test to see if it does do the thing we are looking for and looping indefinitely if it does. Then if our halting problem solution says “halts” then we know that the program doesn't have the behaviour we are looking for.

The proof of undecidability is an example of a *diagonalisation* proof, where we prove that a solution cannot exist by assuming that a solution exists and using it *on itself* to construct a contradiction.

## Vocabulary

### Ways of Building Programs and Data

The following function symbols give us ways of building programs and data values.

1. `true()`, `false()`, `loop()` are all basic programs that ignore their input and (a) return `true`, (b) return `false`, (c) loop forever producing no answer.
2. `pair(x,y)` represents a pair of data items `x` and `y`. We will model programs taking multiple inputs by giving them inputs as pairs.
3. `duplicate(p)` is a program that duplicates its input `x` to a pair `pair(x,x)`, and then executes as the program `p` with that pair as input.
4. `if(p1, p2, p3)` is a program that runs `p1` on the input, if `p1` returns `true` then it runs `p2` and if `p1` returns `false` then it runs `p3`.

We will only need to assume this minimal set of function symbols for building programs to prove that the halting problem is undeciable. We do **not** say in our axiomatisation below that these are the only ways of building programs, only that the underlying model of computation must have **at least** these ways of constructing programs.

### The Execution Predicate

We use the execution predicate we was when [specifying properties of programs](properties-of-programs.md):

1. `exec(program, input, output)` -- meaning that when we run `program` on `input` the result is `output`.

We do not distinguish between things that are program-like and things that are data-like. In particular, a program can take itself as an input. This flexibility of self reference will be crucial for stating the halting problem and proving that it is undecidable.

## Axioms

Next we have axioms that tell us how each of the different kinds of program executes. We'll not actually need all of these axioms to complete the proof of the undecidability of the halting problem, but they serve to show how one can use logic to specify how programs execute.

These axioms are meant to establish some basic properties of computation that any realistic kind of programs ought to satisfy: we can output fixed values, duplicate data, not give answers, and make decisions.

### The `true` and `false` programs

The program `true()` outputs `true()` for any input:
```formula
all x. exec(true(), x, true())
```
and if it outputs anything, then that thing is equal to `true()`:
```formula
all x. all y. exec(true(), x, y) -> y = true()
```

Similarly, `false()` outputs `false()` for any input:
```formula
all x. exec(false(), x, false())
```
and if it outputs anything, then that thing is equal to `false()`:
```formula
all x. all y. exec(false(), x, y) -> y = false()
```

### The `loop` program

The program `loop` never outputs anything:
```formula
   all x. all y. ¬exec(loop(), x, y)
```

### The `duplicate` program

The program `duplicate(p)` acts like I said above:
```formula
all p. all x. all y. exec(p,pair(x,x),y) -> exec(duplicate(p),x,y)
```
and this is the only way it acts:
```formula
all p. all x. all y. exec(duplicate(p),x,y) -> exec(p,pair(x,x),y)
```

### The `if` program

The program `if(p1,p2,p3)` acts like I said above. We split into two cases, one for when the condition `p1` returns `true`:
```formula
all p1. all p2. all p3. all x. all y. exec(p1,x,true()) -> exec(p2,x,y) -> exec(if(p1,p2,p3),x,y)
```
and one when the condition returns `false`:
```formula
all p1. all p2. all p3. all x. all y. exec(p1,x,false()) -> exec(p3,x,y) -> exec(if(p1,p2,p3),x,y)
```
We also need to specify that this is the only way that `if` executes:
```formula
all p1. all p2. all p3. all x. all y. exec(if(p1,p2,p3),x,y) ->
  ((exec(p1,x,true()) /\ exec(p2,x,y)) \/ (exec(p1,x,false()) /\ exec(p3,x,y)))
```

### Explanation

Why do we need “both directions” for the axioms for `duplicate` and `if`? This is because we are going to have to reason backwards about program execution to answer questions like “if the output was `y`, then what happened during the program?”.

## What does it mean for a program to halt?

As we saw when [Specifying Properties of Programs](properties-of-programs.md), we can use the `exec` predicate to define what it means for a program to halt. A program `prog` halts on an input `x` if there exists an answer `y` that executing `prog` with input `x` gives the output `y`:

```formula
ex y. exec(prog,x,y)
```

## What does it mean for a program to solve the halting problem?

To specify when we have a program that solves the halting problem, we use a predicate `solution(p)`. Any solution must satisfy the following four properties, so we say that `solution(p)` implies each one:

1. A solution must always say “true” or “false”:

   ```formula
   all p. solution(p) -> (all q. all x. exec(p,pair(q,x),true()) \/ exec(p,pair(q,x),false()))
   ```

2. A solution must never say “true” and “false”:

   ```formula
   all p. solution(p) -> (all q. all x. exec(p,pair(q,x),true()) -> exec(p,pair(q,x),false()) -> F)
   ```

   Any program that satisfies these two properties is a *decision procedure*: a program that decides whether or not the input is in some set. The next two properties define what set this is.

3. If a solution says “true” for a given `p` and `x`, then executing `p` on `x` halts:

   ```formula
   all p. solution(p) -> (all q. all x. exec(p,pair(q,x),true()) -> (ex y. exec(q,x,y)))
   ```

4. If a solution says “false” for a given `p` and `x`, then executing `p` on `x` does not halt (i.e. loops):

   ```formula
   all p. solution(p) ->
     (all q. all x. exec(p,pair(q,x),false()) -> ¬(ex y. exec(q,x,y)))
   ```

Some notes on this specification:

1. Any solution to the halting problem always halts.

   If we didn't have this property, then there is an easy solution to the halting problem: run the program and if it halts then output `true`, otherwise never give an answer.

2. We do not only say that if the solution says `true` then the input halts, we also state the opposite property for `false`. This rules out “solutions” to the halting problem that always say `false`, or underestimate the cases when the input halts. In practice, because the halting problem is undecidable, this is in fact what we have to do. We'll discuss mitigations of undecidability at the end of this page.

## What if we had a solution to the Halting Problem?

If we had a solution to the halting problem, then we could use it to make larger programs.

One program we can make is the following. Let's say we have a solution `p` to the halting problem, then we could make the following program (in pseudocode):

```
define spoiler(x):
  if(p(x,x)):
    loop-forever
  else:
    return true
```

So this program takes an input `x` and asks `p` whether or not `x` will halt when given itself as an input. If `p` says “true”, then it loops forever; if `p` says “false”, then it returns “true”. We'll prove these facts formally from the axioms below.

We call this program `spoiler` because we can use it to prove that there cannot be any solution to the halting problem.

We can write this program in the format described above like so:

```formula
if(duplicate(p),loop(),true())
```

### Solution says “loops”, then spoiler halts

Conversely, we can prove from the axioms that, if the solution `p` says “false” then the spoiler program does halt:

The proof goes like this:

1. We assume that `p` says `false()` when presented with program `x` and input `x`. If `p` is a solution to the halting problem, then this means that `x` **does not** halt on the input `x`.
2. Using the axioms for `if`, `duplicate` and `true`, we can then replay our informal reasoning above that the spoiler program **does** halt, with output `true()`.

```focused-nd {id=haltingproblem-2}
(config
 (assumptions
  ; execution axioms
  (exec-true1 "all x. exec(true(), x, true())")
  (exec-dup1 "all p. all x. all y. exec(p,pair(x,x),y) -> exec(duplicate(p),x,y)")
  (exec-if1false
   "all p1. all p2. all p3. all x. all y.
    exec(p1,x,false()) ->
	exec(p3,x,y) ->
	exec(if(p1,p2,p3),x,y)")
)
 (goal
  "all p. all x. solution(p) -> exec(p,pair(x,x),false()) ->
    (ex y. exec(if(duplicate(p),loop(),true()),x, y))")
 (solution (Rule(Introduce p)((Rule(Introduce x)((Rule(Introduce solution-p)((Rule(Introduce p-says-false)((Rule(Exists(Fun true()))((Rule(Use exec-if1false)((Rule(Instantiate(Fun duplicate((Var p))))((Rule(Instantiate(Fun loop()))((Rule(Instantiate(Fun true()))((Rule(Instantiate(Var x))((Rule(Instantiate(Fun true()))((Rule Implies_elim((Rule(Use exec-dup1)((Rule(Instantiate(Var p))((Rule(Instantiate(Var x))((Rule(Instantiate(Fun false()))((Rule Implies_elim((Rule(Use p-says-false)((Rule Close())))(Rule Close())))))))))))(Rule Implies_elim((Rule(Use exec-true1)((Rule(Instantiate(Var x))((Rule Close())))))(Rule Close())))))))))))))))))))))))))))))
```

### Solution says “halts”, then spoiler loops

We can prove formally from the axioms that, if the solution `p` says “true” then the spoiler program does not halt:

The proof goes like this:

1. We assume that `p` says `true()` when presented with the program `x` and input `x`. If `p` is a solution to the halting problem, then this means that `x` **does** halt on the input `x`.
2. Using the *reverse* axioms for `if`, `duplicate`, and `loop`, we can again replicate our informal reasoning to show that the spoiler program **does not** halt.

```focused-nd {id=haltingproblem-1}
(config
 (assumptions
  ; execution axioms
  (exec-loop "all x. all y. ¬exec(loop(), x, y)")
  (exec-dup2 "all p. all x. all y. exec(duplicate(p),x,y) -> exec(p,pair(x,x),y)")
  (exec-if2
   "all p1. all p2. all p3. all x. all y.
    exec(if(p1,p2,p3), x, y) ->
	((exec(p1,x,true()) /\ exec(p2,x,y)) \/ (exec(p1,x,false()) /\ exec(p3,x,y)))")

  ; What does being a solution mean?
  (solution-never-says-true-and-false
   "all p. solution(p) -> (all q. all x. exec(p,pair(q,x),true()) -> exec(p,pair(q,x),false()) -> F)")
)
 (goal
  "all p. all x. solution(p) -> exec(p,pair(x,x),true()) ->
    ¬(ex y. exec(if(duplicate(p),loop(),true()),x, y))")
 (solution (Rule(Introduce p)((Rule(Introduce x)((Rule(Introduce solution-p)((Rule(Introduce p-says-true)((Rule(NotIntro spoiler-halts)((Rule(Use spoiler-halts)((Rule(ExElim y spoiler-executes)((Rule(Use exec-if2)((Rule(Instantiate(Fun duplicate((Var p))))((Rule(Instantiate(Fun loop()))((Rule(Instantiate(Fun true()))((Rule(Instantiate(Var x))((Rule(Instantiate(Var y))((Rule Implies_elim((Rule(Use spoiler-executes)((Rule Close())))(Rule(Cases case-true case-false)((Rule(Use exec-loop)((Rule(Instantiate(Var x))((Rule(Instantiate(Var y))((Rule NotElim((Rule(Use case-true)((Rule Conj_elim2((Rule Close())))))))))))))(Rule(Use solution-never-says-true-and-false)((Rule(Instantiate(Var p))((Rule Implies_elim((Rule(Use solution-p)((Rule Close())))(Rule(Instantiate(Var x))((Rule(Instantiate(Var x))((Rule Implies_elim((Rule(Use p-says-true)((Rule Close())))(Rule Implies_elim((Rule(Use exec-dup2)((Rule(Instantiate(Var p))((Rule(Instantiate(Var x))((Rule(Instantiate(Fun false()))((Rule Implies_elim((Rule(Use case-false)((Rule Conj_elim1((Rule Close())))))(Rule Close())))))))))))(Rule Close())))))))))))))))))))))))))))))))))))))))))))))))
```

## Undecidability of the Halting Problem

Given these two facts we have proved about the spoiler program, we can now prove that there can be *no* solution to the halting problem. The proof goes like this:

1. To prove that there cannot be a solution, we assume that there is a solution `p` and prove `F` (“false” as a logical proposition) to show that there is a contradiction.
2. Since `p` is a solution it must either say “true” or “false” when given the spoiler program as *both the program and its input*. This means the proof splits into two cases:

   1. If `p` says “true”, then we know that:

      1. The spoiler program **must** halt when given itself as an input, because `p` is a solution to the halting problem; and
	  2. The spoiler program **must not** halt when given itself as an input, because `p` said “true” so we can use the first result above.

	  We cannot have that a program both halts and does not halt, so we can prove `F`.

   2. If `p` says “false”, then we know that:

      1. The spoiler program **must not** halt when given itself as an input, because `p` is a solution to the halting problem; and
      2. The spoiler program **must** halt when given itself as an input, because `p` said “false” so we can use the second result above.

	  We cannot have that a program both halts and does not halt, so we can prove `F`.

   We have proved `F` in both branches of the proof, so we have a contradiction. The only assumption we made (apart from our basic assumptions about programs) is that there is a solution to the halting problem. So it must be impossible for such a solution to exist.

We can carry this proof out formally from our axioms of computation and the two results we proved above:

```focused-nd {id=haltingproblem-3}
(config
 (assumptions
  ; What does being a solution mean?
  (solution-says-true-or-false
   "all p. solution(p) ->
    (all q. all x. exec(p,pair(q,x),true()) \/ exec(p,pair(q,x),false()))")
  (solution-never-says-true-and-false
   "all p. solution(p) -> (all q. all x. exec(p,pair(q,x),true()) -> exec(p,pair(q,x),false()) -> F)")
  (solution-true-means-halts
   "all p. solution(p) -> (all q. all x. exec(p,pair(q,x),true()) -> (ex y. exec(q,x,y)))")
  (solution-false-means-doesnt-halt
   "all p. solution(p) ->
     (all q. all x. exec(p,pair(q,x),false()) -> ¬(ex y. exec(q,x,y)))")

  ; Two properties of the spoiler from above
  (spoiler1
   "all p. all x. solution(p) -> exec(p,pair(x,x),true()) ->
                  ¬(ex y. exec(if(duplicate(p),loop(),true()),x, y))")
  (spoiler2
   "all p. all x. solution(p) -> exec(p,pair(x,x),false()) ->
                  (ex y. exec(if(duplicate(p),loop(),true()),x, y))"))
 (goal "¬(ex p. solution(p))")
 (solution (Rule(NotIntro solution-exists)((Rule(Use solution-exists)((Rule(ExElim p solution-p)((Rule(Use solution-says-true-or-false)((Rule(Instantiate(Var p))((Rule Implies_elim((Rule(Use solution-p)((Rule Close())))(Rule(Instantiate(Fun if((Fun duplicate((Var p)))(Fun loop())(Fun true()))))((Rule(Instantiate(Fun if((Fun duplicate((Var p)))(Fun loop())(Fun true()))))((Rule(Cases p-says-true p-says-false)((Rule(Use spoiler1)((Rule(Instantiate(Var p))((Rule(Instantiate(Fun if((Fun duplicate((Var p)))(Fun loop())(Fun true()))))((Rule Implies_elim((Rule(Use solution-p)((Rule Close())))(Rule Implies_elim((Rule(Use p-says-true)((Rule Close())))(Rule NotElim((Rule(Use solution-true-means-halts)((Rule(Instantiate(Var p))((Rule Implies_elim((Rule(Use solution-p)((Rule Close())))(Rule(Instantiate(Fun if((Fun duplicate((Var p)))(Fun loop())(Fun true()))))((Rule(Instantiate(Fun if((Fun duplicate((Var p)))(Fun loop())(Fun true()))))((Rule Implies_elim((Rule(Use p-says-true)((Rule Close())))(Rule Close())))))))))))))))))))))))))(Rule(Use solution-false-means-doesnt-halt)((Rule(Instantiate(Var p))((Rule Implies_elim((Rule(Use solution-p)((Rule Close())))(Rule(Instantiate(Fun if((Fun duplicate((Var p)))(Fun loop())(Fun true()))))((Rule(Instantiate(Fun if((Fun duplicate((Var p)))(Fun loop())(Fun true()))))((Rule Implies_elim((Rule(Use p-says-false)((Rule Close())))(Rule NotElim((Rule(Use spoiler2)((Rule(Instantiate(Var p))((Rule(Instantiate(Fun if((Fun duplicate((Var p)))(Fun loop())(Fun true()))))((Rule Implies_elim((Rule(Use solution-p)((Rule Close())))(Rule Implies_elim((Rule(Use p-says-false)((Rule Close())))(Rule Close())))))))))))))))))))))))))))))))))))))))))))))
```

## What does this proof show?

The undecidability of the halting problem is in some sense disappointing, because it shows that we cannot build a program that will do perfect checking of other programs for us. On the other hand, it also shows that Computer Science can never be “solved” in some sense. There will always be more programs to think about.

It is worth looking at the various assumptions underlying this proof, to see exactly what it is saying:

1. We assumed **a model of computation that supports if-then-else, duplication, and looping**, because these are the things we needed to build the spoiler.

   * Prohibiting **if-then-else** seems like it would be very restrictive, so this is rarely done.
   * The real danger here is *duplication*, because it allows us to construct large inputs from small inputs, meaning that there is no bound on the size of computations. If we restrict the size of computations to some fixed size, then the halting problem becomes solvable by enumerating all possible states of the computation. This does require that we have a machine much larger than the ones we want to simulate, however.
   * Another solution is to prohibit unrestricted looping altogether, or at least to control it in some way. If we restrict our programs to always only loop over the input, or over data structures generated from the input, then we can guarantee termination. Unfortunately, this also means that we miss some functions (because otherwise we would have a solution to the halting problem!).
2. We assumed that a solution is **sound and complete**. Soundness means that if it says `true` then the program halts. Completeness means that if it says `false`, then the program does not halt. If we drop one of these, then we can make useful approximate solutions. For example, a solution that says `true` in most *useful* cases is an area of intensive research. This is similar to the idea above of restricting programs to a certain form, but approaching it from the other direction.

On the [next page](metatheory-automation.md), we'll look at a similar negative result that it purely about logic: Gödel's Incompleteness Theorem.
