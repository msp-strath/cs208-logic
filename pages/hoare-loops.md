# Hoare Logic for Loops

```aside
This page assumes that you have worked through the [page on Hoare Logic for loop-less programs](hoare-logic.html). It also builds on the [syntax of Predicate Logic](pred-logic-intro.html) and [the proof rules](pred-logic-rules.html). It will also be helpful to know about [assertions and automation](hoare-assert-and-auto.html).
```

In our [introduction to Hoare Logic](hoare-logic.md), we only looked at simple programs that run from top to bottom, sometimes making decisions on the way. To be a real programming language, we need to be able to process data in a loop.

## Loops, and Loop Invariants {id=hoare-loops:loops}

The simple programming language we are using only has one way of doing loops: `while(C) { <program> }`. More exotic loops, such as `do { ... } while(C)` or `for(...) { ... }` can be expressed using `while` and some auxillary variables.

The meaning of `while(C) { <program> }` is deceptively simple looking: “keep doing `<program>` as long as `C` is true”. Unfortunately, this simplicity is a trap:

Firstly, it is very easy to write programs where `C` never becomes true, which means that the loop never finishes. We will not address this problem here, only mention that the variant of Hoare Logic that we are using here does not prove termination. We would have to switch to [total Hoare logic](hoare-loops.md#hoare-loops:termination).

Secondly, if we try to prove something about the loop the intuitive steps are:
   1. Something is true at the start of the loop: `P0`.
   2. After one step, `P1` is true.
   3. Then `P2` is true
   4. ...
   5. After enough steps, `P` is true, which is what we wanted.

Unfortunately, this reasoning isn't very rigorous and it is pretty much impossible to pin down when it is sound.

The rigorous way to prove things about a loop is to find a *loop invariant*. Instead of finding a chain of facts `P0`, `P1`, `P2`, ..., we find a single `P` that summarises all of them. This `P` must be true when the loop starts, and remains true every time we go round the loop, and is still true when we exit the loop.

This may sound like it cannot possibly work. How can a loop do any useful work if it is required to keep `P` always true?

The answer is that the loop invariant encodes some *relationship* between the current state and the partial work done so far. At the start of the loop, the partial work is non existent, but as the loop progresses it is filled in. The of this page details some strategies for discovering loop invariants to verify programs against specifications.

## Warm up {id=hoare-loops:warmup}

As a warm up, we will prove that the following program sets `X` to be `0`, because the loop never executes. This example will serve to show how loops are entered in the prover.

```
X := 0
while (1 != 1) {
  X := 1
  end
}
end
```

To enter this program, the first command is `X := 0`. Then to enter a loop, type `while (1 != 1)` (similar to an `if` with its condition). The tool will then generate two subproblems, one for the loop body and one for the continuation after the loop.

Looking at the loop body, the precondition is now `¬1 = 1 ∧ (∃oldX.  X = 0 ∧ T)`. This formula contains the contradictory clause `¬1 = 1`, indicating that this code will never execute. It therefore doesn't matter what code is placed here. Entering `X := 1` and then `end` will drop us into proof mode. The goal is to prove that `X = 0`, but since the assumptions are contradictory we do not have to do anything and can use `auto` to complete the proof.

In the continuation after the loop, the additional assumption is that `1 = 1` (the while loop implementation eliminates the double negation for us), but we also get the result of setting `X` to `0` before the loop. Now `end` and then `auto` completes the proof.

```hoare {id=hoare-loops-warmup}
(hoare
 (program_vars X)
 (precond "T")
 (postcond "X = 0"))
```

## Adding Up Numbers {id=hoare-loops:sumTo}

Let's look at a more interesting example that will need more work.

The following program (where I've omitted the `end`s required by the tool) computes the sum `0 + 1 + 2 + ... + (X-1)` and leaves the answer in `TOTAL`:

```
TOTAL := 0
I := 0
while (I != X) {
  TOTAL := add(TOTAL,I)
  I := add(I,1)
}
```

We will encode the desired behaviour using a function `sumTo` with two axioms (these are basically how you would encode this problem in `ask`):

1. Summing up to `0` is `0`:
   ```formula
   sumTo(0) = 0
   ```
2. Summing up to `i + 1` is equal to summing up to `i` then adding `i`:
   ```formula
   all i. sumTo(add(i,1)) = add(sumTo(i),i)
   ```

If you try to prove that this program with precondition `T` satisfies the postcondition `TOTAL = sumTo(X)`, then you will get stuck (try it below!).

The problem is that on entering the while loop the first time we know that `TOTAL = 0` and `I = 0`, but after one step of the loop we now have that `TOTAL = add(0,0)` and `I = add(0,1)`. But the tool is trying to get us to prove that `TOTAL = 0` and `I = 0` again! To be able to go back round the loop, we need to show that the precondition of the loop is also its postcondition. Without this, we cannot execute the loop again.

To fix this, we need to find something involving `TOTAL` and `I` that is true every time the loop goes round. The job of the loop is to compute `sumTo(X)` and it does this by incrementally working up to `X` using the loop counter `I`. Therefore, a reasonable loop invariant is that it is always true that `TOTAL = sumTo(I)`. We can check that this works informally:

1. When the loop starts, both `TOTAL` and `I` are `0`, and we have `sumTo(0) = 0` by our first axiom for `sumTo`.
2. When the loop goes round, `TOTAL` becomes `add(TOTAL,I)` and `I` becomes `add(I,1)`, which matches our second axiom for `sumTo`.
3. When the loop ends, `I = X`, so knowing that `TOTAL = sumTo(I)` implies `TOTAL = sumTo(X)`.

With this in mind, we alter the program to `assert` the loop invariant before the loop. We also add another `assert`ion after the update to `TOTAL` that helps make the proof easier by breaking it into two steps.

```
TOTAL := 0
I := 0
assert (TOTAL = sumTo(I))
while (I != X) {
  TOTAL := add(TOTAL,I)
  assert (TOTAL = sumTo(add(I,1)))
  I := add(I,1)
}
```

If you now enter this program into the proof tool below, you will be able to complete the proofs using the two axioms `sum-0` and `sum-plus-1`. You will be able to save quite a bit of time by finding the right instantiations of these axioms using `store` and then using `auto`.

```hoare {id=hoare-loops-1}
(hoare
 (program_vars TOTAL I X)
 (assumptions
  (sum-0 "sumTo(0) = 0")
  (sum-plus-1 "all x. sumTo(add(x,1)) = add(sumTo(x), x)"))
 (precond "T")
 (postcond "TOTAL = sumTo(X)"))
```

## The Rule for Loops {id=hoare-loops:rule}

The rule for `while (C) { ... }` loops that is implemented by the tool is:

```rules-display
(config
 (rule
  (name "while C")
  (premises "Γ ⊢ { C /\ P } - { P }" "Γ ⊢ { ¬C /\ P } - { Q }")
  (conclusion "Γ ⊢ { P } - { Q }")))
```

In this rule, we take the current precondition `P` as the loop invariant. This means that if the current `P` is not strong enough to be a loop invariant, then we have to use `assert I` for some `I` that is strong enough and is implied by `P`.

The body of the loop is permitted to assume that the loop condition `C` is true along with the loop invariant `P`, and must attain that invariant at the end. The program after the loop runs when `¬C` is true and also gets to assume the loop invariant.

The fact that the state after the loop is described as `¬C /\ P` will often be able to guide us to the correct loop invariant for the problem. If we know what we want, we can work backwards to find out what we need.

## Finding Out If A Number Is Even Or Odd {id=hoare-loops:even-odd}

The following program computes whether or not the value stored in `X` is even or odd by counting up to `X`. As the loop progresses, the variable `EVEN` is `true()` if `I` is even and `false()` if `I` is odd. When the loop ends, `I` is equal to `X` and so `EVEN` tells us whether or not `X` is even.

```
EVEN := true()
I := 0
while (I != X) {
  EVEN := not(EVEN)
  I := add(I,1)
}
```

To specify this program, we assume a predicate `isEven(n)` that is true when `n` is even and false if it is not. This predicate is assumed to satisfy the following axioms:
1. Axiom `even-0`:
   ```formula
   isEven(0)
   ```
2. Axiom `even-odd`:
   ```formula
   all n. isEven(n) -> ¬isEven(add(n,1))
   ```
3. Axiom `odd-even`:
   ```formula
   all n. ¬isEven(n) -> isEven(add(n,1))
   ```

The postcondition we want to prove is:
```formula
(EVEN = true() /\ isEven(X)) \/ (EVEN = false() /\ ¬isEven(X))
```
which states as a formula the informal specification we wrote above.

In order to verify this program meets the specification, we need to add `assert`ions to the program that establish the loop invariant. We also add an assertion after the update to `EVEN` inside the loop that helps break the proof down:

```
EVEN := true()
I := 0
assert ((EVEN = true() /\ isEven(I)) \/ (EVEN = false() /\ ¬isEven(I)))
while (I != X) {
  EVEN := not(EVEN)
  assert ((EVEN = true() /\ isEven(add(I,1))) \/ (EVEN = false() /\ ¬isEven(add(I,1))))
  I := add(I,1)
}
```

With this annotated program, the axioms about `isEven`, and two axioms establishing how `not` works, we can verify this program. To prove the `assert` inside the loop, you will need to instantiate the `even-odd` and `odd-even` axioms with `store` and then use `auto`.

```hoare {id=hoare-loops-even-odd}
(hoare
 (program_vars EVEN I X)
 (assumptions
  (even-0 "isEven(0)")
  (even-odd "all n. isEven(n) -> ¬isEven(add(n,1))")
  (odd-even "all n. ¬isEven(n) -> isEven(add(n,1))")
  (not-1 "not(false()) = true()")
  (not-2 "not(true()) = false()"))
 (precond "T")
 (postcond "(EVEN = true() /\ isEven(X)) \/ (EVEN = false() /\ ¬isEven(X))"))
```

## A Strategy for Finding Loop Invariants {id=hoare-loops:strategy}

Finding a suitable loop invariant can be very hard. However, for the kinds of loops we will look at in this course it often works to look at the final postcondition and replace any occurrences of the desired final value (e.g., `X`, `LEN`) with the loop counter (e.g., `I`) that is counting up to that value. For problems where the size of the problem solved so far is indexed by the loop counter, and we are not overwriting our original data, this method works well. We will see in the [next topic](hoare-arrays.md) a situation where we need to keep track of what has *not* changed and we will have to think harder about the loop invariant.

## Specifying and Verifying Linear Search {id=hoare-loops:search}

A more interesting example of a program with a loop is one that performs a linear search through an array looking for a specific value. The basic specification is that it returns in the `RESULT` variable the index of the value if it is found, and `-1` if it is not.

For the purposes of this example, we assume that there is a function `lookup(I)` that returns the `I`th value of the array. We want to find a position where `lookup(I) = 0` assuming that `I` is between `0` (inclusive) and `LEN` (exclusive).

The basic program is:
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

We will look at three different specifications for this program (decorated with appropriate `assert`s), of increasing informativeness.

### Version 1 {id=hoare-loops:search:v1}

The first specification states exactly what we said above. If the program finishes, then either `RESULT = -1` or `lookup(RESULT) = 0`:

```formula
RESULT = -1 \/ lookup(RESULT) = 0
```

To verify this program we need to provide a loop invariant via an `assert`. The following program is the same as above but with the loop invariant added:

```
RESULT := -1
I := 0
assert (RESULT = -1 \/ lookup(RESULT) = 0)
while (I != LEN) {
  if (lookup(I) = 0) {
    RESULT := I
  }
  I := add(I,1)
}
```

Entering this program into the tool is straightforward. All of the proofs can be completed using `auto`.

```hoare {id=hoare-loops-search-1}
(hoare
 (program_vars RESULT I LEN)
 (precond "T")
 (postcond "RESULT = -1 \/ lookup(RESULT) = 0"))
```

### Version 2 {id=hoare-loops:search:v2}

The specification above states that the program may end with `lookup(RESULT) = 0` indicating that the `RESULT` location contains the value `0`, but it doesn't guarantee that `RESULT` is actually between `0` and `LEN`. To do this we will assume a predicate `between(i,j,k)` that is assumed to mean that `i` is between `j` (inclusive) and `k` (exclusive). We assume that this predicate satisfies the following two axioms:

1. The axiom `between-start` states that `i` is between `0` and `i + 1` (for simplicity, we are assuming that `i` is greater than or equal to `0`):
   ```formula
   all i. between(i,0,add(i,1))
   ```
2. The axiom `between-step` states that if `x` is between `0` and `i`, then it is between `0` and `i+1`:
   ```formula
   all i. all x. between(x, 0, i) -> between(x,0,add(i,1))
   ```

The postcondition we want to prove that the program meets is:
```formula
RESULT = -1 \/ (between(RESULT,0,LEN) /\ lookup(RESULT) = 0)
```
which improves over the previous one by stating that when a `0` is found, it is found between `0` and `LEN`.

To prove that the program meets this upgraded specification, we also need to upgrade our loop invariant. We use the same trick as before and replace `LEN`, which indicates “all of the array”, with `I`, indicating that a partial job has been done.

The fully annotated program looks like this, where additional `assert`s have been used to summarise the effect of each branch of the if-then-else and help the proof construction go through easier:
```
RESULT := -1
I := 0
assert (RESULT = -1 \/ (between(RESULT,0,I) /\ lookup(RESULT) = 0))
while (I != LEN) {
  if (lookup(I) = 0) {
    RESULT := I
    assert (between(RESULT, 0, add(I, 1)) ∧ lookup(RESULT) = 0)
  } else {
    assert (RESULT = -1 /\ (between(RESULT,0,add(I,1)) /\ lookup(RESULT) = 0))
  }
  I := add(I,1)
}
```
The proof can now be completed on the annotated program, but `auto` will need help in instantiating the axioms:
```hoare {id=hoare-loops-search-2}
(hoare
 (program_vars RESULT I LEN)
 (assumptions
  (between-start "all i. between(i,0,add(i,1))")
  (between-step "all i. all x. between(x, 0, i) -> between(x,0,add(i,1))"))
 (precond "T")
 (postcond "RESULT = -1 \/ (between(RESULT,0,LEN) /\ lookup(RESULT) = 0)"))
```

### Version 3 {id=hoare-loops:search:v3}

The specifications so far state that `RESULT = -1` is a possible final state of the program, but does not say what that means. If we want the specification to actually say that there was no element found then we need to add this explicitly.

We can state what it means for there to be no `0` between `start` and `end` by the formula:
```formula
all i. between(i,start,end) -> ¬lookup(i) = 0
```
We could now alter the postcondition of our specification to include this formula directly. This will work (if we add another two axioms for `between`, see below), but it makes the proof unnecessarily messy. To reduce the mess, we prefer to abbreviate this formula to just `notFound(start,end)` and prove two properties of it. When verifying the program, we forget the actual definition of `notFound` and only use the properties.

1. The property `notFound-0` states that the value is not found between `0` and `0` (remember that the upper bound is exclusive):
   ```formula
   notFound(0,0)
   ```
2. The property `notFound-step` states that if the value was not found up to `i` and also not at `i`, then it is not found up to `i + 1`:
   ```formula
   all i. notFound(0,i) -> ¬lookup(i) = 0 -> notFound(0,add(i,1))
   ```

To prove these properties, we will need two additional axioms for `between(i,start,end)`, which are in some sense the “elimination” rules for `between` where the above are the “introduction” rules:
1. Nothing is between `0` and `0`:
   ```formula
   all i. ¬between(i, 0, 0)
   ```
2. If something is between `0` and `i + 1` then it is either between `0` and `i` or equal to `i`.
   ```formula
   all x. all i. between(x, 0, add(i,1)) -> (between(x,0,i) \/ x = i)
   ```

We can now prove them in the prover:
1. ```focused-nd {id=hoare-loops-notFound-1}
   (config
    (name "notFound-0")
	(assumptions
	 (between-empty "all i. ¬between(i, 0, 0)"))
	(goal "all i. between(i,0,0) -> ¬lookup(i) = 0"))
   ```
2. ```focused-nd {id=hoare-loops-notFound-2}
   (config
    (name "notFound-step")
	(assumptions
	 (between-elim "all x. all i. between(x, 0, add(i,1)) -> (between(x,0,i) \/ x = i)"))
	(goal "all i. (all x. between(x,0,i) -> ¬lookup(x) = 0) -> ¬lookup(i) = 0 -> (all x. between(x,0,add(i,1)) -> ¬lookup(x) = 0)"))
   ```

Using the `notFound` predicate, the complete annotated program is:
```
RESULT := -1
I := 0
assert ((RESULT = -1 ∧ notFound(0, I)) ∨ (between(RESULT, 0, I) ∧ lookup(RESULT) = 0))
while (I != LEN) {
  if (lookup(I) = 0) {
    RESULT := I
    assert (between(RESULT, 0, add(I, 1)) ∧ lookup(RESULT) = 0)
  } else {
    assert ((RESULT = -1 ∧ notFound(0, add(I, 1)))
            ∨ (between(RESULT, 0, add(I, 1)) ∧ lookup(RESULT) = 0))
  }
  I := add(I,1)
}
```

And the proof can be completed using the axioms given:

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

## Non-terminating Programs Meet Any Specification {id=hoare-loops:false}

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

More insidiously, it is possible to make any of the programs above verify simply by setting the body of each `while` loop to be `end`. The loop invariant is certainly preserved (by doing nothing), but the program will never finish (unless `X = 0` or similar). Therefore, it is important to keep in mind that partial correctness only promises anything if the program actually terminates.

## Program Verification and Termination {id=hoare-loops:termination}

As we can see in the `while (1 = 1) { }` example, non-termination is potentially a large problem if we are trying to use Hoare Logic for partial correctness to verify our programs.

We can adjust Hoare Logic to be a logic of *total* correctness by altering the rule for `while` to also include a proof that there is some quantity that gets closer to `0` on every step of the loop (this is called the *loop variant*). Often this is easy. For most of the loops above, the difference `X - I` gets smaller on every step until it disappears. In general, however, finding a proof of termination is equivalent to the [halting problem](halting-problem.md).

Nevertheless, Hoare Logic for partial correctness is still valuable if we assume that the programs are written in good faith and are checked by some other means to be terminating. Often, the termination of a program is straightforward because the loops are always counting down (or up) to some fixed bound, and it is the rest of the correctness problem that is difficult.
