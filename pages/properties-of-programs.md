# Specifying Properties of Programs

```aside
This page assumes that you have understood the [proof rules for quantifiers](pred-logic-rules.html) and [proof rules for equality](equality.html) pages and completed all the exercises there.
```

So far, we have seen at least four ways that logic can be used in Computer Science:

1. Encoding problems in logic means that we can use SAT solvers to find solutions to problems. We looked at this in some depth in [Logical Modelling](logical-modelling-intro.html). It is possible to take these ideas further in Logic Programming languages such as [Prolog](https://www.metalevel.at/prolog).
2. Predicate Logic has a close connection with databases. We saw this in the definition of [models for Predicate Logic](pred-logic-semantics.html), where databases can be seen as finite models. Queries on a database are restricted forms of Predicate Logic formula.
3. If we can express our programs as *equations*, then we can use equational reasoning and induction to prove things about programs. We saw an example of this with [arithmetic and induction](induction.html), where addition and multiplication are defined by two equations each. Programming languages like [Haskell](https://www.haskell.org) are entirely based around making definitions by equations. You will start to learn Haskell CS260 next semester.
4. [We mentioned in passing](natural-deduction-intro.html) FIXME: better link; that it is also possible to view proofs as processes or programs transforming evidence. The [CS410 *Advanced Functional Programming*](https://github.com/gallais/CS410-2024) course in 4th year develops this idea much further.

In this page [and the next](halting-problem.html), we'll look at another way of talking about programs using Predicate Logic, where we use the logic to state properties of programs' behaviour directly, and the different statements we can make about programs' behaviour even in the simple case of non-interactive programs that consume one input and produce one output.

On [the next page](halting-problem.html), we'll see how to prove that there are some problems that are unsolvable by any program.

## The Execution Predicate

We define our (simplified) world of programs and their execution via one predicate:

1. `exec(program, input, output)` -- meaning that when we run `program` on `input` the result is `output`.

There may be no output for a given input, which we would observe by a program “hanging” and never returning an output.

This definition also allows multiple possible answers for the same input, where we could have `exec(program, input, output1)` and `exec(program, input, output2)` both being true with `output1 != output2`. This can be used to talk about programs where some part is left unspecified, such as an exact ordering of data in a container (see, for example, how the [Go Programming Language enforces that programs should not rely on the order of data stored in hashmaps](https://nathanleclaire.com/blog/2014/04/27/a-surprising-feature-of-golang-that-colored-me-impressed/)).

We do not distinguish between things that are program-like and things that are data-like. In particular, a program can take itself as an input. This flexibility of self reference will be crucial for stating the [halting problem and proving that it is undecidable](halting-problem.html).

This definition is highly simplified in many ways. It says nothing about the time, space, or other resources needed to carry out the computation of `output` from `input`. Nor does it directly allow for interactive computation where a program takes input and sends output during execution rather than at the start and end. Nevertheless, it does allow us to talk about what computers can and cannot compute.

### Specifying Properties of Programs

Equipped with the `exec` predicate symbol, we can use it to state various properties of a program `prog`.

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

### Relating the specifications

1. If a program halts for all inputs, then it halts for any specific input.

2. If the precondition is 'False' then it doesn't matter what the post condition is. This is true for partial and total correctness.

3. For partial correctness, if the postcondition is 'True', then the specification is always satisfied.

4. Total correctness implies partial correctness.

5. An alternative definition of total correctness for precondition `P` and postcondition `Q` is:

   ```formula
   all input. P(input) -> (ex output. exec(prog, input, output) /\ Q(output))
   ```

   For non-deterministic programs, this is weaker than the definition above, because it only says that one of the outputs satisfies the postcondition `Q`. However, if `prog` is also deterministic, then these two properties are equivalent.

```comment
## Relating programs

The properties of programs we explored above only talk about one program at a time.

1. Program refinement

2. Program equality
```

## Proving Properties of Programs

We won't get to proving things about actual programs in this course. Proofs about programs often involve very large amounts of simple steps that can be automated. The prover used in this course doesn't provide the kinds of automation that are useful in this setting. Nevertheless, we can describe the kinds of things we can say about programs

There are several tools that provide environments for proving properties of programs. Often they are restricted to the partial correctness property described above, because this often provides the best trade-off between usefulness and usability. Some tools are:

- [KeY](https://www.key-project.org/) -- a tool for proving properties about Java programs.
- [Dafny](https://dafny.org/) -- implements its own language and specification language , which can be compiled to other languages like Java, C#, and JavaScript.
- [Frama-C](https://frama-c.com/) -- a suite of tools for proving properties of programs written in C.
- [Spark ADA](https://www.adacore.com/about-spark) -- for proving properties of programs written in Ada, a language originally funded by the US Department of Defense, and used for embedded systems programming.
