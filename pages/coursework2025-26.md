# CS208 Coursework 2025-2026

This is the coursework for semester one of CS208 *Logic and
Algorithms* 2024/25.

It is worth 10% towards your final mark for all of CS208 (both semesters). The remainder of the marks come from the quizzes (5%), the algorithms coursework(s) in semester two (15%), and a final exam in April/May 2025 (70%).

The questions are on this page, along with places for you to write your answers.  This page will remember the answers you type in, even if you leave the page and come back. Your browser's [local storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API/Using_the_Web_Storage_API) is used to store the data. If you delete saved data in your browser, or visit this page in private browsing mode and then close the window, you will lose your answers.

The whole page is marked out of 20.

Once you have completed the questions, please click on the “Download” button to download your answers as a file called `cs208-2025-coursework.answers`. When you are ready to submit your answers, please upload the file to [the MyPlace submission page](https://classes.myplace.strath.ac.uk/mod/assign/view.php?id=2163360).

The deadline is **17:00 Thursday 27th November 2025**. All extension requests should be submitted via [MyPlace](https://classes.myplace.strath.ac.uk/mod/assign/view.php?id=2163360).

```download
cs208-2025-coursework.answers
```

## Question 0 (0 marks) {id=cw2025:q0}

Please enter your name and registration number:

- Name:
  ```entrybox {id=cw2025-name}
  <name>
  ```

- Registration number:
  ```entrybox {id=cw2025-regnum}
  <registration-number>
  ```

## Question 1 : Logical Modelling (6 marks) {id=cw2025:q1}

[Predicate Logic](pred-logic-intro.md) is primarily a language for modelling situations in a way that that can be reasoned about using proof. This question is about using logic statements to model some aspects of a student database.

The vocabulary we will use is as follows, where in each case `x`, `y`, etc. are variables standing for any entity:

1. `student(x)`, meaning `x` is a student.
2. `staff(x)`, meaning `x` is a staff member.
3. `course(x)`, meaning that `x` is a course.
4. `assessment(x)`, meaning that `x` is an assessment.
5. `attempt(x)`, meaning that `x` is an attempt at some assessment.
6. `enrolled(x,y)`, meaning that (student) `x` is enrolled on (course) `y`.
7. `employed(x,y)`, meaning that (staff member) `x` is employed on (course) `y`.
8. `assessmentOf(x,y)`, meaning that (assessment) `x` is for (course) `y`.
9. `attemptBy(x,y)`, meaning that (attempt) `x` is by (student) `y`.
10. `attemptOf(x,y)`, meaning that (attempt) `x` is of (assessment) `y`.
10. `marked(x,y)`, meaning that (attempt) `x` has been marked by (staff member) `y`.

Write the following statements as logical formulas using this vocabulary.

If you feel that your answer needs some commentary, then enter this in the text box beneath the formula entry box.

2. Every student is enrolled on some course.

   ```formulaentry {id=cw2025-q1b}
   ```

   ```textbox {id=cw2025-q1b-comment}
   ```

3. Every staff member is employed on some course

   ```formulaentry {id=cw2025-q1c}
   ```

   ```textbox {id=cw2025-q1c-comment}
   ```

4. Every assessment is part of some course.

   ```formulaentry {id=cw2025-q1d}
   ```

   ```textbox {id=cw2025-q1d-comment}
   ```

5. No assessment is attached to multiple courses.

   ```formulaentry {id=cw2025-q1e}
   ```

   ```textbox {id=cw2025-q1e-comment}
   ```

6. Every attempt by a student is for an assessment on a course that the student is enrolled on.

   ```formulaentry {id=cw2025-q1f}
   ```

   ```textbox {id=cw2025-q1f-comment}
   ```

7. Every marked attempt is of an assessment that is attached to a course and is marked by a staff member for that course.

   ```formulaentry {id=cw2025-q1g}
   ```

   ```textbox {id=cw2025-q1g-comment}
   ```

8. There can only be one attempt by a student for a particular assessment.

   ```formulaentry {id=cw2025-q1h}
   ```

   ```textbox {id=cw2025-q1h-comment}
   ```



## Question 2 : Monoids (3 marks) {id=cw2025:q2}

This question is about [proofs in Predicate Logic](pred-logic-rules.md). You can use the `auto` command, but all of the proofs will involve some kind of manual instantiation of quantifiers using either `inst` or `exists`.

The following proofs all use the axioms of a commutative monoid, which is like an abelian group except that there are no inverses (think of positive numbers with addition).

This question and the two following are about a definition of “less than or equal” in terms of addition. We define “*x* <= *y*” to be the formula “*∃ k.  x + k = y*”. So *x* is less than *y* if there is a difference of *k* between them.

### Question 2(a) (1 mark) {id=cw2025:q2:a}

The first theorem to prove is that everything is less than or equal to itself for this definition of less than or equal:

```focused-nd {id=cw2025-2a marks=1}
(config
 (name "Question 2(a)")
 (assumptions
  (add-zero "∀x. add(x, 0) = x")
  (add-comm "∀x. ∀y. add(x, y) = add(y, x)")
  (add-assoc "∀x. ∀y. ∀z. add(x, add(y, z)) = add(add(x, y), z)"))
 (goal "∀x. ∃k. add(x, k) = x"))
```

### Question 2(b) (1 mark) {id=cw2025:q2:b}

Next, zero is less than or equal to everything (so that *0* is the bottom element of the ordering):

```focused-nd {id=cw2025-2b marks=1}
(config
 (name "Question 2(b)")
 (assumptions
  (add-zero "∀x. add(x, 0) = x")
  (add-comm "∀x. ∀y. add(x, y) = add(y, x)")
  (add-assoc "∀x. ∀y. ∀z. add(x, add(y, z)) = add(add(x, y), z)"))
 (goal "∀x. ∃k. add(0, k) = x"))
```

### Question 2(c) (1 mark) {id=cw2025:q2:c}

And this ordering is transitive, *x <= y* and *y <= z*, then *x <= z*:

```focused-nd {id=cw2025-2c marks=1}
(config
 (name "Question 2(c)")
 (assumptions
  (add-zero "∀x. add(x, 0) = x")
  (add-comm "∀x. ∀y. add(x, y) = add(y, x)")
  (add-assoc "∀x. ∀y. ∀z. add(x, add(y, z)) = add(add(x, y), z)"))
 (goal "∀x. ∀y. ∀z. (∃k. add(x, k) = y) → (∃k. add(y, k) = z) → (∃k. add(x, k) = z)"))
```

## Question 3 : Proving the Hoare Logic Rules sound (6 marks) {id=cw2025:q3}

We have described the [rules of Hoare Logic](hoare-logic.md), but have not proved them sound with respect to our [simple model of computation](specify-verify.md#specify-verify:simple-model). You will do this now.

The rules are given here in a slighly more standard way than the way that the tool presents them. The tool presents a "forward first" approach that traces the path of a formula throughout the program starting at the start, while the standard approach is unbiased and allows the proof to explore the program in any order.

We will be using the definition of a Hoare Logic triple `{P} prog {Q}` in terms of the `exec` predicate:
```formula
all s1. all s2. P(s1) -> exec(prog, s1, s2) -> Q(s2)
```
In words: if `P` is true for the initial state `s1`, and executing `prog` get us from state `s1` to state `s2`, then `Q` is true of the final state `s2`.

For the rules below (except for *Consequence*), we will have to assume certain properties of the `exec` predicate for the relevant kinds of program. We introduce these as we go.

### Question 3(a) : Logical Consequence (1 mark) {id=cw2025:q3:a}

The *Consequence* rule allows a specification to be adjusted. If we know that `prog` satisifies the specification `{ P } prog { Q }`, then we can *strengthen* the precondition and *weaken* the postcondition. Strengthening means assuming something that implies `P`, i.e. assuming something “stronger” (in the sense it can imply more things) than `P`. Weakening means ensuring something that is *implied by* `Q`.

As a deduction rule, *Consequence* is:

```rules-display
(config
 (rule
  (name "Consequence")
  (premises "s, P'(s) |- P(s)" "{ P } prog { Q }" "s, Q'(s) |- Q(s)")
  (conclusion "{ P' } prog { Q' }")))
```

Prove that Hoare Triples satisfy *Consequence*:

```focused-nd {id=cw2025-q3a marks=1}
(config
 (assumptions
  (pre "all s. P'(s) -> P(s)")
  (post "all s. Q(s) -> Q'(s)")
  (prog var)
  (prog-spec "all s1. all s2. P(s1) -> exec(prog, s1, s2) -> Q(s2)"))
 (goal "all s1. all s2. P'(s1) -> exec(prog, s1, s2) -> Q'(s2)"))
```

### Question 3(b) : Doing Nothing (1 mark) {id=cw2025:q3:b}

The simplest program is one that does nothing. In the tool this is called `end` because it is only ever needed at the end of a block of code. In the unbiased presentation of Hoare Logic it can be used anywhere and so is called `skip()` (it is similar to `pass` in Python).

To be able to state and prove a Hoare Logic rule for `skip()`, we need to write down in Logic how it works. The following formula describes the effect that `skip()` has on the state. It does nothing: the final state after doing `skip()` is the same as the state before.
```formula
all s1. all s2. exec(skip(), s1, s2) -> s1 = s2
```
The unbiased deduction rule for `skip()` is:
```rules-display
(config
 (rule
  (name "Skip")
  (conclusion "{ P } skip { P }")))
```
Similarly to the way that `skip()` does nothing to states, the rule says that anything that is true before `skip()` is true afterwards.

Prove that this rule is sound from the axiom about how `skip()` affects the state:
```focused-nd {id=cw2025-q3b marks=1}
(config
 (assumptions
  (exec-skip "all s1. all s2. exec(skip(), s1, s2) -> s1 = s2"))
 (goal "all s1. all s2. P(s1) -> exec(skip(), s1, s2) -> P(s2)"))
```

### Question 3(c) : Sequencing (1 mark) {id=cw2025:q3:c}

The next basic way programs work is by sequencing them one after the other. The tool handles this implicitly, but the unbiased presentation of Hoare Logic treats sequencing as its own rule.

In the logic, we write the sequencing of two programs as `seq(p1,p2)`. The behaviour of this program is specified by this formula:
```formula
all p1. all p2. all s1. all s2. exec(seq(p1, p2), s1, s2) -> (ex s. exec(p1, s1, s) /\ exec(p2, s, s2))
```
In words: if execution of the sequence `p1`;`p2` goes from state `s1` to state `s2`, then there is an intermediate state `s` such that `p1` goes from `s1` to `s` and `p2` goes from `s` to `s2`.

As with `skip()`, the Hoare Logic rule for sequencing follows the same shape. If there is an intermediate predicate `R`, then we can prove Hoare Triple for the sequencing of two programs.
```rules-display
(config
 (rule
  (name "Seq")
  (premises "{ P } prog1 { R }" "{ R } prog2 { Q }")
  (conclusion "{ P } seq(prog1, prog2) { Q }")))
```

Prove that this rule is sound from the axiom of how sequencing affects the state:
```focused-nd {id=cw2025-q3c marks=1}
(config
 (assumptions
  (exec-seq   "all p1. all p2. all s1. all s2. exec(seq(p1, p2), s1, s2) -> (ex s. exec(p1, s1, s) /\ exec(p2, s, s2))")
  (prog1 var)
  (prog2 var)
  (prog1-spec "all s1. all s2. P(s1) -> exec(prog1,s1,s2) -> R(s2)")
  (prog2-spec "all s1. all s2. R(s1) -> exec(prog2,s1,s2) -> Q(s2)")
 )
 (goal "all s1. all s2. P(s1) -> exec(seq(prog1, prog2), s1, s2) -> Q(s2)"))
```

### Question 3(d) : Assignment (backward) (1 mark) {id=cw2025:q3:d}

In the tool, updating the state is performed by writing to variables. In the simple model of programs we have here, the state is not necessarily made of separate variables. We will simply model the updating of the state by assuming that there is some function `doUpdate(s)` that returns the updated version of the state.

With this, we can specify the behaviour of the program `update()` which, when it executes starting in state `s1`, ensures that the final state is `doUpdate(s1)`.
```formula
all s1. all s2. exec(update(), s1, s2) -> s2 = doUpdate(s1)
```
In the unbiased version of Hoare Logic, there are two possibilities for the deductive rule for `update()`. The first is the “backwards” rule:
```rules-display
(config
 (rule
  (name "update-1")
  (conclusion "{ P[s := doUpdate(s)] } update { P }")))
```
This rule states that if `P` was true assuming we already did the update, then `P` is true afterwards. This version of the rule is useful for reasoning backwards through the program to produce a *weakest precondition*.

Prove that this rule is sound, assuming the update axiom for `exec`:

```focused-nd {id=cw2025-q3d marks=1}
(config
 (assumptions
  (exec-update "all s1. all s2. exec(update(), s1, s2) -> s2 = doUpdate(s1)"))
 (goal "all s1. all s2. P(doUpdate(s1)) -> exec(update(), s1, s2) -> P(s2)"))
```

### Question 3(e) : Assignment (forward) (1 mark) {id=cw2025:q3:e}

The alternative version of the rule for `update()` reasons forwards. This is the form that is used in the tool. The rule is:
```rules-display
(config
 (rule
  (name "update-2")
  (conclusion "{ P } update { ex oldS. s = doUpdate(oldS) /\ P[s := oldS] }")))
```

This rule is perhaps easier to explain. If `P` is true about the current state before the update, then after the update there exists an old state, where the new states is equal to the update of the old state and `P` is true about the old state.

Prove this rule using the same axiom for `update()` as above:
```focused-nd {id=cw2025-q3e marks=1}
(config
 (assumptions
  (exec-update "all s1. all s2. exec(update(), s1, s2) -> s2 = doUpdate(s1)"))
 (goal "all s1. all s2. P(s1) -> exec(update(), s1, s2) -> (ex oldstate. s2 = doUpdate(oldstate) /\ P(oldstate))"))
```

### Question 3(f) : If-then-else (1 mark) {id=cw2025:q3:f}

If-then-else is more complex than the rules above because it involves branching between two possible outcomes, so there are two premises to the rule.

Formalising the behaviour of if-then-else on an arbitrary boolean expression will be too complicated, so here we just assume there is some condition `C` on states that is being tested.

The axiom describing the behaviour of a successful execution of an if-then-else on condition `C` is:
```formula
all p1. all p2. all s1. all s2. exec(ifC(p1, p2), s1, s2) -> ((C(s1) /\ exec(p1,s1,s2)) \/ (!C(s1) /\ exec(p2,s1,s2)))
```
In words: if `ifC(p1,p2)` executes from state `s1` to state `s2`, then either `C(s1)` was true and `p1` did that execution, or `C(s1)` was not true and `p2` did that execution.

The rule for `ifC` follows this idea. The OR in the formula becomes a requirement to prove two premises, because we do not know which of them will be true:
```rules-display
(config
 (rule
  (name "If")
  (premises "{ C /\ P } prog1 { Q }" "{ ¬C /\ P } prog2 { Q }")
  (conclusion "{ P } ifC(prog1, prog2) { Q }")))
```

Use the `exec-if` axiom to prove that the `If` rule is sound in Hoare Logic:
```focused-nd {id=cw2025-q3f marks=1}
(config
 (assumptions
  (exec-if "all p1. all p2. all s1. all s2. exec(ifC(p1, p2), s1, s2) -> ((C(s1) /\ exec(p1,s1,s2)) \/ (!C(s1) /\ exec(p2,s1,s2)))")
  (prog1 var)
	(prog2 var)
  (prog1-spec "all s1. all s2. (C(s1) /\ P(s1)) -> exec(prog1, s1, s2) -> Q(s2)")
  (prog2-spec "all s1. all s2. (¬C(s1) /\ P(s1)) -> exec(prog2, s1, s2) -> Q(s2)"))
 (goal "all s1. all s2. P(s1) -> exec(ifC(prog1, prog2), s1, s2) -> Q(s2)"))
```

## Question 4 : Program Proof (5 marks in total) {id=cw2025:q4}

Complete the following proofs using the [Hoare Logic tool](hoare-logic.md). You will also need the page on Hoare Logic Rules for Loops.

### Question 4(a) (1 mark) {id=cw2025:q4:a}

Adding and then subtracting gets you back to where you started:
```formula
all x. all y. sub(add(x,y),y) = x
```

Use this fact to write the following program that ends with a copy of `X` in `Y` and the sum of them in `X`. You should be able to write the program with one assignment to each of `X` and `Y`.

**HINT:** The final proof will involve spliting, rewriting the goal using `add-sub`, and then `auto`. It might be easier to see what is going on if you put an `assert` just before the final line of the program that describes the final values of `X` and `Y` in terms of `x` and `y` (and `add` and `sub`) without any indirections through `oldX` and `oldY`.

```hoare {id=cw2025-q4a marks=1}
(hoare
 (program_vars X Y)
 (logic_vars x y)
 (assumptions
  (add-sub "all x. all y. sub(add(x,y),y) = x"))
 (precond "X = x /\ Y = y")
 (postcond "Y = x /\ X = add(x,y)"))
```

### Question 4(b) (2 marks) {id=cw2025:q4:b}

The `xor` function on pairs of integers has the following two useful properties:

1. It is commutative:
   ```formula
   all x. all y. xor(x,y) = xor(y,x)
   ```
2. It is cancellative, meaning that `xor`ing with the same value twice gets you back to where you started.
   ```formula
   all x. all y. xor(xor(x,y),y) = x
   ```

These two properties mean that it is possible to write a swapping program on integers that does not use a temporary variable.

```
X := xor(X,Y)
Y := xor(X,Y)
X := xor(X,Y)
```

Prove that this program works. The program code you type in (excepting `assert` statements) should be exactly the three lines above.

**HINT:** The proof will be much easier if you put an `assert` after each line of code rewriting the formula for the state at that point as a pair of equations `/\`d together, one for `X` and one for `Y`.

```hoare {id=cw2025-q4b}
(hoare
 (program_vars X Y)
 (logic_vars x y)
 (assumptions
   (xor-cancel "all x. all y. xor(xor(x,y),y) = x")
   (xor-comm "all x. all y. xor(x,y) = xor(y,x)"))
 (precond "X = x /\ Y = y")
 (postcond "X = y /\ Y = x"))
```

### Question 4(c) (2 marks) {id=cw2025:q4:c}

The following program counts up the number of times `lookup(I)` returns `0` between `0` and `LEN - 1`:
```
I := 0
COUNT := 0
while (I != LEN) {
  if (lookup(I) = 0) {
    COUNT := add(COUNT,1)
  }
  I := add(I,1)
}
```

We will specify this program using a function called `countTo` which is defined by the following axioms:

1. There are zero items up to index `0`, so the count is `0`:
   ```formula
   countTo(0) = 0
   ```
2. If `lookup(i) = 0` then counting up to `i + 1` is one more than counting up to `i`:
   ```formula
   all i. lookup(i) = 0 -> countTo(add(i,1)) = add(countTo(i),1)
   ```
3. If `¬lookup(i) = 0` then counting up to `i + 1` is the same as counting up to `i`:
   ```formula
   all i. ¬lookup(i) = 0 -> countTo(add(i,1)) = countTo(i)
   ```

Prove that the program above correctly implements `countTo`:

```hoare {id=cw2025-q4c marks=2}
(hoare
 (program_vars COUNT I LEN)
 (assumptions
  (count-zero "countTo(0) = 0")
  (count-yes  "all i. lookup(i) = 0 -> countTo(add(i,1)) = add(countTo(i),1)")
  (count-no   "all i. ¬lookup(i) = 0 -> countTo(add(i,1)) = countTo(i)"))
 (precond "T")
 (postcond "COUNT = countTo(LEN)"))
```

---

**Remember to download your answers and submit them to MyPlace**.
