# The Undecidability of the Halting Problem

**DRAFT**

```aside
This page assumes that you have understood the [proof rules for quantifiers](pred-logic-rules.html) and [proof rules for equality](equality.html) pages and completed all the exercises there.
```

One of the foundational results of Computer Science is that there is no program which can reliably tell if another program will halt on a given input.

This page presents a formal proof of this fact.



## Vocabulary

### Ways of Building Programs and Data

The following function symbols give us ways of building programs and data values.

1. `true()`, `false()`, `loop()` are all basic programs that ignore their input and (a) return `true`, (b) return `false`, (c) loop forever producing no answer.
2. `pair(x,y)` represents a pair of data items `x` and `y`. We will model programs taking multiple inputs by giving them inputs as pairs.
3. `duplicate(p)` is a program that duplicates its input `x` to a pair `pair(x,x)`, and then executes as the program `p` with that pair as input.
4. `if(p1, p2, p3)` is a program that runs `p1` on the input, if `p1` returns `true` then it runs `p2` and if `p1` returns `false` then it runs `p3`.

We will only need to assume this minimal set of function symbols for building programs to prove that the halting problem is undeciable. We do **not** say in our axiomatisation below that these are the only ways of building programs, only that the underlying model of computation must have **at least** these ways of constructing programs.

### The Execution Predicate

We define our world of computational things via one predicate:

1. `exec(program, input, output)` -- meaning that when we run `program` on `input` the result is `output`. Note that there may be no output for a given input (i.e. the program never gives us an answer), or there may be multiple possible answers for an input (i.e. the program may be non-deterministic).

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

Why do we need “both directions” for the axioms for `dup` and `if`? This is because we are going to have to reason backwards about program execution to answer questions like “if the output was `y`, then what happened during the program?”.

## What does it mean for a program to halt?

We can use the `exec` predicate to define what it means for a program to halt. A program `p` halts on an input `x` if there exists an answer `y` that executing `p` with input `x` gives the output `y`:

```formula
ex y. exec(p,x,y)
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

3. If a solution says “true” for a given `p` and `x`, then executing `p` on `x` halts:

   ```formula
   all p. solution(p) -> (all q. all x. exec(p,pair(q,x),true()) -> (ex y. exec(q,x,y)))
   ```

4. If a solution says “false” for a given `p` and `x`, then executing `p` on `x` does not halt (i.e. loops):

   ```formula
   all p. solution(p) ->
     (all q. all x. exec(p,pair(q,x),false()) -> ¬(ex y. exec(q,x,y)))
   ```

FIXME: put some quiz questions here.

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

### Solution says “halts”, then spoiler loops

We can prove formally from the axioms that, if the solution `p` says “true” then the spoiler program does not halt:

FIXME: put a rough plan of the proof here.

```focused-nd {id=haltingproblem-1}
(config
 (assumptions-name "Axioms")
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

### Solution says “loops”, then spoiler halts

Conversely, we can prove from the axioms that, if the solution `p` says “false” then the spoiler program does halt:

FIXME: put a rough plan of the proof here

```focused-nd {id=haltingproblem-2}
(config
 (assumptions-name "Axioms")
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
 (assumptions-name "Axioms")
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

## Further reading

TBD...
