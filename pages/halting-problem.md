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

1. `exec(program, input, output)` -- when we run `program` on `input` the result is `output`. Note that there may be no output for a given input (i.e. the program never gives us an answer), or there may be multiple possible answers for an input (i.e. the program may be non-deterministic).

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

### Exercises

Exercise: prove that the program `if(id(),false(),true())` implements a NOT gate. FIXME: will need `id()`.

## What does it mean for a program to halt?

`halts(p,x)` when does a program halt?

### Exercises

FIXME: Prove that some programs halt

## What does it mean for a program to solve the halting problem?

`solution(p)`

1. all p. solution p -> (all q. all x. exec(p,pair(q,x),true()) \/ exec(p,pair(q,x),false()))

2. ...

## What if we had a solution to the Halting Problem?

If we had a solution to the halting problem, then we could use it to make larger programs.



```focused-nd {id=haltingproblem-1}
(config
 (assumptions-name "Axioms")
 (assumptions
  ; execution axioms
;  (exec-true1 "all x. exec(true(), x, true())")
;  (exec-true2 "all x. all y. exec(true(), x, y) -> y = true()")
  (exec-loop "all x. all y. ¬exec(loop(), x, y)")
;  (exec-dup1 "all p. all x. all y. exec(p,pair(x,x),y) -> exec(duplicate(p),x,y)")
  (exec-dup2 "all p. all x. all y. exec(duplicate(p),x,y) -> exec(p,pair(x,x),y)")
;  (exec-if1true
;   "all p1. all p2. all p3. all x. all y.
;    exec(p1,x,true()) ->
;	exec(p2,x,y) ->
;	exec(if(p1,p2,p3),x,y)")
;  (exec-if1false
;   "all p1. all p2. all p3. all x. all y.
;    exec(p1,x,false()) ->
;	exec(p3,x,y) ->
;	exec(if(p1,p2,p3),x,y)")
  (exec-if2
   "all p1. all p2. all p3. all x. all y.
    exec(if(p1,p2,p3), x, y) ->
	((exec(p1,x,true()) /\ exec(p2,x,y)) \/ (exec(p1,x,false()) /\ exec(p3,x,y)))")

  ; What does being a solution mean?
;  (solution-says-true-or-false
;   "all p. solution(p) -> (all q. all x. exec(p,pair(q,x),true()) \/ exec(p,pair(q,x),false()))")
  (solution-never-says-true-and-false
   "all p. solution(p) -> (all q. all x. exec(p,pair(q,x),true()) -> exec(p,pair(q,x),false()) -> F)")
;  (solution-true-means-halts
;   "all p. solution(p) -> (all q. all x. exec(p,pair(q,x),true()) -> halts(q,x))")
;  (solution-false-means-doesnt-halt
;   "all p. solution(p) -> (all q. all x. exec(p,pair(q,x),false()) -> ¬halts(q,x))")
)
 (goal
  "all p. all x. solution(p) -> exec(p,pair(x,x),true()) ->
    ¬(ex y. exec(if(duplicate(p),loop(),true()),x, y))"))
```

```focused-nd {id=haltingproblem-2}
(config
 (assumptions-name "Axioms")
 (assumptions
  ; execution axioms
  (exec-true1 "all x. exec(true(), x, true())")
;  (exec-true2 "all x. all y. exec(true(), x, y) -> y = true()")
;  (exec-loop "all x. all y. ¬exec(loop(), x, y)")
  (exec-dup1 "all p. all x. all y. exec(p,pair(x,x),y) -> exec(duplicate(p),x,y)")
;  (exec-dup2 "all p. all x. all y. exec(duplicate(p),x,y) -> exec(p,pair(x,x),y)")
;  (exec-if1true
;   "all p1. all p2. all p3. all x. all y.
;    exec(p1,x,true()) ->
;	exec(p2,x,y) ->
;	exec(if(p1,p2,p3),x,y)")
  (exec-if1false
   "all p1. all p2. all p3. all x. all y.
    exec(p1,x,false()) ->
	exec(p3,x,y) ->
	exec(if(p1,p2,p3),x,y)")
;  (exec-if2
;   "all p1. all p2. all p3. all x. all y.
;    exec(if(p1,p2,p3), x, y) ->
;	((exec(p1,x,true()) /\ exec(p2,x,y)) \/ (exec(p1,x,false()) /\ exec(p3,x,y)))")

  ; What does being a solution mean?
;  (solution-says-true-or-false
;   "all p. solution(p) ->
;    (all q. all x. exec(p,pair(q,x),true()) \/ exec(p,pair(q,x),false()))")
;  (solution-never-says-true-and-false
;   "all p. solution(p) -> (all q. all x. exec(p,pair(q,x),true()) -> exec(p,pair(q,x),false()) -> F)")
;  (solution-true-means-halts
;   "all p. solution(p) -> (all q. all x. exec(p,pair(q,x),true()) -> halts(q,x))")
;  (solution-false-means-doesnt-halt
;   "all p. solution(p) -> (all q. all x. exec(p,pair(q,x),false()) -> ¬halts(q,x))")
)
 (goal
  "all p. all x. solution(p) -> exec(p,pair(x,x),false()) ->
    (ex y. exec(if(duplicate(p),loop(),true()),x, y))"))
```


## Undecidability of the Halting Problem

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
 (goal "¬(ex p. solution(p))"))
```
