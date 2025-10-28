# Hoare Logic for Loops

```aside
This page assumes that you have worked through the [page on Hoare Logic for loop-less programs](hoare-logic.html). It also builds on the [syntax of Predicate Logic](pred-logic-intro.html) and [the proof rules](pred-logic-rules.html).
```

In our [introduction to Hoare Logic](hoare-logic.md), we only looked at simple programs that run from top to bottom, sometimes making decisions on the way. To be a real programming language, we need to be able to process data in a loop. We look at how to prove properties of programs with loops here.

## Making Assertions

Before we do that though, we first look at



## Loops, and Loop Invariants {id=hoare-loops:loops}

The simple programming language we are using only has one way of doing loops: `while(C) { <program> }`. More exotic loops, such as `do { ... } while(C)` or `for(...) { ... }` can be expressed using `while` and some auxillary variables.

The meaning of `while(C) { <program> }` is deceptively simple looking: “keep doing `<program>` as long as `C` is true”. Unfortunately, this simplicity is a trap:

1. It is very easy to write programs where `C` never becomes true, which means that the loop never finishes. We will not address this problem here, only mention that the variant of Hoare Logic that we are using here does not prove termination. We would have to switch to [total Hoare logic](hoare-loops.md#hoare-loops:termination)
2. If we try to prove something about the loop the intuitive steps are:
   1. Something is true at the start of the loop: `P0`.
   2. After one step, `P1` is true.
   3. Then `P2` is true
   4. ...
   5. After enough steps, `P` is true, which is what we wanted.

   Unfortunately, this reasoning isn't very rigorous and it is pretty much impossible to pin down when it is sound.

The rigorous way to prove things about a loop is to find a *loop invariant*. This is some `P` that is true when the loop starts, and remains true every time we go round the loop.

This may sound like it cannot possibly work. How can a loop do any useful work if it is required to keep `P` always true?

The answer is that the loop invariant encodes some *relationship* between the current state and the partial work done so far. At the start of the loop, the partial work is non existent, but as the loop progresses it is filled in.

### Adding Up Numbers {id=hoare-loops:loops:sumTo}

Let's look at an example. The following program (where I've omitted the `end`s required by the tool) computes the sum `0 + 1 + 2 + ... + (X-1)` and leaves the answer in `TOTAL`:

```
TOTAL := 0
I := 0
while (I != X) {
  TOTAL := add(TOTAL,I)
  I := add(I,1)
}
```

We will encode the desired behaviour using a function `sumTo` with two axioms (these are basically how you would encode this problem in `ask`):

1. ```formula
   sumTo(0) = 0
   ```
2. ```formula
   all i. sumTo(add(i,1)) = add(sumTo(i),i)
   ```

If you try to prove this program meets the specification

```hoare {id=hoare-loops-1}
(hoare
 (program_vars TOTAL I X)
 (assumptions
  (sum-0 "sumTo(0) = 0")
  (sum-plus-1 "all x. sumTo(add(x,1)) = add(sumTo(x), x)"))
 (precond "T")
 (postcond "TOTAL = sumTo(X)"))
```

### The Rule for Loops {id=hoare-loops:loops:rule}

The rule for `while (C) { ... }` loops is:

```rules-display
(config
 (rule
  (name "while C")
  (premises "Γ ⊢ { C /\ P } - { P }" "Γ ⊢ { ¬C /\ P } - { Q }")
  (conclusion "Γ ⊢ { P } - { Q }")))
```

In this rule, we take the current precondition `P` as the loop invariant. This means that if the current `P` is not strong enough to be a loop invariant, then we have to use `assert I` for some `I` that is strong enough and is implied by `P`.

The body of the loop is permitted to assume that the loop condition `C` is true along with the loop invariant `P`, and must attain that invariant at the end. The program after the loop runs when `¬C` is true and also gets to assume the loop invariant.

The key point is that it is the combination `¬C /\ P` that will often be able to guide us to the correct loop invariant for the problem.

### Testing a number for Even/Odd {id=hoare-loops:loops:even-odd}

```
EVEN := true()
I := 0
while (I != X) {
  EVEN := not(EVEN)
  I := add(I,1)
}
```

