[Contents](contents.html)

# Predicate Logic: Introduction

Predicate Logic upgrades Propositional Logic by adding the ability to talk about the relationships between things, and whether they are true for all things or for some things.

[Slides for the videos (PDF)](week06-slides.pdf).

## Introduction

In the first video, we look at the syntax of Predicate Logic and how Predicate Logic formulas are constructed.

```youtube
74exPHdSPuA
```

```textbox {id=pred-notes1}
Enter any notes to yourself here.
```

## Formal Syntax and Vocabularies

Predicate Logic formulas are built from predicate symbols and function symbols, collectively known as a vocabulary. In the second video this week, we look at some example vocabularies and the formal syntax of Predicate Logic. The key concept to understand when looking at the syntax is the ideas of free and bound variables, and the fact that we can rename bound variables without changing the meaning of a formula.

```youtube
H0OdDzoCHtI
```

```textbox {id=pred-notes2}
Enter any notes to yourself here.
```

## Saying what you mean

Predicate Logic is a very expressive language for making complex statements. In video 3.3, we go through a collection of sample statements showing how to express various forms of relationship in Predicate Logic, and point out some common pitfalls.

```youtube
2zwqVMWBtJw
```

```textbox {id=pred-notes3}
Enter any notes to yourself here.
```

## Exercises

### Writing formulas

Write the following English-language statements as Predicate Logic formulas. Invent whatever vocabulary (function and relation symbols) you feel is necessary to write the statement as a formula.

````details
How to enter formulas

Predicate symbols are any sequence of letters and numbers, where the first character is a letter, followed by their arguments in parentheses. This is similar to the rules for variable names in Java.

Connectives and Quantifiers are represented by ASCII versions:

