# CS208 Coursework 2026-2027

This is the coursework for semester one of CS208 *Logic and Algorithms* 2026/27.

It is worth 10% towards your final mark for all of CS208 (both semesters). The remainder of the marks come from the quizzes (5%), the algorithms coursework(s) in semester two (15%), and a final exam in April/May 2026 (70%).

The whole page is marked out of 20.

The questions are on this page, along with places for you to write your answers.  This page will remember the answers you type in, even if you leave the page and come back. Your browser's [local storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API/Using_the_Web_Storage_API) is used to store the data. If you delete saved data in your browser, or visit this page in private browsing mode and then close the window, you will lose your answers.

Once you have completed the questions, click on the “Download” button to download your answers as a file called `cs208-2026-coursework.answers`. When you are ready to submit your answers, upload the file to [the MyPlace submission page](https://classes.myplace.strath.ac.uk/mod/assign/view.php?id=2163360).

The deadline is **12:00 Wednesday 2nd December**. All extension requests should be submitted via [MyPlace](https://classes.myplace.strath.ac.uk/mod/assign/view.php?id=2163360).

```download
cs208-2026-coursework.answers
```

## Q0 (0 marks) {id=cw2026:q0}

Enter your name and registration number:

- Name:
  ```entrybox {id=cw2026-name}
  <name>
  ```

- Registration number:
  ```entrybox {id=cw2026-regnum}
  <registration-number>
  ```

## Q1 : Undefined Behaviour (2 marks) {id=cw2026:q1}

The [document defining the C programming language](https://www.iso.org/standard/82075.html) (available for free as a [draft copy](https://www.open-std.org/jtc1/sc22/wg14/www/docs/n3220.pdf)) includes the concept of *undefined behaviour* (Section 3.5.3). This means that there are things that have the syntax of C programs but the C standard does not assign them a behaviour for all possible inputs. A standards conforming C compiler is allowed to assume that the program it is asked to compile will only ever use behaviour that is defined by the standard. Therefore, if the program does do something that is undefined, then the C compiler is under no obligation to do anything “sensible” with the program.

The concept of undefined behaviour is surprisingly subtle. Usually we can rely on each part of a program having a well defined meaning. Sequential steps of a program apply those meanings one after the other until the program finishes. However, if the compiler is allowed to assume that some things *cannot happen* because doing so would lead to undefined behaviour then the compiler can draw surprising and non-obvious conclusions about the code.

Have a look at this snippet of C code. Assume that the variable `ptr` has type `int *` (i.e., it has the type of a pointer to an `int`).

```
if (ptr == NULL) {
  printf("ptr is NULL\n");
}
*ptr = 17;
```

We might hope to read this as “if `ptr` is `NULL` then print a message. Then write `17` into the memory location pointed to by `ptr`”. If `ptr` is actually `NULL` when this code gets executed then we might expect it to crash with a segmentation fault on the last line. But we would also expect it to have printed a message before that, helping us to diagnose the problem.

Surprisingly, the C standard **does not** require the compiler to print the message. In fact, the compiler is free to *completely remove the whole `if ... { ... }` from the code*.

The reason is that writing to a `NULL` pointer is *undefined behaviour* according to the C standard (Section 6.5.4.2, see footnote 101). Because a compiler is allowed to assume that the program will never use undefined behaviour, it is allowed to assume that `ptr` is *not* `NULL`. Therefore, the condition `ptr == NULL` cannot possibly be true, and therefore the body of the `if` will never run.

The chains of reasoning get quite long, so let's see how to model this situation using logic. We will use the following vocabulary to talk about an abstracted form of C programs:

1. `NULL()` will be the constant `NULL` value.
2. `dereferenced(x)` will be true if the variable `x` is dereferenced (i.e., read from or written to) at any point in the program.
3. `message-printed` is true if the message is printed.

On this vocabulary, we have several axioms. The first defines the rule above from the C standard: if a pointer is used, then it cannot be `NULL`:

```formula
all p. dereferenced(p) -> ¬(p = NULL())
```

We also encode the program into three axioms, which describe the programs' behaviour:

1. If `ptr` is `NULL` then the message gets printed:

   ```formula
   ptr = NULL() -> message-printed
   ```

2. If `ptr` is not `NULL` then the message does not get printed (this is implicit in the empty `else` branch in the program):

   ```formula
   ¬(ptr = NULL()) -> ¬message-printed
   ```

3. The variable `ptr` gets dereferenced (for this example, it does not matter what actual value gets written to `*ptr`):

  ```formula
  dereferenced(ptr)
  ```

With all of these axioms together, we can prove that the message does not get printed. Prove this using the [proof tool](pred-logic-rules.md):

```focused-nd {id=cw2026-1a marks=1}
(config
 (name "Question 1(a)")
 (assumptions
  (deref-not-null "all p. dereferenced(p) -> ¬(p = NULL())")
  (ptr            var)
  (yes-print      "ptr = NULL() -> message-printed")
  (no-print       "¬(ptr = NULL()) -> ¬message-printed")
  (ptr-derefd     "dereferenced(ptr)"))
 (goal "¬message-printed"))
```

This proof does not make any prior assumptions on what `ptr` is, so we can conclude that the message never gets printed *even if* `ptr` is `NULL`!

In fact, if `ptr` is `NULL` then the compiler has complete freedom to do whatever it wants, including making demons fly out of your nose. To model the possibility of nasal demonic transit we add the propositional atom `nasal-demons` to our vocabulary.

Now prove that the axioms above plus the fact that `ptr = NULL()` allows the compiler to justify `nasal-demons`:

```focused-nd {id=cw2026-1b marks=1}
(config
 (name "Question 1(b)")
 (assumptions
  (deref-not-null "all p. dereferenced(p) -> ¬(p = NULL())")
  (ptr            var)
  (yes-print      "ptr = NULL() -> message-printed")
  (no-print       "¬(ptr = NULL()) -> ¬message-printed")
  (ptr-derefd     "dereferenced(ptr)")
  (ptr-is-null    "ptr = NULL()"))
 (goal "nasal-demons"))
```

What makes C's undefined behaviour so confusing from a programmer's point of view is that the consequences of invoking undefined behaviour (in this example, dereferencing a `NULL` pointer) can flow *backwards* through the program. Normally, we expect that a part of a program may fail or work in an unexpected way, but the consequences of this ought to happen after that. It is inherent in the way that C compilers optimise code that information about what will happen “in the future” of a program's execution flows backwards.

````details
More details

The program given above does have the “expected” behaviour in all C compilers that I have tried it with. A C compiler is not required to necessarily exploit undefined behaviour.

However, with GCC 16.2 the similar code:
```
int unused = *ptr;
if (ptr == NULL) {
  printf("ptr is NULL\n");
}
*ptr = 17;
```
does compile as if it were just:
```
*ptr = 17;
```
because the first line is removed because variable `unused` is unused. The reasoning above then occurs and the `if` is removed. See [the Godbolt Compiler Explorer example](https://godbolt.org/#g:!((g:!((g:!((h:codeEditor,i:(filename:'1',fontScale:14,fontUsePx:'0',j:1,lang:___c,selection:(endColumn:2,endLineNumber:10,positionColumn:2,positionLineNumber:10,selectionStartColumn:2,selectionStartLineNumber:10,startColumn:2,startLineNumber:10),source:'/*+Type+your+code+here,+or+load+an+example.+*/%0A%23include+%3Cstdio.h%3E%0A%0Avoid+test(int+*ptr)+%7B%0A++++int+unused+%3D+*ptr%3B%0A++++if(ptr+%3D%3D+NULL)+%7B%0A++++++++printf(%22ptr+is+NULL%5Cn%22)%3B%0A++++%7D%0A++++*ptr+%3D+17%3B%0A%7D'),l:'5',n:'0',o:'C+source+%231',t:'0')),k:50,l:'4',n:'0',o:'',s:0,t:'0'),(g:!((h:compiler,i:(compiler:cg162,filters:(b:'0',binary:'1',binaryObject:'1',commentOnly:'0',debugCalls:'1',demangle:'0',directives:'0',execute:'1',intel:'0',libraryCode:'0',trim:'1',verboseDemangling:'0'),flagsViewOpen:'1',fontScale:14,fontUsePx:'0',j:1,lang:___c,libs:!(),options:'-O2',overrides:!(),selection:(endColumn:1,endLineNumber:1,positionColumn:1,positionLineNumber:1,selectionStartColumn:1,selectionStartLineNumber:1,startColumn:1,startLineNumber:1),source:1),l:'5',n:'0',o:'+x86-64+gcc+16.2+(Editor+%231)',t:'0')),k:50,l:'4',n:'0',o:'',s:0,t:'0')),l:'2',n:'0',o:'',t:'0')),version:4) to see how this is compiled by GCC 16.2 with optimisations turned on.

The series of articles [What Every C Programmer Should Know About Undefined Behavior, Part 1](https://blog.llvm.org/2011/05/what-every-c-programmer-should-know.html), [Part 2](https://blog.llvm.org/2011/05/what-every-c-programmer-should-know_14.html) and [Part 3](https://blog.llvm.org/2011/05/what-every-c-programmer-should-know_21.html) explain more about undefined behaviour in C. Programming in C is very difficult to get right, and if (when) you do it wrong, you can cause [internet-wide shutdowns and cybersecurity flaws](https://www.bbc.co.uk/news/articles/c3qjnwye0ep5o) (the article doesn't mention it, but the bug lies in unexpected behaviour of PHP's implementation in C).
````

## Q2 : Set Theory (3 marks) {id=cw2026:q2}

Predicate logic can be used as a foundational language for all of mathematics, but to do so we need to start from some axioms about what sort of things exist. *Set Theory* is a way of defining what mathematical things exist in terms of collections, called sets. The most common system of axioms for set theory is [Zermelo-Fraenkel Set Theory](https://en.wikipedia.org/wiki/Zermelo%E2%80%93Fraenkel_set_theory) which specifies 9 axioms (or "axiom schemas") that is enough to build almost all of modern mathematics. For this question we will look at two of the axioms: *pairing* and *union*.

In Set Theory, the only things that exist are sets and the only relationship that we have between things is membership. Membership is usually written as `x ∈ y` to mean `x` is a *member* of `y` (or `x` is an *element* of `y`). Here we will write this as `member(x,y)`. Everything in Set Theory is built from sets and the membership relation between them.

Informally, we write sets by listing their elements inside curly brackets. For example, `{ a, b, c }` is the set containing `a`, `b` and `c`. To express this in terms of the `member` relation we say that there exists a set `x` such that `member(a,x)`, `member(b,x)` and `member(c,x)`, and that for all `y` such that `member(y,x)` then `y = a` or `y = b` or `y = c`. Note that we have to give both a list of things that we know to be in the set and something that is true for everything in the set. (Compare to the introduction and elimination rules for the logical connectives.)

Saying that something is in a set twice (e.g., `member(a,x) /\ member(a,x)`) is equivalent to saying it is in the set once `member(a,x)`. This matches the usual idea of sets that duplicates don't matter: the set `{ a, a }` is the same as the set `{ a }`.

There are nine axioms in the usual description of ZF Set Theory. Most of the axioms tell us when certain sets exist. We will only look at two of them:

1. The *pair* axiom says that if `x` and `y` are sets, then there exists a set `p` such that `x` and `y` are members of `p`, and that `x` and `y` are the only members of `p`.

   ```formula
   all x. all y. ex p. (all w. member(w,p) -> (w = x \/ w = y)) /\ member(x,p) /\ member(y,p)
   ```

   Informally, the pair axiom says that if we have `x` and `y`, then the set `{ x, y }` exists.

2. The *union* axiom says that it is possible to “flatten” nested sets. For example, if we have a set of sets
   ```
     { {a, b, c}, {d, e, f}, {g, h}, {i} }
   ```
   then the *union* of these is all their elements flattened into one:
   ```
     { a, b, c, d, e, f, g, h, i }
   ```
   In general, if `x` is a set, then there exists a set `z` such that (1) for every `w` and `u` such that `w ∈ u` and `u ∈ x` then `w ∈ z`; and (2) if `w ∈ z` then there exists a `u` such that `u ∈ x` and `w ∈ u`.

   Expressed in logic, we write this as:
   ```formula
   all x. ex z. (all w. all u. member(w,u) -> member(u,x) -> member(w,z)) /\ (all w. member(w,z) -> (ex u. member(u,x) /\ member(w,u)))
   ```

### Q2(a) : Making Singletons {id=cw2026:q2:a}

Prove that the pairing axiom implies that singleton sets exist. That is, for every `x`, there is a set `s` that contains `x` and only `x`. This set is usually written as `{x}`.

```focused-nd {id=cw2026-2a marks=1}
(config
 (name "Question 2(a)")
 (assumptions
  (pair-axiom "all x. all y. ex p. (all w. member(w,p) -> (w = x \/ w = y)) /\ member(x,p) /\ member(y,p)"))
 (goal "all x. ex s. member(x,s) /\ (all w. member(w,s) -> w = x)"))
```

### Q2(b) : Unions of two sets {id=cw2026:q2:b}

The union axiom states that a set of sets can be “flattened” to a single set by combining all their elements. A useful special case of this is the union of two sets: if `x` and `y` are sets, then their union (usually written `x ∪ y`) contains all the elements of `x` and all the elements of `y` and nothing else.

Prove that the union of `x` and `y` exists as a consequence of the pairing and union axioms:

```focused-nd {id=cw2026-2b marks=1}
(config
 (name "Question 2(b)")
 (assumptions
  (pair-axiom "all x. all y. ex z. (all w. (member(w,z) -> (w = x \/ w = y))) /\ member(x,z) /\ member(y,z)")
  (union-axiom "all x. ex z. (all w. all u. member(w,u) -> member(u,x) -> member(w,z)) /\ (all w. member(w,z) -> (ex u. member(u,x) /\ member(w,u)))"))
 (goal "all x. all y. ex u. (all w. (member(w,x) \/ member(w,y)) -> member(w,u)) /\ (all w. member(w,u) -> (member(w,x) \/ member(w,y)))"))
```

### Q2(c) : Making triples {id=cw2026:q2:c}

The pairing axiom says that we can form the set `{x,y}` from `x` and `y`. Part (a) above says we can form `{x}` from `x`. Prove that from `x`, `y`, `z` we can make the set `{x,y,z}`.

```focused-nd {id=cw2026-2c marks=1}
(config
 (name "Question 2(c)")
 (assumptions
  (pair-axiom "all x. all y. ex z. (all w. (member(w,z) -> (w = x \/ w = y))) /\ member(x,z) /\ member(y,z)")
  (union-axiom "all x. ex z. (all w. all u. member(w,u) -> member(u,x) -> member(w,z)) /\ (all w. member(w,z) -> (ex u. member(u,x) /\ member(w,u)))"))
 (goal "all x. all y. all z. ex t. member(x,t) /\ member(y,t) /\ member(z,t) /\ (all w. member(w,t) -> (w = x \/ w = y \/ w = z))"))
```

## Q3 : Hoare Logic is Sound (3 marks) {id=cw2026:q3}

We have described the [rules of Hoare Logic](hoare-logic.md), but have not proved them sound with respect to our [simple model of computation](specify-verify.md#specify-verify:simple-model). You will do this now.

The rules are given here in a slighly more standard way than the way that the tool presents them. The tool presents a "forward first" approach that traces the path of a formula throughout the program starting at the start, while the standard approach is unbiased and allows the proof to explore the program in any order.

We will be using the definition of a Hoare Logic triple `{P} prog {Q}` in terms of the `exec` predicate:
```formula
all s1. all s2. P(s1) -> exec(prog, s1, s2) -> Q(s2)
```
In words: if `P` is true for the initial state `s1`, and executing `prog` get us from state `s1` to state `s2`, then `Q` is true of the final state `s2`.

For the rules below (except for *Consequence*), we will have to assume certain properties of the `exec` predicate for the relevant kinds of program. We introduce these as we go.

### Q3(a) : Logical Consequence {id=cw2026:q3:a}

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

```focused-nd {id=cw2026-q3a marks=0.5}
(config
 (name "Question 3(a): Consequence")
 (assumptions
  (pre "all s. P'(s) -> P(s)")
  (post "all s. Q(s) -> Q'(s)")
  (prog var)
  (prog-spec "all s1. all s2. P(s1) -> exec(prog, s1, s2) -> Q(s2)"))
 (goal "all s1. all s2. P'(s1) -> exec(prog, s1, s2) -> Q'(s2)"))
```

### Q3(b) : Doing Nothing {id=cw2026:q3:b}

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
```focused-nd {id=cw2026-q3b marks=0.5}
(config
 (name "Question (b): Doing Nothing")
 (assumptions
  (exec-skip "all s1. all s2. exec(skip(), s1, s2) -> s1 = s2"))
 (goal "all s1. all s2. P(s1) -> exec(skip(), s1, s2) -> P(s2)"))
```

### Q3(c) : Sequencing {id=cw2026:q3:c}

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
```focused-nd {id=cw2026-q3c marks=0.5}
(config
 (name "Question 3(c): Sequencing")
 (assumptions
  (exec-seq   "all p1. all p2. all s1. all s2. exec(seq(p1, p2), s1, s2) -> (ex s. exec(p1, s1, s) /\ exec(p2, s, s2))")
  (prog1 var)
  (prog2 var)
  (prog1-spec "all s1. all s2. P(s1) -> exec(prog1,s1,s2) -> R(s2)")
  (prog2-spec "all s1. all s2. R(s1) -> exec(prog2,s1,s2) -> Q(s2)")
 )
 (goal "all s1. all s2. P(s1) -> exec(seq(prog1, prog2), s1, s2) -> Q(s2)"))
```

### Q3(d) : Assignment (backward) {id=cw2026:q3:d}

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

```focused-nd {id=cw2026-q3d marks=0.5}
(config
 (name "Question 3(d): Assignment (backward)")
 (assumptions
  (exec-update "all s1. all s2. exec(update(), s1, s2) -> s2 = doUpdate(s1)"))
 (goal "all s1. all s2. P(doUpdate(s1)) -> exec(update(), s1, s2) -> P(s2)"))
```

### Q3(e) : Assignment (forward) {id=cw2026:q3:e}

The alternative version of the rule for `update()` reasons forwards. This is the form that is used in the tool. The rule is:
```rules-display
(config
 (rule
  (name "update-2")
  (conclusion "{ P } update { ex oldS. s = doUpdate(oldS) /\ P[s := oldS] }")))
```

This rule is perhaps easier to explain. If `P` is true about the current state before the update, then after the update there exists an old state, where the new states is equal to the update of the old state and `P` is true about the old state.

Prove this rule using the same axiom for `update()` as above:
```focused-nd {id=cw2026-q3e marks=0.5}
(config
 (name "Question 3(e): Assignment (forward)")
 (assumptions
  (exec-update "all s1. all s2. exec(update(), s1, s2) -> s2 = doUpdate(s1)"))
 (goal "all s1. all s2. P(s1) -> exec(update(), s1, s2) -> (ex oldstate. s2 = doUpdate(oldstate) /\ P(oldstate))"))
```

### Q3(f) : If-then-else {id=cw2026:q3:f}

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
```focused-nd {id=cw2026-q3f marks=0.5}
(config
 (name "Question 3(e): If-then-else")
 (assumptions
  (exec-if "all p1. all p2. all s1. all s2. exec(ifC(p1, p2), s1, s2) -> ((C(s1) /\ exec(p1,s1,s2)) \/ (!C(s1) /\ exec(p2,s1,s2)))")
  (prog1 var)
	(prog2 var)
  (prog1-spec "all s1. all s2. (C(s1) /\ P(s1)) -> exec(prog1, s1, s2) -> Q(s2)")
  (prog2-spec "all s1. all s2. (¬C(s1) /\ P(s1)) -> exec(prog2, s1, s2) -> Q(s2)"))
 (goal "all s1. all s2. P(s1) -> exec(ifC(prog1, prog2), s1, s2) -> Q(s2)"))
```

## Q4 : Straight Line Programs (3 marks) {id=cw2026:q4}

These three sub-questions all involve proving something about programs that do not involve any loops using the [rules of Hoare Logic](hoare-logic.md). You will also find [assertions and automation](hoare-assert-and-auto.md) useful.

### Q4(a) : One step forward, one step back {id=cw2026:q4:a}

Adding and then subtracting gets you back to where you started:
```formula
all x. all y. sub(add(x,y),y) = x
```

Use this fact to write the following program that ends with a copy of `X` in `Y` and the sum of them in `X`. You should be able to write the program with one assignment to each of `X` and `Y`.

**HINT:** The final proof will involve spliting, rewriting the goal using `add-sub`, and then `auto`. It might be easier to see what is going on if you put an `assert` just before the final line of the program that describes the final values of `X` and `Y` in terms of `x` and `y` (and `add` and `sub`) without any indirections through `oldX` and `oldY`.

```hoare {id=cw2026-q4a marks=1}
(hoare
 (name "Question 4(a) : Add and Subtract")
 (program_vars X Y)
 (logic_vars x y)
 (assumptions
  (add-sub "all x. all y. sub(add(x,y),y) = x"))
 (precond "X = x /\ Y = y")
 (postcond "Y = x /\ X = add(x,y)"))
```

### Q4(b) : Swapping with XOR {id=cw2026:q4:b}

The bitwise `xor` function on pairs of integers has the following two useful properties:

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

```hoare {id=cw2026-q4b marks=1}
(hoare
 (name "Question 4(b): XOR swap")
 (program_vars X Y)
 (logic_vars x y)
 (assumptions
   (xor-cancel "all x. all y. xor(xor(x,y),y) = x")
   (xor-comm "all x. all y. xor(x,y) = xor(y,x)"))
 (precond "X = x /\ Y = y")
 (postcond "X = y /\ Y = x"))
```

### Q4(c) : Swapping Array Elements {id=cw2026:q4:c}

This program swaps two elements of an array `A` at indexes `I` and `J`. All other elements of the array are left as they were before:
```
Temp := get(A,I)
A := set(A, I, get(A, J))
A := set(A, J, Temp)
```

Using the [axioms for arrays](hoare-arrays.md), write a proof that this program satisfies the specification. We assume that `I` and `J` are different to cut down on cases in the proof, although the program does still work in this case.

You can add as many `assert`s as you need, but the program code should be exactly the same as above.

```hoare {id=cw2026-q4c marks=1}
(hoare
 (name "Question 4(c): Array swap")
 (program_vars A I J Temp)
 (logic_vars arr)
 (assumptions
   (get-set "∀a. ∀i. ∀x. get(set(a, i, x), i) = x")
   (get-get "∀a. ∀i. ∀j. ∀x. ¬i = j → get(set(a, i, x), j) = get(a, j)"))
 (precond "A = arr /\ ¬I = J")
 (postcond "get(A,I) = get(arr,J) /\ get(A,J) = get(arr,I) /\ (all i. ¬i = I -> ¬i = J -> get(A,i) = get(arr,i))"))
```

**HINT:** It is useful to add an assert at the end of the program but before `end` that summarises in one line how the final value of `A` relates to the initial value of the array in `arr`.

## Q5 : Programs with Loops (3 marks) {id=cw2026:q5}

The next three questions involve programs with loops. The programs are given to you, but to complete the proofs you will need to work out the right [loop invariant](hoare-loops.md) to use, and how to use the axioms given to complete the proof.

### Q5(a) : Counting {id=cw2026:q5:a}

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

Prove that the program above correctly implements `countTo`. You can add as many `assert`s as you need, but the program code should be exactly the same as above.

```hoare {id=cw2026-q5a marks=1}
(hoare
 (name "Question 5(a) : Counting Zeros")
 (program_vars COUNT I LEN)
 (assumptions
  (count-zero "countTo(0) = 0")
  (count-yes  "all i. lookup(i) = 0 -> countTo(add(i,1)) = add(countTo(i),1)")
  (count-no   "all i. ¬lookup(i) = 0 -> countTo(add(i,1)) = countTo(i)"))
 (precond "T")
 (postcond "COUNT = countTo(LEN)"))
```

### Q5(b) : Summing {id=cw2026:q5:b}

The following program sums up the numbers in an array `A` up to but not including the `N`th element., putting the result into the variable `SUM`.
```
I := 0
SUM := 0
while (I != N) {
  SUM := add(SUM,get(A,I))
  I := add(I,1)
}
```

The behaviour of this program can be specified by the following pair of equations:

1. Summing up to the `0`th element is `0`:
   ```formula
   all arr. sumArray(arr, 0) = 0
   ```

2. Summing up to the `n+1`th element is summing up to the `n`th element plus the `n`th element:
   ```formula
   all arr. all i. sumArray(arr,add(i,1)) = add(sumArray(arr,i), get(arr,i))
   ```

Prove that the program above correctly implements `sumArray`. You can add as many `assert`s as you need, but the program code should be exactly the same as above.

```hoare {id=cw2026-q5b marks=1}
(hoare
 (name "Question 5(b) : Summing")
 (program_vars I SUM A N)
 (assumptions
  (sum-array-zero "all arr. sumArray(arr, 0) = 0")
  (sum-array-step "all arr. all i. sumArray(arr,add(i,1)) = add(sumArray(arr,i), get(arr,i))"))
 (precond "T")
 (postcond "SUM = sumArray(A,N)"))
```

### Q5(c) : Running Sum {id=cw2026:q5:c}

The following program computes the running sums of an array `A`. At the end of the program, the output array `B` at element `i` contains the sum of the elements of `A` up to `i`.

```
SUM := 0
I := 0
while (I != N) {
  B := set(B, I, SUM)
  SUM := add(SUM, get(A, I))
  I := add(I,1)
}
```

Prove that this program satisfies the specification written above. You will need to use the `sumArray` axioms from before with the array `get` and `set` axioms and the axioms for `between` from the [page on Hoare logic with arrays](hoare-arrays.md).

You can add as many `assert`s as you need, but the program code should be exactly the same as above.

```hoare {id=cw2026-q5c marks=1}
(hoare
 (name "Question 5(c) : Running Sum")
 (program_vars SUM I N A B)
 (assumptions
  (sum-array-zero "all arr. sumArray(arr, 0) = 0")
  (sum-array-step "all arr. all i. sumArray(arr,add(i,1)) = add(sumArray(arr,i), get(arr,i))")
  (get-set "all a. all i. all x. get(set(a,i,x),i) = x")
  (get-get "all a. all i. all j. all x. ¬i = j -> get(set(a,i,x),j) = get(a,j)")
  (between-empty "all i. all j. ¬between(i,j,j)")
  (between-step "all x. all s. all i. between(x, s, add(i,1)) -> ((between(x,s,i) /\ ¬(x = i)) \/ x = i)"))
 (precond "T")
 (postcond "all i. between(i,0,N) -> get(B,i) = sumArray(A,i)"))
```

## Q6 : Register Allocation (3 marks) {id=cw2026:q6}

Compilers have to translate from high level code that uses any amount of variables to low-level machine code that only has as many registers as the CPU has. Each variable in the high-level code must be assigned to a register in the machine code, but since there may be fewer registers than variables in the original code we have to find a way of reusing registers where possible.  This is a kind of resource allocation problem. One way to solve this problem is to express the problem in terms of logical constraints and ask the computer to find a solution. We will do this by expressing valid allocations as [models of logical theories](pred-logic-semantics.md).

```details
The Truth...

Real compilers don't, in general, use logical modelling in the way explained here, at least not directly. Register allocation is only part of the problem that compilers have to solve, which also includes instruction selection and scheduling that interact with register allocation. In practice, real compilers use a collection of greedy algorithms and heuristics to make sure they do not take too long to compile code. They also have to deal with the case when there are too few registers for the variables used in the program, in which case they have to “spill” to memory. However, logical modelling is a nice way of thinking about the problem conceptually before committing to a particular solution strategy.
```

As an example, we will look at the following program (though the solution you will write should work for any program by changing the constraints). The program uses six variables, and is written in [Static Single Assignment (SSA)](https://en.m.wikipedia.org/wiki/Static_single-assignment_form) form. This means that every variable is only written to once, which makes things easier (most modern compilers use SSA internally).

```
1. X = 5
2. Y = 6
3. Z = X + Y
4. W = X + Z
5. U = W + Z
6. V = U + X
7. return V
```

Let's say we are compiling to a machine with only three registers `R1`, `R2`, `R3`. To systematically work out how to assign registers to variables, we need to work out the "live ranges" of each variable: the range of instructions for which a variable is required to have a place to call its own. If two variables have overlapping live ranges then they must be stored in separate registers. If not they can "share" a register.

For this program, the live ranges for each variable are as follows, where the starting instruction is when it gets assigned and the finish instruction is the last time it is used.

```
X : 1 to 6
Y : 2 to 3
Z : 3 to 5
W : 4 to 5
U : 5 to 6
V : 6 to 7
```

If two variables have ranges `(s1,e1)` and `(s2,e2)`, then they can only share a register if either `e1 <= s2` or `e2 <= s1` (it is ok for the start of one to be the same as the end of another if we assume that the add instruction can write to the same register as one of its arguments). If two variables have overlapping live ranges then they **conflict**.

**Question**

1. Complete the theory `RegisterAllocation` below by filling in the axiom definitions to make sure that for any model of this theory, `allocated` is a valid allocation of variables to registers avoiding conflicts.

2. Fill in the empty definitions in the model `Example` to accurately model the register allocation problem described above. The universe has been filled in for you.

```model-checker {id=cw2026-q6}
theory RegisterAllocation {
  // What sort of things are there?
  predicate variable/1
  predicate register/1

  // What things conflict?
  predicate conflict/2

  // What is allocated to what?
  predicate allocated/2

  // Axiom: if x is allocated to y, then x is a variable and y is a register
  axiom ax0 : "T"

  // Axiom: every variable is allocated to some register
  axiom ax1 : "T"

  // Axiom: no variable is allocated more than one register
  axiom ax2 : "T"

  // Axiom : if x conflicts with y, then x and y are both variables
  axiom ax3 : "T"

  // Axiom : if x conflicts with y, then they are not allocated the same register
  axiom ax4 : "T"
}

// Fill in 'variable', 'register' and 'conflict'
// to get 'allocated' generated following the axioms.
model Example for RegisterAllocation {
  universe = { U, V, W, X, Y, Z, R1, R2, R3 }

  // What things are registers?
  register = { }

  // What things are variables?
  variable = { }

  // What things are in conflict?
  conflict = { }

  // Get the computer to compute an allocation.
  // DO NOT remove the '?'
  allocated = ?
}
```

## Q7 : Planning (3 marks) {id=cw2026:q7}

A planning problem is where we are asked to invent a way of achieving a goal by making actions.  We can use logic to solve many kinds of planning problem. Given a logical description of what it means to be a good plan and constraints on what actions can be taken, we can get computers to write plans for us. In this question you will develop a simple logical description of good plans that can be used by the computer to generate plans to meet specific goals.

You are asked to write a theory for describing plans where a robot has to be in a sequence of locations, one for each timestep. Across consecutive timesteps, the robot can only move between locations that are linked. The robot must hit several specified waypoints.

To define what we mean by a plan, we need to represent times and places logically.

### Time {id=cw2026:q7:time}

We model time as a collection of timesteps related to each other by a relation `next/2`. The idea is that timesteps are any `t` for which `timestep(t)` is true, and two timesteps are consecutive if the relation `next(t1,t2)` is true.

We will not specify any particular axioms about time in our theory. The nature of time will be something that is given by the model itself. For some purposes, it might make sense for time to be have branches or to have loops.

For the example planning scenario here though, we will assume that there are six timesteps `T1`, `T2`, `T3`, `T4`, `T5`, `T6`, and that `next(x,y)` is true for each pair in sequence. Only immediately consecutive timesteps are related by `next`: we have `next(T1,T2)` and `next(T2,T3)` but not `next(T1,T3)`.

### Place {id=cw2026:q7:place}

We model the places that can be moved to as locations related to each other by `linked/2`. Locations are things `l` such that `location(l)` is true. Two locations `l1` and `l2` are directly linked if `linked(l1,l2)` is true. The idea is that if two locations are linked, then the robot can move from one to the other in between two immediately subsequent timesteps.

For the example planning scenario here, we assume the locations `Store`, `Factory`, `LoadingBay`, `Road`, `Yard`, and `WasteHeap`. These are linked in the following way:

```
    (Store, Factory)
    (Store, Yard)
    (Factory, Store)
    (Factory, LoadingBay)
    (Yard, Factory)
    (Yard, Store)
    (Yard, WasteHeap)
    (WasteHeap, Road)
    (WasteHeap, Yard)
    (LoadingBay, WasteHeap)
    (LoadingBay, Factory)
    (LoadingBay, Road)
```

### Waypoints {id=cw2026:q7:waypoints}

A *waypoint* is a particular `(time,location)` pair that must be met during the plan. We represent these using a predicate `waypoint/2`.

In the example here, we want the robot to be in the `Store` at timestep `T1` and at the `Road` at timestep `T6`.

### Representing Plans {id=cw2026:q7:plans}

We represent a plan using a predicate `robot-at/2`. If we have `robot-at(t,l)`, then at timestep `t` the robot is at location `l`. To be a valid plan, this predicate must satisfy the following properties:

1. If the robot at time `t` is at `l`, then `t` is a timestep and `l` is a location.
2. At every timestep, the robot is at some location.
3. The robot is never in more than one location at each timestep.
4. For each consecutive pair of timesteps `t1` and `t2`, the location at time `t1` and the location at time `t2` are linked.
5. Each waypoint is met by the robot.

### Plans are Models {id=cw2026:q7:plans-are-models}

The editor box below is set up with a theory with the vocabulary described above and a partial model of this vocabulary for the example planning problem.

If you click ‘Run’, it will generate an empty plan (i.e., an empty definition of `robot-at/2` where nothing is true). The empty plan is not a valid plan.

Add axioms to the theory that generate a valid plan for the robot. Make sure that your axioms match the five properties for a good plan listed above. You should put in the axioms that match the properties above, not just ones that happen to give a valid plan in this example. Your axioms should work for all examples.

```model-checker {id=cw2026-q7}
theory Planning {
  predicate timestep/1
  predicate next/2

  predicate location/1
  predicate linked/2

  predicate waypoint/2

  predicate robot-at/2

  // Fill in your axioms here
}

model Factory for Planning {
  // The universe consists of times and places
  universe = {
    T1, T2, T3, T4, T5, T6,
    Store, Factory, LoadingBay, Road, Yard, WasteHeap
  }

  // some things are times
  timestep = { T1, T2, T3, T4, T5, T6 }

  // and some things are places
  location = { Store, Factory, LoadingBay, Road, Yard, WasteHeap }

  // times are related by being in a sequence
  next = { (T1, T2), (T2, T3), (T3, T4), (T4, T5), (T5, T6) }

  // places are related by the possibility of moving from one to another
  linked = {
    (Store, Factory),
    (Store, Yard),
    (Factory, Store),
    (Factory, LoadingBay),
    (Yard, Factory),
    (Yard, Store),
    (Yard, WasteHeap),
    (WasteHeap, Road),
    (WasteHeap, Yard),
    (LoadingBay, WasteHeap),
    (LoadingBay, Factory),
    (LoadingBay, Road)
  }

  // Certain times and places are fixed
  waypoint = { (T1, Store), (T6, Road) }

  // The plan, what is it? Get the computer to
  // work it out from your axioms! DO NOT solve the
  // problem yourself.
  robot-at = ?
}
```

---

**Remember to download your answers and submit them to MyPlace**.