```hoare {id=hoare-loops-even-odd}
(hoare
 (program_vars EVEN I X)
 (assumptions
  (even-0 "isEven(0)")
  (even-ax1 "all n. isEven(n) -> ¬isEven(add(n,1))")
  (even-ax2 "all n. ¬isEven(n) -> isEven(add(n,1))")
  (not-1 "not(false()) = true()")
  (not-2 "not(true()) = false()"))
 (precond "T")
 (postcond "(EVEN = true() /\ isEven(X)) \/ (EVEN = false() /\ ¬isEven(X))"))
```

### A Strategy for Finding Loop Invariants {id=hoare-loops:loops:trick}

Finding a suitable loop invariant can be very hard. However, for the kinds of loops we will look at in this course it often works to look at the final postcondition and replace any occurrences of the desired final value (e.g., `X`, `LEN`) with the loop counter (e.g., `I`) that is counting up to that value. For problems where the size of the problem solved so far is indexed by the loop counter, and we are not overwriting our original data, this method works well. We will see in the next topic a situation where we need to keep track of what has *not* changed and we will have to think harder about the loop invariant.

### Searching {id=hoare-loops:loops:search}

```
RESULT := -1
I := 0
while (I != LEN) {
  if (lookup(I) = 0) {
    RESULT := I
  }
  I := add(I,1)
}
```

Loop invariant is:
```formula
(RESULT = -1 /\ notFound(0,I)) \/ lookup(RESULT) = 0
```

```hoare {id=hoare-loops-search}
(hoare
 (program_vars RESULT I LEN)
 (assumptions
  (notFound-0 "notFound(0,0)")
  (notFound-step "all i. notFound(0,i) -> ¬lookup(i) = 0 -> notFound(0,add(i,1))"))
 (precond "T")
 (postcond "(RESULT = -1 /\ notFound(0,LEN)) \/ lookup(RESULT) = 0"))
```

Note: not saying that `RESULT` is between `0` and `LEN` in the found case. We can also add some axioms for `between` to fix this.

Loop invariant is:
```formula
(RESULT = -1 /\ notFound(0,I)) \/ (between(RESULT, 0, I) /\ lookup(RESULT) = 0)
```

```hoare {id=hoare-loops-search2}
(hoare
 (program_vars RESULT I LEN)
 (assumptions
  (notFound-0 "notFound(0,0)")
  (notFound-step "all i. notFound(0,i) -> ¬lookup(i) = 0 -> notFound(0,add(i,1))")
  (between-start "all i. between(i,0,add(i,1))")
  (between-step "all i. all x. between(x, 0, i) -> between(x,0,add(i,1))"))
 (precond "T")
 (postcond "(RESULT = -1 /\ notFound(0,LEN)) \/ (between(RESULT,0,LEN) /\ lookup(RESULT) = 0)"))
```

### Non-terminating Programs Meet Any Specification {id=hoare-loops:loops:false}

The rules that we have been using so far for Hoare Logic are only suitable for *partial correctness*, which means that the postcondition is also guaranteed if the program terminates. Therefore, it is always possible to meet any specification by writing a program that never finishes. Because there is no final state, the question of whether or not it meets the postcondition is void.

The simplest program that meets any specification is:

```
while (1 = 1) {
}
```

Because `1 = 1` is alway true, this program never finishes. We can use this fact in the proof tool to show that it meets the specification of making `F` true:

```hoare {id=hoare-loops-false}
(hoare
 (precond "T")
 (postcond "F"))
```

You can complete the construction by entering `while (1 = 1)` and then `end` and `auto` for the loop body and the continuation.

## Program Verification and Termination {id=hoare-loops:termination}

As we can see in the `while (1 = 1) { }` example, non-termination is potentially a large problem if we are trying to use Hoare Logic for partial correctness to verify our programs.

We can adjust Hoare Logic to be a logic of *total* correctness by altering the rule for `while` to also include a proof that there is some quantity that gets closer to `0` on every step of the loop (this is called the *loop variant*). Often this is easy. For most of the loops above, the difference `X - I` gets smaller on every step until it disappears. In general, however, finding a proof of termination is equivalent to the [halting problem](halting-problem.md).

Nevertheless, Hoare Logic for partial correctness is still valuable if we assume that the programs are written in good faith and are checked by some other means to be terminating. Often, the termination of a program is straightforward because the loops are always counting down (or up) to some fixed bound, and it is the rest of the correctness problem that is difficult.