- And (“∧”) is represented by “`/\`” (forward slash, backwardslash).
- Or (“∨”) is represented by “`\/`” (backward slash, forward slash).
- Implies (“→”) is represented by “`->`” (dash, greater than).
- Not “¬” is represented by “`¬`” (top left of your keyboard). Alternatively, you can use “`~`” (tilde) or “`!`” (exclamation mark).
- For all “∀x.” is represented by “`all x.`”.
- Exists “∃x.” is represented by “`ex x.`”.
- Use parentheses “`(`” and “`)`” to disambiguate mixtures of connectives.

As an example of the use of ASCII for entering formulas, the formula
```formula
∀d. Sunny(d) ∨ Rainy(d)
```
is entered as `all d. Sunny(d) \/ Rainy(d)`.

Use equality “`x = y`” and disequality “`x != y`” (or “`¬ (x = y)`”) to state when two things are the same or different.

The rules for mixing connectives and parentheses were described Lecture 1.
````

1. “Every tree is green”.

   ```formulaentry {id=saying-ex1}
   ```

   ````details
   Answer...

   The formula I would write is:
   ```formula
   all t. tree(t) -> green(t)
   ```
   or
   ```formula
   all t. tree(t) -> colour(t,green())
   ```
   both of which say "for all `t`, if `t` is a tree, then `t` is green."

   It is also *sort of* correct to write:
   ```formula
   all t. green(t)
   ```
   But *only* if we are assuming that everything in the universe is a tree. Remember that `∀x.` means "for all entities in the universe". It is up to us as modellers to decide what the limits of the universe we are talking about, but when communicating with others we need to be clear about it.

   Note that changing the variable name doesn't affect whether it is a tree or not. The formulas
   ```formula
   all tree. green(tree)
   ```
   and
   ```formula
   all dog. green(dog)
   ```
   both mean exactly the same thing. As far as Predicate Logic is concerned, variables are given meaning by how they are *used*, not by how they are *named*.
   ````

   ```tickbox {id=saying-tick1}
   I'm happy with this one.
   ```

2. “Every tree is bare and dead”.

   ```formulaentry {id=saying-ex2}
   ```

   ````details
   Answer...

   This rather bleak sentence can be expressed as:
   ```formula
   all t. tree(t) -> (bare(t) /\ dead(t))
   ```
   or, in words: "every thing t that is a tree is both bare and dead".

   When writing on paper, it is common mistake to mix up the final part and write the even bleaker sentence:
   ```formula
   all t. (tree(t) -> bare(t)) /\ dead(t)
   ```
   which says for all things “t”, if “t” is a tree then it is bare, and, separately, “t” is dead. As we shall see later in the course, this sentence will imply that everything is dead:
   ```formula
   all t. dead(t)
   ```
   ````

   ```tickbox {id=saying-tick2}
   I'm happy with this one.
   ```

3. “There exists a tree that is green”.

   ```formulaentry {id=saying-ex3}
   ```

   ````details
   Answer...

   I would write:
   ```formula
		 ex t. tree(t) /\ green(t)
   ```
   This says "there exists a `t`, such that `t` is a tree and `t` is
   green".

   As above, if you are assuming that every thing in the universe is a tree, then the following also makes sense:
   ```formula
   ex t. green(t)
   ```

   It is tempting to write the following **wrong** thing:
   ```formula
	 ex t. tree(t) -> green(t)
   ```
   but this says "there exists a `t`, such that **if** `t` is a
   tree, **then** `t` is green". This statement is true of, for
   example, a red ball: there is a red ball, and if it were a tree it
   would be green, but it isn't a tree, so it doesn't matter (for the
   purposes of this formula) what colour it is. Another example: “if your granny had wheels, she'd be a car”.
   ````

   ```tickbox {id=saying-tick3}
   I'm happy with this one.
   ```

4. “All the leaves are brown, and the sky is grey”.

   ```formulaentry {id=saying-ex4}
   ```

   ````details
   Answer...

   One way to write this [lyric](https://www.youtube.com/watch?v=N-aK6JnyFmk) is:
   ```formula
   (all l. leaf(t) -> brown(t)) /\ grey(sky())
   ```
   Note here I have used a 0-argument function sky() to talk about “the” sky, instead of saying “there exists a thing which is the sky, and it is grey”. When we talk about fixed objects (e.g., “socrates()”), we can use 0-argument function symbols.
   ````

   ```tickbox {id=saying-tick4}
   I'm happy with this one.
   ```


5. “For every ‘x’ there is a ‘y’ that is greater than ‘x’”. (You might want to use a predicate symbol like “greaterthan” for this.)

   ```formulaentry {id=saying=ex5}
   ```

   ````details
   Answer...

   ```formula
   all x. ex y. greaterthan(y,x)
   ```
   where we are implicitly assuming that it makes sense to compare things. You could also be explicit about the fact that we are comparing numbers (for instance):
   ```formula
   all x. number(x) -> (ex y. number(y) /\ greaterthan(y,x))
   ```
   ````

   ```tickbox {id=saying-tick5}
   I'm happy with this one.
   ```


6. “For every tree that is green, there is a tree that is blue”.

   ```formulaentry {id=saying-ex6}
   ```

   ````details
   Answer...

   ```formula
   all t. (tree(t) /\ green(t)) -> (ex u. tree(u) /\ blue(u))
   ```
   In words: "for all `t`, if `t` is a tree and `t` is green, then there
   exists a `u` such that `u` is a tree and is blue.". It is also
   possible to replace the `∧` to the left of the `→` with
   another `→`:
   ```formula
   all t. tree(t) -> green(t) -> (ex u. tree(u) /\ blue(u))
   ```

   Optionally, depending on how you want to interpret the English
   statement, you could also state that the blue tree is different to
   the green tree:
   ```formula
   all t. (tree(t) /\ green(t)) -> (ex u. tree(u) /\ blue(u) /\ t != u)
   ```
   ````

   ```tickbox {id=saying-tick6}
   I'm happy with this one.
   ```


7. “There is a bird that has sat in every tree”.

   ```formulaentry {id=saying-ex7}
   ```

   ````details
   Answer...

   ```formula
   ex b. bird(b) /\ (all t. tree(t) -> satIn(b,t))
   ```
   In words: "there exists a bird b, such that for all trees t, b has sat in t".

   The following expresses something different:
   ```formula
   all t. tree(t) -> (ex b. bird (b) /\ satIn(b,t))
   ```
   Which says "Every tree has a bird that sits in it". Note that in this sentence there could be a different bird in every tree. The original sentence asks for *one* bird that has sat in every tree.

   Another faulty formula is:
   ```formula
   all t. ex b. tree(t) /\ bird(b) /\ satIn(b,t)
   ```
   which says "for all t, (a) t is a tree, and (b) there exists a bird b that has sat in t". Taking just the (a) part, this formula implies the formula:
   ```formula
   all t. tree(t)
   ```
   which says that everything is a tree. Indeed, if we assume that there is at least one thing in the universe, we can use the following chain of reasoning:

   1. If there is at least one thing in the univese, call it “Sylvester”
   2. Then using the faulty formula, setting t to be “Sylvester”, we learn that
	  1. There exists something, call it “Tweety”
	  2. “Sylvester” is a tree
	  3. “Tweety” is a bird
	  4. “Tweety” has sat in “Sylvester”

   The first two formulas above avoid the problem of everything being a tree.

   If you wanted to get way more complicated, then you could attempt to encode the precise meaning of “has” in terms of “there exists a point in time before the current time when the bird sat in the tree”. Whether you do this or just use a predicate like “satIn” depends on what you want to model.
   ````

   ```tickbox {id=saying-tick7}
   I'm happy with this one.
   ```

8. “There is exactly one tree that is red”.

   ```formulaentry {id=saying-ex8}
   ```

   ````details
   Answer...

   ```formula
	 ex t. tree(t) /\ red(t) /\ (all u. (tree(u) /\ red(u)) -> t = u)
   ```
   In words “there exists a `t`, which is a tree and is red, and
   every `u` that is a red tree is equal to `t`”. You can read the parts after the the ∃ as a list of requirements: t must be (i) a tree; (ii) red; and (iii) the only one.
   ````

   ```tickbox {id=saying-tick8}
   I'm happy with this one.
   ```

9. “There is at most one red tree”.

   ```formulaentry {id=saying-ex9}
   ```

   ````details
   Answer...

   ```formula
	 all t1. all t2. (tree(t1) /\ red(t1) /\ tree(t2) /\ red(t2)) -> t1 = t2
   ```
   In words "for all t1 and t2, if they are both trees and both red, then they are equal". Note that this formula does not specify that a red tree actually exists, only that if we can find any red trees they are all equal.
   ````

   ```tickbox {id=saying-tick9}
   I'm happy with this one.
   ```

10. “There exist at least two different green trees”.

	```formulaentry {id=saying-ex10}
	<formula>
	```

	````details
	Answer...

	```formula
	  ex t1. ex t2. tree(t1) /\ green(t1) /\ tree(t2) /\ green(t2)/\ t1 != t2
	```
	In words "there exist a t1 and a t2 that are both trees, are both green, and are not equal". Without the extra “t1 != t2”, this formula would still be true when there was only one tree.
	````

	```tickbox {id=saying-tick10}
	I'm happy with this one.
	```


### Same Formulas?

1. Are these two formulas the same up to renaming of their bound variables?
   ```formula
   all x. P(x)
   ```
   and
   ```formula
   all y. P(y)
   ```

   ```selection {id=alphaeq-ex1}
   (config (options (True False)))
   ```

   ```details
   Answer...

   **True**: the bound variable “x” in the first one has been consistently renamed to “y” in the second.
   ```

2. Are these two formulas the same up to renaming of their bound variables?
   ```formula
   all x. P(x)
   ```
   and
   ```formula
   all y. P(x)
   ```

   ```selection {id=alphaeq-ex2}
   (config (options (True False)))
   ```

   ```details
   Answer...

   **False**: in the first one, “x” appears bound, but it is free in the second one.
   ```

3. Are these two formulas the same up to renaming of their bound variables?
   ```formula
   all x. P(x) -> (ex y. Q(x,y))
   ```
   and
   ```formula
   all y. P(y) -> (ex x. Q(y,x))
   ```

   ```selection {id=alphaeq-ex3}
   (config (options (True False)))
   ```

   ```details
   Answer...

   **True**: the bound variable “x” in the first one has been consistently renamed to “y” in the second, and the bound variable “y” has been consistently renamed to “x”.
   ```

4. Are these two formulas the same up to renaming of their bound variables?
   ```formula
   all x. P(x) -> (ex y. Q(x,y))
   ```
   and
   ```formula
   all y. P(y) -> (ex y. Q(x,y))
   ```

   ```selection {id=alphaeq-ex4}
   (config (options (True False)))
   ```

   ```details
   Answer...

   **False**: we can match up “x” in the first with “y” in the second, and “y” in the first with “x” in the second, but this pairing does not make “Q(x,y)” in the first and “Q(x,y)” in the second equal.
   ```

5. Are these two formulas the same up to renaming of their bound variables?
   ```formula
   all x. P(x) -> Q(x)
   ```
   and
   ```formula
   all y. Q(y) -> P(y)
   ```

   ```selection {id=alphaeq-ex5}
   (config (options (True False)))
   ```

   ```details
   Answer...

   **False**: the two formulas have different structure, because the predicate symbols “P” and “Q” are swapped.
   ```

6. Are these two formulas the same up to renaming of their bound variables?
   ```formula
   (all x. P(x)) /\ (all x. Q(x))
   ```
   and
   ```formula
   (all y. P(y)) /\ (all z. Q(z))
   ```

   ```selection {id=alphaeq-ex6}
   (config (options (True False)))
   ```

   ```details
   Answer...

   True: the two bound “x”s in the first formula are independent and can be renamed separately.
   ```

---

[Contents](contents.html)
