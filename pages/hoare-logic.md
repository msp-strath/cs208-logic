# Hoare Logic

```aside
This page assumes that you have understood the [predicate logic syntax](pred-logic-intro.html) and [proof rules for predicate logic](pred-logic-rules.html). It will also help to know about the basics of [specifying and verifying code](specify-verify.html).
```

A Hoare Triple for partial correctness has the form:

```
  { P } program { Q }
```

where `P` and `Q` are formulas describing what is expected to be true before executing `program` (the *precondition*) and what will be true after `program` is executed (the *postcondition*). This is called *partial* correctness because we do not prove that `program` actually does finish, only that `Q` will be true if it does.

In Hoare Logic, it is usual to treat *program* variables (i.e., the names of parts of the computer's memory that can be read from and written to) as *logical* variables in formulas. The effect of this is that we can write the statement “the variable `X` has value 10 and the variable `Y` has value 5” as the formula:
```formula
X = 10 /\ Y = 5
```
instead of, where `s` is the current state:
```formula
valueOf(s, X(), 10) /\ valueOf(s,Y(),5)
```
This may seem obvious, but it does mean that we aren't working directly with predicates on states.

We will distinguish between program variables and logic variables by writing the former with capital letters (e.g., `X`, `Y`, `RESULT`) and the latter in lower case (e.g., `x`, `y`, `input`).

Hoare Logic is defined as a set of rules for proving statements of the form `{ P } program { Q }`. Most of the rules follow the structure of the program, so first we define what the programs that we are dealing with are. We will say that `<program>`s can be:

1. `end`: this indicates the end of a program, or part of a program inside an `if` or `while`.
2. `<var> := <term>`, where `<var>` is a program variable, and `<term>` is a term with only program variables in it. This is the program that performs an update to the state by writing a new value to a variable.
3. `if (<term> <rel> <term>) { <program> } else { <program> }`, where `<rel>` is either `=` or `!=`. This is the standard if-then-else.
4. `while (<term>) { program }`. This is the standard while loop.
5. `assert <formula>`. This is an assertion that says that the `<formula>` is true at this point in the program. We will use this to help construct proofs of programs as we shall we below.

This language is small, but illustrates the three basic operations of (imperative) programming: changing the state of the computer, making choices, and doing something in a loop until a condition is true.

## The Rules {id=hoare-logic:rules}

As for logical proofs, we construct proofs in Hoare Logic by applying rules. The examples below use an extended version of the proof tool that enables you to construct programs at the same time as the proofs about them. Note that this is a particular choice of the way this tool has been set up. It is more common to use Hoare Logic for constructing a proof against a specification for a *given* program. We construct the proof and program together here to show more clearly how the two interact.

The tool is used in the same way as the proof tool: the program and its proof is constructed incrementally by entering rules. The difference is now that there are rules for constructing programs as well as proofs. When in program constructing mode, the box shows the current goal (a pre- and postcondition) with an input box for the next command.

## Programs that do Nothing {id=hoare-logic:skip}

Sometimes, we are in the enviable position that our programs have nothing to do, or at least nothing more to do. If our specification's precondition and postcondition are the same, then the program can just `end`. You can see this by typing `end` into the `<command>` box and pressing Enter:

```hoare {id=hoare-skip0}
(hoare
 (program_vars X)
 (precond "X = 10")
 (postcond "X = 10")
 (solution (Rule(Program_rule End)())))
```

The program is verified against the specification because the precondition is exactly the same as the postcondition.

It might also be the case that there is nothing for a program to do, but showing this might require some proof. In this case, we need to prove that the precondition implies the postcondition. The same program `end` can be used here, but this time we will dropped into prover mode to complete the proof that `end` meets the specification:

```hoare {id=hoare-skip1}
(hoare
 (program_vars X Y)
 (precond "X = 10 /\ Y = 20")
 (postcond "X = 10")
 (solution (Rule(Program_rule End)((Rule(Proof_rule(Use H))((Rule(Proof_rule Conj_elim1)((Rule(Proof_rule Close)())))))))))
```

Notice that when we get dropped into proof mode, the precondition is given the name `H` and we are tasked to prove the postcondition. In this case, we can prove it with `use H`; `first`; `done`.

In many cases when proving things about programs, the proofs are boring and lengthy rearrangement of known facts. For this reason, the prover has been extended with a new `auto` command that can complete any proof that does not involve the `inst` or `exists` commands. Try it in the previous example by entering `auto` for the proof.

Program specifications can also have universal quantifiers and assumptions around them. The following program starts with a precondition that `X = x`, along with an assumption that `x = 10`. We can again use `end` to complete this program, but then have to prove that `x = 10` and `X = x` imply `X = 10`.

```hoare {id=hoare-skip2}
(hoare
 (program_vars X)
 (logic_vars x)
 (assumptions
  (x-is-10 "x = 10"))
 (precond "X = x")
 (postcond "X = 10")
 (solution (Rule(Program_rule End)((Rule(Proof_rule Auto)())))))
```

This proof can be completed using `rewrite->`, but is also simple enough for `auto` to complete.

The rule underlying the `end` command looks like this. The context `Γ` contains the assumed variables and assumptions.

```rules-display
(config
 (rule
  (name "end")
  (premises "Γ, P ⊢ Q")
  (conclusion "Γ ⊢ { P } - { Q }")))
```

In words, we a program that starts in state `P` immediately ends in state `Q` if `P` implies `Q`.

## Reading and writing variables {id=hoare-logic:assign}

A program that does nothing can only generate postconditions that are implied by the preconditions. The point, however, of most programs is to change the world in order to make the postconditions true. The way they do this is by setting variables.

### Setting a variable {id=hoare-logic:assign:set}

The following program assumes the precondition `T`, which is always true. To make the postcondition `X = 10` true, the program must assign `10` to `X` with the command `X := 10`.

Entering `X := 10` as the program leads to a state where the precondition is `∃oldX. X = 10 /\ T`. In words: there exists an old value of `X` and `X = 10` and `T` is true. In this case, the old value of `X` is not needed.

The program is completed by entering the command `end`. This drops us into the proof mode. Doing the proof by hand is lengthy because we need to unpack the existential statement to get at the fact that `X = 10`. However, this is exactly the kind of proof that `auto` is good at.

```hoare {id=hoare-assign1}
(hoare
 (program_vars X)
 (precond "T")
 (postcond "X = 10")
 (solution (Rule(Program_rule(Assign X(Fun 10())))((Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))
```

The next program requires that we write to two variables. In this simple language we assume that all variables are independent, so writing to one does not affect any others. Complete this program by entering `X := 10` and `Y := 20` as commands (in any order). Notice that the formula describing the state of the system expands as the assignments are performed. Once the program is finished by typing `end`, you are asked to prove that the effect of performing these two assignments is to make `X = 10 /\ Y = 20` true. Again, the `auto` command can do this for you.

```hoare {id=hoare-assign2}
(hoare
 (program_vars X Y)
 (precond "T")
 (postcond "X = 10 /\ Y = 20")
 (solution (Rule(Program_rule(Assign X(Fun 10())))((Rule(Program_rule(Assign Y(Fun 20())))((Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))))
```

Just for your peace of mind, try entering an *incorrect* program and seeing if the computer will accept your proof.

### Incrementing a variable {id=hoare-logic:assign:inc}

The formula generated by doing an assignment might seem to be overcomplicated. Why do we have to use this complex existential formula? If the current formula is `P` and we run the command `X := 10` why can't we just say that `X = 10 /\ P` is now true?

The reason is that `P` itself might say something about the value of `X` before the assignment. The assignment command overwrites the value of `X` so anything that was true about it before is no longer true. Therefore, we have to say that there exists an old value of `X` for which `P` is true.

Let's see how this works in a example. We are given the task of writing a program that adds 1 to the value of `X`, whatever that is. We specify “whatever that is” by the logical variable `x`, so the precondition is `X = x`.

The program to increment `X` is `X := add(X,1)` (the language doesn't have infix operators). If you try entering `X := add(x,1)`, the tool will complain because `x` is not a program variable: it does not exist in the program, only in the specification. Programs can only read and write program variables.

Entering `X := add(X,1)` yields the formula:
```formula
∃oldX. X = add(oldX,1) /\ oldX = x
```
which we can read as “there exists an old value of `X`, such that `X` is equal to adding one to it, and it is also equal to `x`”. This formula captures the effect of assigning a new value to a piece of memory, while still being able to talk about the old value.

```hoare {id=hoare-assign3}
(hoare
 (program_vars X)
 (logic_vars x)
 (precond "X = x")
 (postcond "X = add(x,1)")
 (solution (Rule(Program_rule(Assign X(Fun add((Var X)(Fun 1())))))((Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))
```

Again, the program is completed by typing `end`, and the proof can be completed by typing `auto`.

### Copying a variable and then incrementing it {id=hoare-logic:assign:copy-inc}

The previous program updated the value of `X`, but forgot the old value. Write a program that copies `X` into another variable `Y`, and then adds one to `X`:

```hoare {id=hoare-assign4}
(hoare
 (program_vars X Y)
 (logic_vars x)
 (precond "X = x")
 (postcond "Y = x /\ X = add(x,1)")
 (solution (Rule(Program_rule(Assign Y(Var X)))((Rule(Program_rule(Assign X(Fun add((Var X)(Fun 1())))))((Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))))
```

Again, `auto` will be able to complete the proof at the end.

### The Assignment Rule {id=hoare:assign:rule}

The deduction rule for assignment is this:

```rules-display
(config
 (rule
  (name "assign t to X")
  (premises "Γ ⊢ { ∃oldX. X = (t[X := oldX]) /\ P[X := oldX] } - { Q }")
  (conclusion "Γ ⊢ { P } - { Q }")))
```

In words, if we are proving that precondition `P` leads to postcondition `Q`, then making an assignment of `t` to `X` changes the precondition to assuming that there exists an `oldX` for which `P` is true, and that `X` is (now) equal to `t[X := oldX]`.

### Exercise {id=hoare-logic:assign:exercise}

The specification of this program is that the variables `X` and `Y` start with specific values `x` and `y`, and we want their values to be swapped by the end of the program. Luckily, we are given an additional variable `Z` to use.

```hoare {id=hoare-assign5}
(hoare
 (program_vars X Y Z)
 (logic_vars x y)
 (precond "X = x /\ Y = y")
 (postcond "X = y /\ Y = x")
 (solution (Rule(Program_rule(Assign Z(Var X)))((Rule(Program_rule(Assign X(Var Y)))((Rule(Program_rule(Assign Y(Var Z)))((Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))))))
```

When writing this program, you will notice that the formule involved gets quite long. We will see how to address this in the next topic.

## Making Decisions {id=hoare-logic:if}

If we just read and write variables, then the program always does the same thing. To write interesting programs, we need to change the behaviour based on the values stored in variables. This is done by using an `if` statement.

### Setting a variable conditionally {id=hoare-logic:if:setting}

The following program sets `RESULT` to `1` if `INPUT` is `5`:

```
if (INPUT = 5) {
  RESULT := 1
  end
} else {
  end
}
end
```

One specification of this program is that the postcondition is `INPUT = 5 -> RESULT = 1`. We can prove that this program meets this specification using the tool. To enter an if-then-else, you only need to enter `if (INPUT = 5)`, the tool will then generate the “then” and “else” branches for you. Look carefully at the pre- and postconditions being generated.

```hoare {id=hoare-if1}
(hoare
 (program_vars RESULT INPUT)
 (precond "T")
 (postcond "INPUT = 5 -> RESULT = 1"))
```

You should notice that the postconditions of the two branches of the if-then-else are unknown formulas `?Px` and `?Py` (the exact numbers vary). The *pre*condition of the program after the if-then-else is these two formulas ORed together. This is because, from the point of view of the contination of the program, either one of the two branches may have happened.

In this example, there is a much simpler way of meeting the specification given. We can also notice that the specification only says that *if* `INPUT` is `5` then the value of `RESULT` must be `1`. We can meet this specification by simply using the program:

```
RESULT := 1
```

Try this:

```hoare {id=hoare-if1v2}
(hoare
 (program_vars RESULT INPUT)
 (precond "T")
 (postcond "INPUT = 5 -> RESULT = 1")
 (solution (Rule(Program_rule(If(Rel(Var INPUT)Ne(Fun 5()))))((Rule(Program_rule End)())(Rule(Program_rule(Assign RESULT(Fun 1())))((Rule(Program_rule End)())))(Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))
```

### Specifying conditional setting of a variable {id=hoare-logic:if:specify}

To avoid the possibly unintended solution where the program does not actually check the `INPUT` variable, we need to specify what happens in the case that `INPUT` is not equal to `5` in the postcondition. Setting `RESULT` correctly in the “then” and “else” branches will yield a program that meets this specification:

```hoare {id=hoare-if2}
(hoare
 (program_vars RESULT INPUT)
 (precond "T")
 (postcond "(INPUT = 5 -> RESULT = 1)
            /\ (¬INPUT = 5 -> RESULT = 2)")
 (solution (Rule(Program_rule(If(Rel(Var INPUT)Eq(Fun 5()))))((Rule(Program_rule(Assign RESULT(Fun 1())))((Rule(Program_rule End)())))(Rule(Program_rule(Assign RESULT(Fun 2())))((Rule(Program_rule End)())))(Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))
```

You can also try writing this program the other way round by using `INPUT != 5` as the condition.

A more complex program is one that sets the `RESULT` variable according to the value of `INPUT`, but also unsets the `INPUT` variable. In this case, we need to remember what the old value of `INPUT` was by using a logical variable:

```hoare {id=hoare-if3}
(hoare
 (program_vars RESULT INPUT)
 (logic_vars input)
 (precond "INPUT = input")
 (postcond "(input = 5 -> RESULT = 1)
            /\ (¬input = 5 -> RESULT = 2)
			/\ INPUT = 0")
 (solution (Rule(Program_rule(If(Rel(Var INPUT)Eq(Fun 5()))))((Rule(Program_rule(Assign RESULT(Fun 1())))((Rule(Program_rule End)())))(Rule(Program_rule(Assign RESULT(Fun 2())))((Rule(Program_rule End)())))(Rule(Program_rule(Assign INPUT(Fun 0())))((Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))))
```

Again, `auto` will be able to complete the proof.

### The Rule {id=hoare-logic:if:rule}

The rule for `if (C)` has three premises. The first one is the “then” branch, which gets to assume that `C` is true. The second one is the “else” branch, which gets to assume that `C` is false. The final one is the continuation, the precondition is which is the *OR* of the postconditions of the two branches. It needs to deal with an *OR* because after the `if`, we don't know which of the two branches was taken.

```rules-display
(config
 (rule
  (name "if C")
  (premises "Γ ⊢ {C /\ P} - { R1 }" "Γ ⊢ {¬C /\ P} - { R2 }" "Γ ⊢ {R1 \/ R2} - {Q}")
  (conclusion "Γ ⊢ { P } - { Q }")))
```

### Exercise 1 {id=hoare-logic:if:ex1}

Write a program that sets `RESULT` to `1` if `INPUT` is `2`, but leaves it alone otherwise.

```hoare {id=hoare-if4}
(hoare
 (program_vars RESULT INPUT)
 (logic_vars originalResult)
 (precond "RESULT = originalResult")
 (postcond "(INPUT = 2 -> RESULT = 1) /\ (¬INPUT = 2 -> RESULT = originalResult)")
 (solution (Rule(Program_rule(If(Rel(Var INPUT)Eq(Fun 2()))))((Rule(Program_rule(Assign RESULT(Fun 1())))((Rule(Program_rule End)())))(Rule(Program_rule End)())(Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))
```

### Exercise 2 {id=hoare-logic:if:ex2}

The little language we are using here does not allow full logical expressions in a if-then-else, only equality and disequality tests. However, by nesting if-then-elses, we can simulate a logical AND. Complete the following program by using mutiple if-then-elses:

```hoare {id=hoare-if5}
(hoare
 (program_vars RESULT INPUT1 INPUT2)
 (precond "T")
 (postcond "((INPUT1 = 5 /\ INPUT2 = 10) -> RESULT = 1) /\ (¬(INPUT1 = 5 /\ INPUT2 = 10) -> RESULT = 2)")
 (solution (Rule(Program_rule(If(Rel(Var INPUT1)Eq(Fun 5()))))((Rule(Program_rule(If(Rel(Var INPUT2)Eq(Fun 10()))))((Rule(Program_rule(Assign RESULT(Fun 1())))((Rule(Program_rule End)())))(Rule(Program_rule(Assign RESULT(Fun 2())))((Rule(Program_rule End)())))(Rule(Program_rule End)())))(Rule(Program_rule(Assign RESULT(Fun 2())))((Rule(Program_rule End)())))(Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))
```

Likewise, it is possible to simulate a logical OR by using if-then-else in sequence:

```hoare {id=hoare-if6}
(hoare
 (program_vars RESULT INPUT1 INPUT2)
 (precond "T")
 (postcond "((INPUT1 = 5 \/ INPUT2 = 10) -> RESULT = 1) /\ (¬(INPUT1 = 5 \/ INPUT2 = 10) -> RESULT = 2)")
 (solution (Rule(Program_rule(Assign RESULT(Fun 2())))((Rule(Program_rule(If(Rel(Var INPUT1)Eq(Fun 5()))))((Rule(Program_rule(Assign RESULT(Fun 1())))((Rule(Program_rule End)())))(Rule(Program_rule End)())(Rule(Program_rule(If(Rel(Var INPUT2)Eq(Fun 10()))))((Rule(Program_rule(Assign RESULT(Fun 1())))((Rule(Program_rule End)())))(Rule(Program_rule End)())(Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))))))
```

There are several different ways of writing these programs. Try a few and look at the formulas generated. The solutions given are only one way of writing them. The proofs should always be finishable using `auto` without having to do any proofs by hand. Using proof automation here is almost essential to deal with the complexity of the formulas.

## Next {id=hoare-logic:next}

We have now looked at the Hoare Logic rules for dothing nothing, assigning variables, and making decisions. In order to do complete programs, the final thing we need is the ability to repeatedly do something until the state of the computer changes. We will look at this in the [next topic](hoare-loops.md).
