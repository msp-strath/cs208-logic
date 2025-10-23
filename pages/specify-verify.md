# Specification and Verification

```aside
This page assumes that you have understood the [predicate logic syntax](pred-logic-intro.html] and [proof rules for predicate logic](pred-logic-rules.html).
```

**This page is partially finished... there are exercises at the bottom, but most of the material is on the [slides](topic05-slides.pdf)**

One of the motivating reasons to use logic in Computer Science is to *specify* what software systems are supposed to do, and to *verify* that they actually do so. But first, we have to learn where specification and verification fit into the overall picture of software development.

## Validation and Verification

The problem of building a software system that is fit for purpose involves two key questions:

1. **Validation**: Are we building the right thing?
2. **Verification**: Are we building the thing right?

*Validation* is the question of whether or not the system that is being built is fit for the purpose that it is intended for. This question is answered by working with the “stakeholders” of the system, who include the actual users, as well as whoever is paying for the system, the people whose data is being stored (the “data subjects”), the people responsible for deploying and maintaining the system, relevant regulatory authorities (e.g, the [ICO](https://ico.org.uk/)), and others. One might include “physical reality” as a stakeholder too.

*Verification* is the question of whether or not the system built actually performs as required. This relates the code and hardware to the requirements identified by stakeholders.

The interface between these two questions is the **specification** of the system. The specification is the description of what the system is meant to do. Validation checks the specification against the real world, and verification checks the implementation against the specification.

In actual software systems, it is very rare for a complete specification to be written down. Some parts may be written down (e.g., “must run on iOS and Android”, “must interface with the PostgreSQL server”, “must store data X, Y, Z”), some might be legal requirements (e.g., compliance with [GDPR](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/)), some might be “common sense” (e.g., people's surnames don't contain spaces and [other false things](https://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/)), and some might be difficult to pin down (e.g., the game must be fun).

The process of coming up with a specification is not a one-off event. Software systems must adapt to changing requirements, and the presence of a software system itself changes the reality around it. So the processes of validation and verification are typically on going.

Software systems are not monolithic entities. A single system (e.g., the Pegasus system used at Strathclyde for student and staff records) will itself be composed of multiple sub-systems (e.g., payroll, admissions, curriculum history, exam boards, course catalogues, ...), and each of those will be built from components (e.g., databases, web frontend frameworks, message queues, reporting tools, ...), built on lower-level components (e.g., programming language implementations, operating systems, networks, ...) right down to the hardware. Each of these sub-systems and components has a specification and the questions of validation and verification need answering.

## Formal Specification

A specification is in some sense a contract between the implementor of a system and its stakeholders. (In some cases this is literally true.) It is therefore of interest to make sure that the specification is consistent and unambiguous, and to provide a method for verifying

In some cases, it is possible to write down parts of a system's specification as statements in formal logic.

Despite the fact that specifications for complete systems are often complex, fast moving, and difficult to write down, there are cases

TODO: finish this section. See [the slides](topic05-slides.pdf) for now.


### A Simple Model of Programs

We define our (simplified) world of programs and their execution via one predicate `exec`:

```formula
exec(prog, initialState, finalState)
```

which means “running the program `prog` with the initial state `initialState` can finish with the final state `finalState`”.

1. There may be no output for a given input, meaning that for a fixed `prog` and `initialState`, there may be no `finalState` for which `exec(prog, initialState, finalState)` is true. In terms of execution of real programs, we would observe this by a program “hanging” and never returning an output.

2. This definition also allows multiple possible answers for the same input, where we could have `exec(program, input, output1)` and `exec(program, input, output2)` both being true with `output1 != output2`. This can also be used to talk about programs where some part is left unspecified, such as an exact ordering of data in a container (see, for example, how the [Go Programming Language enforces that programs should not rely on the order of data stored in hashmaps](https://nathanleclaire.com/blog/2014/04/27/a-surprising-feature-of-golang-that-colored-me-impressed/)).

3. This definition does not distinguish between things that are program-like and things that are data-like for input and output. In particular, a program can take itself as an input. This flexibility of self reference will be crucial for stating the [halting problem and proving that it is undecidable](halting-problem.md).

4. This definition is highly simplified in many ways. It says nothing about the time, space, or other resources needed to carry out the computation of `output` from `input`. Nor does it allow for interactive computation where a program takes input and sends output during execution rather than at the start and end. Nevertheless, it does allow us to talk about what computers can and cannot compute.

### Properties of Programs

Equipped with the `exec` predicate, we can use it to state various properties of a program `prog`.

1. We can say “the program `prog` halts for the input `input`”:

   ```formula
   ex output. exec(prog, input, output)
   ```

   The word “halts” comes from thinking of a computer as a machine that steps through the computation. A basic question is whether or not the machine runs forever, or halts with an answer. With our `exec` predicate, we are ignoring the details of individual steps, but we can still ask the question of whether or not a program produces an output.

   As we will see when we look at the [halting problem](halting-problem.md), it is not possible to write a program that reliably determines whether or not a program halts on a particular input.

2. “The program `prog` halts for all inputs”:

   ```formula
   all input. ex output. exec(prog, input, output)
   ```

   This is a stronger statement than the previous one. Instead of asking whether or not a program halts for a specific `input`, it asks whether or not it halts for *all* inputs.

3. The program `prog` does not halt on the input `input`:

   ```formula
   ¬(ex output. exec(prog, input, output))
   ```

   The negation of the first property states that a `prog` produces no answer on the input `input`.

4. The `exec` predicate allows for multiple potential outputs for a single initial state, which is referred to as being “non-deterministic”. If we want to specify that a program is “deterministic”, then we need to say that for any two final states from the same initial state, those final states are equal:

   ```formula
   all s. all s1. all s2. exec(prog, s, s1) -> exec(prog, s, s2) -> s1 = s2
   ```

## Hoare Logic for Partial Correctness

The statements about programs we looked at above are quite generic, and don't say much about what programs actually do. Usually we are interested in statements like “if the inital state satisfies `P`, then the final state satisfies `Q`”.

For example:
   1. If the input is an array of numbers, the output is an array of the same numbers, but in sorted order.
   2. If the input is a Java program, the output is Java bytecode that correctly implements the same behaviour as the original program.
   3. If the input is a map and a start and end point, the output is the route from the start to the end point that is “the best”.
   4. If the input is a description of the obstacles currently visible on the road, the output is instructions to the car's steering, brakes and acceleration that avoids them in the safest way possible.

It is possible to think of “specifications” that are quite difficult to write down. Nevertheless, it is possible for some small critical parts of programs to give precise specifications, such as “this program sorts arrays”, or this “program

Using the `exec` predicate, we can write what it means for

The program `prog` satisfies a specification if whenever `P` is true for the input, then `Q` is true for any output of the program:

```formula
all input. all output. P(input) -> exec(prog, input, output) -> Q(output)
```

The predicate `P` is called the *precondition*, and the predicate `Q` is called the *postcondition*.

This kind of specification is called *partial correctness*: it says that if the precondition holds *and the program halts*, then the postcondition holds for the output. This kind of specification is often written in the form:

```
	{ P } prog { Q }
```

called a *Hoare Triple* after C. A. R. Hoare, who invented the Hoare Logic named after him. FIXME: citation.

The rules of Hoare Logic come in two groups:

- Logical rules, which incorporate logical reasoning about pre- and postconditions.
- Program rules, which

### Fixing a set of programs

```
prog := skip | seq(prog1,prog2) | update | ifC(prog1,prog2) | whileC(prog)
```

### Weakening and Strengthening Specifications

```rules-display
(config
 (rule
  (name "Consequence")
  (premises "s, P'(s) |- P(s)" "{ P } prog { Q }" "s, Q'(s) |- Q(s)")
  (conclusion "{ P' } prog { Q' }")))
```

```focused-nd {id=specify-verify-partial-correct-consequence}
(config
 (assumptions
  (pre "all s. P'(s) -> P(s)")
  (post "all s. Q(s) -> Q'(s)")
  (prog var)
  (prog-spec "all s1. all s2. P(s1) -> exec(prog, s1, s2) -> Q(s2)"))
 (goal "all s1. all s2. P'(s1) -> exec(prog, s1, s2) -> Q'(s2)"))
```

### Programs that do nothing

**Skip specification**
```formula
all s1. all s2. exec(skip(), s1, s2) -> s1 = s2
```

**Skip rule**
```rules-display
(config
 (rule
  (name "Skip")
  (conclusion "{ P } skip { Q }")))
```

```focused-nd {id=specify-verify-partial-correct-skip}
(config
 (assumptions
  (exec-skip "all s1. all s2. exec(skip(), s1, s2) -> s1 = s2"))
 (goal "all s1. all s2. P(s1) -> exec(skip(), s1, s2) -> P(s2)"))
```

### Doing one thing after another

**Sequence Specification**
```formula
all p1. all p2. all s1. all s2. exec(seq(p1, p2), s1, s2) -> (ex s. exec(p1, s1, s) /\ exec(p2, s, s2))
```

**Sequence rule**
```rules-display
(config
 (rule
  (name "Seq")
  (premises "{ P } prog1 { R }" "{ R } prog2 { Q }")
  (conclusion "{ P } seq(prog1, prog2) { Q }")))
```

```focused-nd {id=specify-verify-partial-correct-seq}
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

### Updating the state

**Updating Specification**
```formula
all s1. all s2. exec(update(), s1, s2) -> s2 = doUpdate(s1)
```

**Update Rule, version 1**
```rules-display
(config
 (rule
  (name "update-1")
  (conclusion "{ P[s := doUpdate(s)] } update { P }")))
```

```focused-nd {id=specify-verify-partial-correct-update-bwd}
(config
 (assumptions
  (exec-update "all s1. all s2. exec(update(), s1, s2) -> s2 = doUpdate(s1)"))
 (goal "all s1. all s2. P(doUpdate(s1)) -> exec(update(), s1, s2) -> P(s2)"))
```

**Update Rule, version 2**
```rules-display
(config
 (rule
  (name "update-2")
  (conclusion "{ P } update { ex o. s = doUpdate(o) /\ P[s := o] }")))
```

```focused-nd {id=specify-verify-partial-correct-update-fwd}
(config
 (assumptions
  (exec-update "all s1. all s2. exec(update(), s1, s2) -> s2 = doUpdate(s1)"))
 (goal "all s1. all s2. P(s1) -> exec(update(), s1, s2) -> (ex oldstate. s2 = doUpdate(oldstate) /\ P(oldstate))"))
```

### If-then-else

**Specification of if-then-else**
```formula
all p1. all p2. all s1. all s2. exec(ifC(p1, p2), s1, s2) -> ((C(s1) /\ exec(p1,s1,s2)) \/ (!C(s1) /\ exec(p2,s1,s2)))
```

**Rule for If-then-else**
```rules-display
(config
 (rule
  (name "If")
  (premises "{ C /\ P } prog1 { Q }" "{ ¬C /\ P } prog2 { Q }")
  (conclusion "{ P } ifC(prog1, prog2) { Q }")))
```

```focused-nd {id=specify-verify-partial-correct-if}
(config
 (assumptions
  (exec-if "all p1. all p2. all s1. all s2. exec(ifC(p1, p2), s1, s2) -> ((C(s1) /\ exec(p1,s1,s2)) \/ (!C(s1) /\ exec(p2,s1,s2)))")
  (prog1 var)
	(prog2 var)
  (prog1-spec "all s1. all s2. (C(s1) /\ P(s1)) -> exec(prog1, s1, s2) -> Q(s2)")
  (prog2-spec "all s1. all s2. (¬C(s1) /\ P(s1)) -> exec(prog2, s1, s2) -> Q(s2)"))
 (goal "all s1. all s2. P(s1) -> exec(ifC(prog1, prog2), s1, s2) -> Q(s2)"))
```

Note that the axiom for if implies that excluded middle is true for the predicate `C` whenever the program executes successfully:

FIXME

### While Loops

**Rule for While**
```rules-display
(config
 (rule
  (name "While")
  (premises "{ C /\ P } prog { P }")
  (conclusion "{ P } whileC(prog) { ¬C /\ P }")))
```

```formula
all p. all s1. all s2. exec(whileC(p),s1,s2) ->
  ((ex s. C(s1) /\ exec(p,s1,s) /\ exec(whileC(p),s,s2))
   \/
   (¬C(s1) /\ s1 = s2))
```

````comment

Need a fixpoint to make this work, induction principle:

```formula
(all s1 s s2. C(s1) -> exec(p,s1,s) -> P(s, s2) -> P(s1,s2)) ->
(all s. ¬C(s) -> P(s,s)) ->
all s1. all s2.
exec(whileC(p),s1,s2) -> P(s1,s2)
```

```focused-nd {id=specify-verify-partial-correct-while}
(config
 (assumptions
  (exec-while "all p. all s1. all s1. exec(whileC(
```

````

## Total Correctness

A stronger condition is *total correctness*, which says that if the precondition `P` holds, then the program always halts, and every output the program can generate satisfies the postcondition `Q`:

```formula
all s1. P(s1) -> ((ex s2. exec(prog, s1, s2)) /\ (all s2. exec(prog, s1, s2) -> Q(s2)))
```

Weaker one, which is equivalent in the presence of determinism:

```formula
all s1. P(s1) -> (ex s2. exec(prog, s1, s2) /\ Q(s2))
```

```focused-nd {id=specify-verify-total-equiv1}
(config
 (assumptions
  (prog var)
  (prog-total-spec "all s1. P(s1) -> ((ex s2. exec(prog, s1, s2)) /\ (all s2. exec(prog, s1, s2) -> Q(s2)))"))
 (goal "all s1. P(s1) -> (ex s2. exec(prog, s1, s2) /\ Q(s2))"))
```

```focused-nd {id=specify-verify-total-equiv2}
(config
 (assumptions
  (prog var)
  (prog-total-spec "all s1. P(s1) -> (ex s2. exec(prog, s1, s2) /\ Q(s2))")
  (prog-deterministic
   "all s. all s1. all s2. exec(prog,s,s1) -> exec(prog,s,s2) -> s1 = s2"))
 (goal "all s1. P(s1) -> ((ex s2. exec(prog, s1, s2)) /\ (all s2. exec(prog, s1, s2) -> Q(s2)))"))
```

Total Hoare triples are written like this:

```
	 [ P ] prog [ Q ]
```

### Weakening and Strengthening Specifications

```rules-display
(config
 (rule
  (name "Consequence")
  (premises "s, P'(s) |- P(s)" "[ P ] prog [ Q ]" "s, Q'(s) |- Q(s)")
  (conclusion "[ P' ] prog [ Q' ]")))
```


```focused-nd {id=specify-verify-total-correct-consequence}
(config
 (assumptions
  (pre "all s. P'(s) -> P(s)")
  (post "all s. Q(s) -> Q'(s)")
  (prog var)
  (prog-spec "all s1. P(s1) -> (ex s2. exec(prog, s1, s2) /\ Q(s2))"))
 (goal "all s1. P'(s1) -> (ex s2. exec(prog, s1, s2) /\ Q'(s2))"))
```

### Programs that do nothing

**Specification for skip (2)**
```formula
all s. exec(skip(), s, s)
```

**Skip rule**
```rules-display
(config
 (rule
  (name "Skip")
  (conclusion "[ P ] skip [ Q ]")))
```

```focused-nd {id=specify-verify-total-correct-skip}
(config
 (assumptions
  (exec-skip2 "all s. exec(skip(), s, s)"))
 (goal "all s1. P(s1) -> (ex s2. exec(skip(), s1, s2) /\ P(s2))"))
```

### Doing one thing after another

**Specification for sequencing (2)**
```formula
all p1. all p2. all s1. all s2. (ex s. exec(p1, s1, s) /\ exec (p2, s, s2)) -> exec(seq(p1, p2), s1, s2)
```

**Sequencing rule (total correctness)**
```rules-display
(config
 (rule
  (name "Seq")
  (premises "[ P ] prog1 [ R ]" "[ R ] prog2 [ Q ]")
  (conclusion "[ P ] seq(prog1, prog2) [ Q ]")))
```


```focused-nd {id=specify-verify-total-correct-seq}
(config
 (assumptions
  (exec-seq2 "all p1. all p2. all s1. all s2. (ex s. exec(p1, s1, s) /\ exec (p2, s, s2)) -> exec(seq(p1, p2), s1, s2)")
  (prog1 var)
  (prog2 var)
  (prog1-spec "all s1. P(s1) -> (ex s2. exec(prog1, s1, s2) /\ R(s2))")
  (prog2-spec "all s1. R(s1) -> (ex s2. exec(prog2, s1, s2) /\ Q(s2))"))
 (goal "all s1. P(s1) -> (ex s2. exec(seq(prog1, prog2), s1, s2) /\ Q(s2))"))
```

### Updating the state

**Specification for update (2)**
```formula
all s. exec(update(), s, doUpdate(s))
```

**Update Rule, version 1**
```rules-display
(config
 (rule
  (name "update-1")
  (conclusion "[ P[s := doUpdate(s)] ] update [ P ]")))
```

```focused-nd {id=specify-verify-total-correct-update-bwd}
(config
 (assumptions
  (exec-update2 "all s. exec(update(), s, doUpdate(s))"))
 (goal "all s1. P(doUpdate(s1)) -> (ex s2. exec(update(), s1, s2) /\ P(s2))"))
```

**Update Rule, version 2**
```rules-display
(config
 (rule
  (name "update-2")
  (conclusion "[ P ] update [ ex o. s = doUpdate(o) /\ P[s := o] ]")))
```

```focused-nd {id=specify-verify-total-correct-update-fwd}
(config
 (assumptions
  (exec-update2 "all s. exec(update(), s, doUpdate(s))"))
 (goal "all s1. P(s1) -> (ex s2. exec(update(), s1, s2) /\ (ex oldState. s2 = doUpdate(oldState) /\ P(oldState)))"))
```

### If-then-else

**Specification for if-then-else (2)**
1. ```formula
   all p1. all p2. all s1. all s2. C(s1) -> exec(p1, s1, s2) -> exec(ifC(p1, p2), s1, s2)
   ```
2. ```formula
   all p1. all p2. all s1. all s2. ¬C(s1) -> exec(p2,s1, s2) -> exec(ifC(p1, p2), s1, s2)
   ```

**Rule for If-then-else**
```rules-display
(config
 (rule
  (name "If")
  (premises "[ C /\ P ] prog1 [ Q ]" "[ ¬C /\ P ] prog2 [ Q ]")
  (conclusion "[ P ] ifC(prog1, prog2) [ Q ]")))
```

```focused-nd {id=specify-verify-total-correct-if}
(config
 (assumptions
  (exec-if2-true "all p1. all p2. all s1. all s2. C(s1) -> exec(p1, s1, s2) -> exec(ifC(p1, p2), s1, s2)")
  (exec-if2-false "all p1. all p2. all s1. all s2. ¬C(s1) -> exec(p2,s1, s2) -> exec(ifC(p1, p2), s1, s2)")
  (decide-C "all s. C(s) \/ ¬C(s)")
  (prog1 var)
  (prog2 var)
  (prog1-spec "all s1. (C(s1) /\ P(s1)) -> (ex s2. exec(prog1,s1,s2) /\ Q(s2))")
  (prog2-spec "all s1. (¬C(s1) /\ P(s1)) -> (ex s2. exec(prog2,s1,s2) /\ Q(s2))"))
 (goal "all s1. P(s1) -> (ex s2. exec(ifC(prog1,prog2),s1,s2) /\ Q(s2))"))
```

### While

**Rule for While**
```rules-display
(config
 (rule "While")
 (premises "∀x. [ C /\ P /\ f(s) = x ] prog [ P /\ f(s) < x ]")
 (goal "[ P ] whileC(prog) [ ¬C /\ P ]"))
```


## Summary

In the above, we have
