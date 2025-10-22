# Specification and Verification

```aside
This page assumes that you have understood the [predicate logic syntax](pred-logic-intro.html] and [proof rules for predicate logic](pred-logic-rules.html).
```

**This page is partially finished... there are exercises at the bottom, but most of the material is on the [slides](topic05-slides.pdf)**

One of the motivating reasons to use logic in Computer Science is to *specify* what software systems are supposed to do, and to *verify* that they actually do so.

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


## Example Specification and Verification Framework

### Execution Predicate

We define our (simplified) world of programs and their execution via one predicate `exec`:

```formula
exec(prog, initialState, finalState)
```

which means “running the program `prog` with the initial state `initialState` can finish with the final state `finalState`”.

1. There may be no output for a given input, which we would observe by a program “hanging” and never returning an output.

2. This definition also allows multiple possible answers for the same input, where we could have `exec(program, input, output1)` and `exec(program, input, output2)` both being true with `output1 != output2`. This can also be used to talk about programs where some part is left unspecified, such as an exact ordering of data in a container (see, for example, how the [Go Programming Language enforces that programs should not rely on the order of data stored in hashmaps](https://nathanleclaire.com/blog/2014/04/27/a-surprising-feature-of-golang-that-colored-me-impressed/)).

3. We do not distinguish between things that are program-like and things that are data-like for input and output. In particular, a program can take itself as an input. This flexibility of self reference will be crucial for stating the [halting problem and proving that it is undecidable](halting-problem.md).

4. This definition is highly simplified in many ways. It says nothing about the time, space, or other resources needed to carry out the computation of `output` from `input`. Nor does it directly allow for interactive computation where a program takes input and sends output during execution rather than at the start and end. Nevertheless, it does allow us to talk about what computers can and cannot compute.

## Properties

Equipped with the `exec` predicate, we can use it to state various properties of a program `prog`.

1. The program `prog` halts for the input `input`:

   ```formula
   ex output. exec(prog, input, output)
   ```

   The word “halts” comes from thinking of a computer as a machine that runs through small steps. A basic question is whether or not the machine runs forever, or halts with an answer. With our `exec` predicate, we are ignoring the details of individual steps, but we can still ask the question of whether or not a program produces an output.

2. The program `prog` halts for all inputs:

   ```formula
   all input. ex output. exec(prog, input, output)
   ```

   This is a stronger statement than the previous one. Instead of asking whether or not a program halts for a specific `input`, it asks whether or not it halts for *all* inputs.

3. The program `prog` does not halt on the input `input`:

   ```formula
   ¬(ex output. exec(prog, input, output))
   ```

   The negation of the first property states that a `prog` produces no answer on the input `input`.

4. The `exec` predicate allows for multiple potential outputs for a single input, which is referred to as being “non-deterministic”. If we want to specify that a program is “deterministic”, then we need to say that for any two outputs from the same input, those outputs are equal:

   ```formula
   all input. all output1. all output2. exec(prog, input, output1) -> exec(prog, input, output2) -> output1 = output2
   ```

5. The previous four statements don't mention what a program actually does. Usually we are interested in statements like “if the input looks like `P`, then the output looks like `Q`”.

   Examples:
   1. If the input is an array of numbers, the output is an array of the same numbers, but in sorted order.
   2. If the input is a Java program, the output is Java bytecode that correctly implements the same behaviour as the original program.
   3. If the input is a map and a start and end point, the output is the route from the start to the end point that is “the best”.
   4. If the input is a description of the obstacles currently visible on the road, the output is instructions to the car's steering, brakes and acceleration that avoids them in the safest way possible.

   As you can see from these examples, when we get to specifying interesting programs, the specifications get very vague and difficult to write down. Nevertheless, it is possible for some small critical parts of programs to give precise specifications, such as “this method actually sorts arrays”. It is also possible to give specifications about the *absence* of certain kinds of errors:

   1. If the input is not `null`, then this program never throws a `NullPointerException`.

   In general we call the input/output constraints a “specification”. The program `prog` satisfies a specification if whenever `P` is true for the input, then `Q` is true for any output of the program:

   ```formula
   all input. all output. P(input) -> exec(prog, input, output) -> Q(output)
   ```

   The predicate `P` is called the *precondition*, and the predicate `Q` is called the *postcondition*.

   This kind of specification is called *partial correctness*: it says that if the precondition holds *and the program halts*, then the postcondition holds for the output. This kind of specification is often written in the form:

   ```
       { P } prog { Q }
   ```

   called a *Hoare Triple* after C. A. R. Hoare, who invented the Hoare Logic named after him.

6. A stronger condition is *total correctness*, which says that if the precondition `P` holds, then the program always halts, and every output the program can generate satisfies the postcondition `Q`:

   ```formula
   all input. P(input) -> ((ex output. exec(prog, input, output)) /\ (all output. exec(prog, input, output) -> Q(output)))
   ```

   This kind of specification is often written in the form:

   ```
        [ P ] prog [ Q ]
   ```

## Hoare Logic for Partial Correctness

### Programs that do nothing

```focused-nd {id=specify-verify-partial-correct-skip}
(config
 (assumptions
  (exec-skip "all s1. all s2. exec(skip(), s1, s2) -> s1 = s2"))
 (goal "all s1. all s2. P(s1) -> exec(skip(), s1, s2) -> P(s2)"))
```

### Doing one thing after another

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

```focused-nd {id=specify-verify-partial-correct-update-bwd}
(config
 (assumptions
  (exec-update "all s1. all s2. exec(update(), s1, s2) -> s2 = doUpdate(s1)"))
 (goal "all s1. all s2. P(doUpdate(s1)) -> exec(update(), s1, s2) -> P(s2)"))
```

```focused-nd {id=specify-verify-partial-correct-update-fwd}
(config
 (assumptions
  (exec-update "all s1. all s2. exec(update(), s1, s2) -> s2 = doUpdate(s1)"))
 (goal "all s1. all s2. P(s1) -> exec(update(), s1, s2) -> (ex oldstate. s2 = doUpdate(oldstate) /\ P(oldstate))"))
```

### If-then-else

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

## Total Correctness

TBD...
