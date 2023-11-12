# Arithmetic and Induction

```aside
This page assumes that you have understood the [proof rules for quantifiers](pred-logic-rules.html) and [proof rules for equality](equality.html) pages and completed all the exercises there.
```

Now we can talk about [equality](equality.html) in our proof system, we can start to talk about useful things like numbers and arithmetic, and make statements like the fact that addition is commutative (i.e., it doesn't matter which way round we add things):

```formula
∀ x. ∀ y. add(x,y) = add(y,x)
```

However, we cannot yet prove statements like this. To be able to prove such statements, we use a collection of [axioms](https://en.wikipedia.org/wiki/Peano_axioms) set out by [Giuseppe Peano](https://en.wikipedia.org/wiki/Giuseppe_Peano) in the 19th century. These axioms specify a way of representing numbers, the laws for addition and multiplication, and the proof principle of induction, which allows us to prove facts about all natural numbers.

The axioms, including induction, are introduced in the following video, and explained below with exercises in the interactive proof editor.

```youtube
2hZCKrHmuTo
```

```textbox {id=induction-note1}
Enter any notes to yourself here.
```

## Representing numbers

Numbers are represented in *unary* notation. We start from 0 and represent larger numbers by “adding one” many times using the function symbol S, standing for “successor”. So 1 is represented as S(0) (“successsor of zero” or “1 + 0”), 2 is represented as S(S(0)), 3 as S(S(S(0))), and so on.

In order to make sure that the function symbols 0 and S act properly, we need two axioms:

1. *zero-ne-succ*: “all x. ¬(0 = S(x))”

   This axiom states that 0 is never equal to the successor of something. We need this to make sure that our numbers do not “loop round” back to zero at some point.

2. *succ-injective*: “all x. all y. S(x) = S(y) → x = y”

   This axiom states that if two successors are equal, then their predecessors are equal. This axiom is a bit more difficult to understand than the previous one. One way to understand it is that it says that there is only one way to “get to” a number in one step. So it is another way of saying that our sequence of numbers has no cycles.

### Exercise

With these axioms, we can prove that numbers that are written differently are unequal:

```focused-nd {id=arith-proof-repr1}
(config
 (assumptions-name "0 and S axioms")
 (assumptions
  (zero-ne-succ "all x. ¬(0 = S(x))")
  (succ-injective "all x. all y. S(x) = S(y) -> x = y"))
 (goal "¬(S(0) = S(S(0)))"))
```

## Axioms of Addition

Peano's axioms assume a function symbol “add(x,y)” intended to represent “x + y”. The behaviour of addition is specified by two axioms, which are hopefully almost self-explanatory:

1. *add-zero*: “all x. add(0,x) = x”

   Adding zero to “x” is equal to “x”. In normal symbols, “0 + x = x”.

2. *add-succ*: “all x. all y. add(S(x),y) = S(add(x,y))”

   Adding the successor of “x” to “y” is equal to the successor of adding “x” to “y”. In normal symbols, “(1 + x) + y = 1 + (x + y)”.

   One way to visualise this axioms is as “pushing” the “S” symbol outside the addition. Most proofs proceed by using the equality in the axiom left-to-right, pushing the “add” symbol down into the term, usually in the hope that the *add-zero* axiom will apply and the addition will disappear altogether.

### Exercise

With these axioms, we can prove simple facts like 2 + 2 = 4:
```focused-nd {id=arith-proof-add1}
(config
 (assumptions-name "Addition axioms")
 (assumptions
  (add-zero "all x. add(0,x) = x")
  (add-succ "all x. all y. add(S(x),y) = S(add(x,y))"))
 (goal "add(S(S(0)),S(S(0))) = S(S(S(S(0))))"))
```

## Axioms of Multiplication

Multiplication is specified in a similar way to addition, by saying what it does on 0 and S in its first argument. Multiplication is represented as repeated addition.

1. *mul-zero*: “all x. mul(0,x) = 0”

   Multiplying 0 by anything is always 0.

2. *mul-succ*: “all x. all y. mul(S(x),y) = add(y,mul(x,y))”

   In normal symbols, this axiom says: “(1 + x) * y = y + (x * y)”. As with the *add-succ* axiom above, we can think of it as pushing the “mul” operation through a layer of successor. Repeated use of this axiom should usually lead to the “mul” operation disappearing when the *mul-zero* axiom is used.

### Exercises

With these axioms for multiplication (and the ones for addition), we can prove facts about arithmetic on specific numbers. For example, 2*2=4:

```focused-nd {id=arith-proof-mul1}
(config
 (assumptions-name "Addition and Multiplication axioms")
 (assumptions
  (add-zero "all x. add(0,x) = x")
  (add-succ "all x. all y. add(S(x),y) = S(add(x,y))")
  (mul-zero "all x. mul(0,x) = 0")
  (mul-succ "all x. all y. mul(S(x),y) = add(y,mul(x,y))"))
 (goal "mul(S(S(0)),S(S(0))) = S(S(S(S(0))))"))
```

## Induction

The final axiom of Peano's is really an axiom *schema*: a family of axioms, one for each formula.

The induction axiom schema states that if we want to prove a property *P(x)* for all numbers *x*, then we can do so by proving *P(0)* (the *base case*) and proving that, for all *n*, *P(n)* implies *P(S(n))* (the *step case*).

In symbols, we have an axiom of induction for every formula *P(-)*:

```formula
P(0) -> (all n. P(n) -> P(S(n))) -> (all x. P(x))
```

In order to make proofs by induction a bit easier (it can be difficult to select exactly the right formula *P* to prove), induction has been built into the proof system we are using. This is explained in the following video:

```youtube
fwhu4C9E_7U
```

```textbox {id=induction-note2}
Enter any notes to yourself here.
```

### Exercises on Induction

Details on how to do the first few of these are in the video above.

````details
Proof commands...

The blue boxes represent parts of the proof that are unfinished.  The comments (in green) tells you what the current goal is. Either the goal is unfocused:

```
{ goal: <some formula> }
```

or there is a formula is focus:

```
{ focus: <formula1>; goal: <formula2> }
```

The commands that you can use differ according to which mode youare in. The commands correspond directly to the proof rules given in the videos.

#### Unfocused mode

These rules can be used when there is no formula in the focus. These rules either act on the conclusion directly to break it down into simpler sub-goals, or switch to focused mode (the `use` command).

- `introduce H` can be used when the goal is an implication ‘P → Q’. The name `H` is used to give a name to the new assumption P. The proof then continues proving Q with this new assumption. A green comment is inserted to say what the new named assumption is.
- `introduce y` can be used when the goal is a *for all* quantification ‘∀x. Q’. The name `y` is used for the assumption of an arbitrary individual that we have to prove ‘Q’ for. The proof then continues proving ‘Q’. A green comment is inserted to say that the rest of this branch of the proof is under the assumption that there is a named entity.
- `split` can be used when the goal is a conjunction “P ∧ Q”. The proof will split into two sub-proofs, one to prove the first half of the conjunction “P”, and one to prove the other half “Q”.
- `true` can be used when the goal to prove is ‘T’ (true). This  will finish this branch of the proof.
- `left` can be used when the goal to prove is a disjunction ‘P ∨ Q’. A new sub goal will be created to prove ‘P’.
- `right` can be used when the goal to prove is a disjunction ‘P ∨ Q’. A new sub goal will be created to prove ‘Q’.
- `not-intro H` can be used when the goal is a negation ‘¬P’. The name `H` is used to give a name to the new assumption P. The proof then continues proving F (i.e. False) with this new assumption. A green comment is inserted to say what the new named assumption is.
- `exists "t"` can be used when the goal is an *exists* quantification ‘∃x. Q’. The term `t` which must be in quotes, is used as the existential witness and is substituted for `x` in Q. The proof then continues proving ‘Q[x:=t]’,
- `refl` can be used when the goal is ‘t = t’ for some term ‘t’. Note that the terms on each side of the equality must be exactly the same. If this command is applicable, then this branch of the proof is complete.
- **NEW** `induction x` can be used when the variable ‘x’ is in scope. This will start a proof by induction on ‘x’. The proof will split into two branches, one to prove the case when ‘x = 0’, and one to prove the case when ‘x = S(x1)’. In the latter case, you get to assume the *induction-hypothesis* which states that the property being proved is true for ‘x1’.
- `use H` can be used whenever there is no current focus. `H` is the name of some assumption that is available on this branch of the proof. Named assumptions come from the original statement to be proved, and uses of `introduce H`, `cases H1 H2`, `not-intro H`, and `unpack y H`.

#### Focused mode

These rules apply when there is a formula in focus. These rules either act upon the formula in focus, or finish the proof when the focused formula is the same as the goal.

- `done` can be used when the formula in focus is exactly the same  as the goal formula. This will finish this branch of the proof.
- `apply` can be used when the formula in focus is an implication ‘P → Q’. A new subgoal to prove ‘P’ is generated, and the focus becomes ‘Q’ to continue the proof.
- `first` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘P’, the first part of the conjunction, and the proof continues.
- `second` can be used when the formula in focus is a conjunction `P ∧ Q`. The focus then becomes ‘Q’, the second part of the conjunction, and the proof continues.
- `cases H1 H2` can be used then the formula in focus is a disjunction ‘P ∨ Q’. The proof splits into two branches, one for ‘P’ and one for ‘Q’. The two names `H1` and `H2` are used to name the new assumption on the two branches. Green comments are inserted to say what the new named assumptions are.
- `false` can be used when the formula in focus is ‘F’ (false). The proof finishes at this point, no matter what the conclusion is.
- `not-elim` can be used when the formula in focus is a negation  ‘¬P’. A new subgoal is generated to prove ‘P’ in order to generate a contradiction.
- `inst "t"` can be used when the formula in focus is of the form ‘∀x. P’. The term t (which must be in quotes) is substituted in the place of x in the formula after the quantifier and the substituted formula ‘P[x:=t]’ remains in focus.
- `unpack y H` can be used when the formula in focus is of the form ‘∃x. P’. The existential is “unpacked” into the assumption of an entity `y` and its property ‘P[x:=y]’, which is named `H`. Green comments are inserted to say what the assumption ‘`H`’ is.
- `rewrite->` can be used when the formula in focus is an equality ‘t1 = t2’. Every occurrence of ‘t1’ in the goal is rewritten to ‘t2’. (The rewrite goes left to right.)
- `rewrite<-` can be used when the formula in focus is an equality ‘t1 = t2’. Every occurrence of ‘t2’ in the goal is rewritten to ‘t1’. (The rewrite goes right to left.)
````

1. add-x-zero: x + 0 = x

   ```focused-nd {id=arith-proof-ind1}
   (config
    (assumptions-name "Addition axioms")
	(assumptions
	 (add-zero "all x. add(0,x) = x")
	 (add-succ "all x. all y. add(S(x),y) = S(add(x,y))"))
    (goal "all x. add(x,0) = x")
	(solution
	(Rule(Introduce x)((Rule(Induction x)((Rule(Use add-zero)((Rule(Instantiate(Fun 0()))((Rule Close())))))(Rule(Use add-succ)((Rule(Instantiate(Var x1))((Rule(Instantiate(Fun 0()))((Rule(Rewrite ltr)((Rule(Use induction-hypothesis)((Rule(Rewrite ltr)((Rule Refl())))))))))))))))))))
   ```

2. add-x-succ : x + S(y) = S(x + y)

   ```focused-nd {id=arith-proof-ind2}
   (config
    (assumptions-name "Addition axioms")
	(assumptions
	 (add-zero "all x. add(0,x) = x")
	 (add-succ "all x. all y. add(S(x),y) = S(add(x,y))"))
    (goal "all x. all y. add(x,S(y)) = S(add(x,y))"))
   ```

3. Addition is associative:

   ```focused-nd {id=arith-proof-ind3}
   (config
    (assumptions-name "Addition axioms")
	(assumptions
	 (add-zero "all x. add(0,x) = x")
	 (add-succ "all x. all y. add(S(x),y) = S(add(x,y))"))
    (goal "all x. all y. all z. add(x,add(y,z)) = add(add(x,y),z)"))
   ```

4. Addition is commutative:

   ```focused-nd {id=arith-proof-ind4}
   (config
    (assumptions-name "Addition axioms + add-x-zero + add-x-succ")
	(assumptions
	 (add-zero "all x. add(0,x) = x")
	 (add-succ "all x. all y. add(S(x),y) = S(add(x,y))")
	 (add-x-zero "all x. add(x,0) = x")
	 (add-x-succ "all x. all y. add(x,S(y)) = S(add(x,y))"))
    (goal "all x. all y. add(x,y) = add(y,x)"))
   ```

5. Every number is a zero or is a successor of some other number.

   ```focused-nd {id=arith-proof-ind5}
   (config
    (assumptions-name "0 and S axioms")
    (assumptions
     (zero-ne-succ "all x. ¬(0 = S(x))")
     (succ-injective "all x. all y. S(x) = S(y) -> x = y"))
    (goal "all x. x = 0 \/ (ex y. x = S(y))"))
   ```

6. For all numbers *x* and *y*, either they are equal, or they are not. If we assume [excluded middle](soundness-complete-meaning.html), then this fact is immediate from the fact that every proposition is either true or false. If we do not however, we have to construct a proof. The proof proceeds very similarly to how one might construct a computer program to decide whether two numbers are equal: first check if the first number is zero or successor and then check the second; if they are both zero then they are equal, if one is zero and one is a successor then they are not equal, and they are both successors then check the two smaller numbers.

   ```focused-nd {id=arith-proof-ind6}
   (config
    (assumptions-name "0 and S axioms")
    (assumptions
     (zero-ne-succ "all x. ¬(0 = S(x))")
     (succ-injective "all x. all y. S(x) = S(y) -> x = y"))
    (goal "all x. all y. x = y \/ ¬(x = y)"))
   ```


7. We can define “less than or equal” for numbers as *x <= y* is *∃k. add(x,k) = y*. The following proof proves that the numbers are totally ordered: for all pairs of numbers *x* and *y*, either *x <= y* or *y <= x*.

   ```focused-nd {id=arith-proof-ind7}
   (config
    (assumptions-name "Addition axioms")
	(assumptions
	 (add-zero "all x. add(0,x) = x")
	 (add-succ "all x. all y. add(S(x),y) = S(add(x,y))"))
    (goal "all x. all y. (ex k. add(x,k) = y) \/ (ex k. add(y,k) = x)"))
   ```

8. Multiplication distributes over addition.

   The proof of this fact depends on the associativity and commutativity properties of addition that we proved above. There is a tricky bit of rewriting at the end. It is best to work it out on paper first.

   ```focused-nd {id=arith-proof=ind8}
   (config
    (assumptions-name "Addition and Multiplication axioms + add-assoc + add-comm")
	(assumptions
	 (add-zero "all x. add(0,x) = x")
	 (add-succ "all x. all y. add(S(x),y) = S(add(x,y))")
	 (mul-zero "all x. mul(0,x) = 0")
	 (mul-succ "all x. all y. mul(S(x),y) = add(y,mul(x,y))")
	 (add-assoc "all x. all y. all z. add(x,add(y,z)) = add(add(x,y),z)")
	 (add-comm "all x. all y. add(x,y) = add(y,x)"))
	(goal "all x. all y. all z. mul(x,add(y,z)) = add(mul(x,y),mul(x,z))"))
   ```
