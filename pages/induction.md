# Arithmetic and Induction

**DRAFT**

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

   One way to visualise this axioms is as “pushing” the “S” symbol outside the addition. Most proofs proceed by using the equality in the axiom left-to-right, pushing the “add” symbol down into the term, usually in the hope that the “add-zero” axiom will apply and the addition will disappear altogether.

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

   FIXME: explain

2. *mul-succ*: “all x. all y. mul(S(x),y) = add(y,mul(x,y))”

   FIXME: explain

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

FIXME: we need induction to prove anything for all numbers.

One of these axioms is the principle of induction, which states that to prove a property `P(x)` for all numbers `x`, we have to prove `P(0)` (the base case), and to prove `P(n+1)` assuming `P(n)` (the step case).

### Proofs by Induction in the Proof Tool

```youtube
fwhu4C9E_7U
```

```textbox {id=induction-note2}
Enter any notes to yourself here.
```

### Exercises on Induction

FIXME: proof rules with induction

1. add-x-zero: x + 0 = x

   ```focused-nd {id=arith-proof-ind1}
   (config
    (assumptions-name "Addition axioms")
	(assumptions
	 (add-zero "all x. add(0,x) = x")
	 (add-succ "all x. all y. add(S(x),y) = S(add(x,y))"))
    (goal "all x. add(x,0) = x"))
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

3. add-assoc : x + (y + z) = (x + y) + z

   ```focused-nd {id=arith-proof-ind3}
   (config
    (assumptions-name "Addition axioms")
	(assumptions
	 (add-zero "all x. add(0,x) = x")
	 (add-succ "all x. all y. add(S(x),y) = S(add(x,y))"))
    (goal "all x. all y. all z. add(x,add(y,z)) = add(add(x,y),z)"))
   ```

4. add-comm : x + y = y + x

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

5. zero-or-successor : all x. x = 0 \/ ex y. x = S(y)

   FIXME: the robinson arithmetic axiom is derivable from induction

   ```focused-nd {id=arith-proof-ind5}
   (config
    (assumptions-name "0 and S axioms")
    (assumptions
     (zero-ne-succ "all x. ¬(0 = S(x))")
     (succ-injective "all x. all y. S(x) = S(y) -> x = y"))
    (goal "all x. x = 0 \/ (ex y. x = S(y))"))
   ```

6. all x. all y. (x = y) \/ ¬(x = y)

   FIXME: equality is "deciable", just from the zero and successor axioms

   ```focused-nd {id=arith-proof-ind6}
   (config
    (assumptions-name "0 and S axioms")
    (assumptions
     (zero-ne-succ "all x. ¬(0 = S(x))")
     (succ-injective "all x. all y. S(x) = S(y) -> x = y"))
    (goal "all x. x = 0 \/ (ex y. x = S(y))"))
   ```


7. all x. all y. (ex k. x + k = y) \/ (ex k. y + k = x)

   FIXME: either x is less than or equal to y, or y is less than or equal to x

   ```focused-nd {id=arith-proof-ind7}
   (config
    (assumptions-name "Addition axioms")
	(assumptions
	 (add-zero "all x. add(0,x) = x")
	 (add-succ "all x. all y. add(S(x),y) = S(add(x,y))"))
    (goal "all x. all y. (ex k. add(x,k) = y) \/ (ex k. add(y,k) = x)"))
   ```

8. Multiplication distributes over addition:

   ```
   all x. all y. all z. x * (y + z) = (x * y) + (x * z)
   ```

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
