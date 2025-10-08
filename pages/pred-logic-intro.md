# Topic 3: Predicate Logic

```aside
This page assumes you have understood the [syntax](prop-logic-syntax.html) and [semantics](prop-logic-semantics.html) of Propositional Logic.
```

Predicate Logic upgrades Propositional Logic by adding the ability to talk about the relationships between things, and whether they are true for all things or for some things.

## Why Predicate Logic?

With Propositional Logic, we can say things like “If it is raining or sunny, and it is not sunny, then it is raining”. In symbols:

```formula
((Rainy | Sunny) & ¬Sunny) -> Rainy
```

But we can't say things like

1. “*Every* day is sunny or rainy, today is not sunny, so today is rainy”
2. “*Some* version of the package is installled”

Propositional logic lacks the ability to make *universal* statements (“Every ...”) or *existential* statements (“Some ...”) about individuals. The best we can do is list the possibilities:

```formula
(S_mon | R_mon) & (S_tue | R_tue) & (S_wed | R_wed) & (S_thu | R_thu) & (S_fri | R_fri)
```

Universal statements are used to say things that are true for a potentially infinite number of individuals. The classical example is:

> All humans are mortal

As we will see later, universal statements are used by instantiating them with specific individuals. In this case, if we assume that “Socrates is human”, then the combination of this and the previous statements allows us to conclude that “Socrates is mortal”.

Existential statements are used to say that something is true for *some* individual. Database queries are often a kind of existential statement. For example:

1. “Do there exist customers that have not paid their invoice?”
2. “Do there exist players within 10 metres of player 1?”
3. ”Do there exist players that are logged in?”
4. “Do we have any customers?”

We have already seen examples of universal and existential statements in the [semantics](truth-tables.html) and [entailment](entailement.html) for Propositional Logic:

1. “`P` is satisfiable if *there exists* a valuation that makes it true”
2. “`P` is valid if *all* valuations make it true”
3. “`P` entails `Q` if *for all* valuations, `P` is true implies `Q` is true”

## Syntax of Predicate Logic

Here are two example formulas in Predicate Logic:

1. “There exists an entity that is a customer and is logged off”:

   ```formula
   ex x. customer(x) /\ loggedOff(x)
   ```

   Or, more concisely, “there is a customer that is logged off”.

2. “For every entity `x`, if `x` is human, then `x` is mortal”:

   ```formula
   all x. human(x) -> mortal(x)
   ```

   More concisely, “all humans are mortal”.

As these examples show, the syntax of Predicate Logic is more complex than that of Propositional Logic. The syntax is separated into **terms**, which describe the entities that we are talking about, and **formulas**, which state properties of relationships between entities.

*Terms* (or *expressions*) are things like variables `x`, specific individuals like `socrates()`, or functions applied to individuals, like `dayAfter(x)`, `x + y`, or `nameOf(cust)`. The structure of terms is very simliar to that of expressions in a language like Java or Python. The words `socrates`, `dayAfter`, `nameOf` are *function symbols*. Each function symbol has a defined *arity*: the number of arguments it has.

In the *formulas* of Predicate Logic, the atomic propositions of Propositional Logic are replaced by *relations* or *predicates* `R` between `n` individuals (as with function symbols, the number `n` depends on the relation `R` being used). For example `customer(x)` and `customerInvoice(x,i)` or `between(x,y,z)`.

A collection of function symbols and relation symbols with specified arities is known as a *vocabulary* as we define below.

As with Propositional Logic, Predicate Logic formulas are composed from atoms using the connectives `∧`, `∨`, `→`, and `¬`. Predicate Logic also has *quantifiers* that allow universal and existential statements, as we saw in the examples above.

## Saying What You Mean

Predicate Logic is an expressive language for stating properties of individuals and their relationships in a precise and unambiguous way, but it can be a bit confusing to start with.

This section explains some common patterns and pitfalls.

### Writing formulas

Write the following English-language statements as Predicate Logic formulas. Invent whatever vocabulary (function and relation symbols) you feel is necessary to write the statement as a formula.

You can practise writing formulas by entering them here. The box underneath the entry box will tell you if there is a problem with your syntax or show you the syntax highlighted version if it is okay:

```formulaentry {id=pred-logic-intro-example}
```

There are exercises below for you to try to express various properties in Predicate Logic.

````details
Syntax for entering formulas

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

### “`x` is a `P`”

Relation symbols with arity 1 are usually used to represent properties of individuals, such as being human, or a swan, or mortal.

If we have a variable `x` standing for some individual, or an expression `e`, then we can say that it has the property `P` by writing `P(x)`. For example:

```formula
human(x)
```
```formula
mortal(x)
```
```formula
swan(x)
```
```formula
golden(x)
```

To say that a specific named individual has a property, then we replace the `x` by the function symbol representing that individual:

```formula
mortal(socrates())
```

### “`x` and `y` are related by `R`”

Relation symbols with arity 2 express relationships between pairs of entities, such as being connected in a network, or knowing each other in a social graph. For example:

```formula
colour(x,gold())
```
```formula
species(x,swan())
```
```formula
connected(x,y)
```
```formula
knows(pooh(), piglet())
```

Properties of individuals are sometimes expressed as having some relationship to a fixed individual. So `colour(x,gold())` could also be expressed as `gold(x)`. Which is more useful depends on how formulas are being used.

### “All `x` are...”

```formula
all x. boring(x)
```
```formula
all x. wet(x)
```

It is usually not very useful to say that everything has some specific property `P` without it being a compound formula because if *everything* has some property, then that property does not carry any useful information.

It is more useful to condition the statement to say that “Everything that is `P` is also `Q`”, for example:

```formula
all x. human(x) → mortal(x)
```
```formula
all x. swan(x) → white(x)
```
```formula
all x. insect(x) -> numLegs(x,6)
```

The part of the formula to the left of the `→` restricts the scope of the for all quantifier to only those individuals with that property. Usually when writing formulas it is common to always have a similar property just after a `all x.` to restrict the scope.

Another common pattern is when we know that the world we are interested in is partitioned in some way. For example, if we are talking about whole numbers, then it might be useful to say:

```formula
all x. even(x) \/ odd(x)
```

#### Exercises

Some of these exercises ask you to mix the new Predicate Logic syntax with the Propositional Logic syntax you have used before.

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

3. “All the leaves are brown, and the sky is grey”.

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

### “Some `x` are ...”

The following formulas all have the shape “there an `x` such that `x` is ...”.

```formula
ex x. human(x)
```
```formula
ex x. swan(x)
```
```formula
ex x. class(x, insecta())
```

These kinds of statements are useful to say that at least one thing with some property exists without making any more statements about that thing.

It is often more useful to say that there is some `P`-thing that has a property `Q`, where `P` is intended to be some kind of category or type, and `Q` is some attribute. For example:

1. There is a mortal human:
   ```formula
   ex x. human(x) /\ mortal(x)
   ```

2. There is a black swan:
   ```formula
   ex x. swan(x) /\ colour(x,black())
   ```

3. There is an insect with 6 legs:
   ```formula
   ex x. insect(x) /\ numLegs(x,6)
   ```

#### “All `P` are `Q`” vs “Some `P` are `Q`”

The examples so far have fitted into the following patterns:
```formula
all x. P(x) -> Q(x)
```
```formula
ex x. P(x) /\ Q(x)
```

It is tempting to write similar formulas with the Propositional connectives switched:

```formula
all x. P(x) /\ Q(x)
```
```formula
ex x. P(x) -> Q(x)
```

These are almost always not what you want. The first says “everything is both `P` and `Q`”. The second says “there an `x` such that *if* `P` is true for `x` then so is `Q`”, which is hardly ever useful.

#### Exercises

1. “There exists a tree that is green”.

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

2. “There exists a tree that is either red or green”

   ```formulaentry {id=saying-ex11}
   <formula>
   ```

   ````details
   Answer...

   The simplest way to write this is:

   ```formula
   ex x. tree(x) /\ (red(x) \/ green(x))
   ```

   **Not**:

   ```formula
   ex x. tree(x) -> (red(x) /\ green(x))
   ```

   because this means that there exists something, such that if it is a tree, then it is red or green. As above, this is satisfied by anything that is not a tree, as well as red or green trees.
   ````

### “No `P` is `Q`”

To say “no swans are blue”:
```formula
all x. swan(x) -> ¬blue(x)
```
or
```formula
¬(ex x. swan(x) /\ blue(x))
```
Both formulas mean the same thing. The first version says “if you can show me a swan, then I can show you it is not blue”. The second says “if you can find a blue swan, then I can prove false”.

Similar statements are:
```formula
¬(ex x. bird(x) /\ canFlyInSpace(x))
```
```formula
all x. program(p) -> ¬works(p)
```

#### Exercise

Write a formula that states “no dog is both small and fun”.

```formulaentry {id=saying-ex12}
```

````details
Answer...

Possible ways are:

```formula
all x. dog(x) -> ~(small(x) /\ fun(x))
```
```formula
¬(ex x. dog(x) /\ small(x) /\ fun(x))
```
```formula
all x. dog(x) -> (~small(x) \/ ~fun(x))
```

````

### “For every `P`, there exists a related `Q`”

All of the above examples have only used one quantifier. More interesting statements can be made when we alternate the quantifiers to say things like “for all `P` there is a `Q`”. For example, *every farmer owns a donkey*:
```formula
all f. farmer(f) -> (ex d. donkey(d) /\ owns(f,d))
```
This formula combines the structures from above with “for all of some type”, then “there exists of some type”, followed by some relationship between the two.

Another example is *every day has a next day*:
```formula
all d. day(d) -> (ex d2. day(d2) /\ next(d,d2))
```
or *every list has a sorted version*, where “sorted version” is separated into two parts:
```formula
all x. list(x) -> (ex y. list(y) /\ sorted(y) /\ sameElements(x,y))
```
Sometimes, we do not need the “type” information (`list`, `day`, `farmer`, etc.) because everything we are talking about is the same. For example, if all we can talk about is positions in a map and their properties we could state *every position has a nearby safe position* as:
```formula
all p1. ex p2. nearby(p1,p2) /\ safe(p2)
```

To understand these kinds of formulas with multiple quantifiers, it helps to think of them as a kind of game. If we are trying to prove one of these properties, we can think of the quantifiers as either player or opponent moves, where a *for all* is an opponent move (they are trying to pick a difficult example that makes us lose) and an *exists* is a player move (we can pick anything we like). The nesting of the quantifiers determines the order of moves.

For these “for all, exists” formulas:

1. For every `x` (they choose)
2. There is a `y` (we choose)
3. Such that `x` and `y` are related.

So the `y` we choose can depend on `x`, but we are constrained to have one that is related appropriately to the original `x` which was arbitrarily chosen by the opponent.

#### Exercises

1. “For every ‘x’ there is a ‘y’ that is greater than ‘x’”. (You might want to use a predicate symbol like “greaterthan” for this.)

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

2. “For every tree that is green, there is a tree that is blue”.

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

### “There exists a `P` such that every `Q` is related”

If we switch the order of the quantifiers, then we get formulas that say that there exists one thing that has some relationship to everything. The other reading of *every farmer owns a donkey* is:
```formula
ex d. donkey(d) /\ (all f. farmer(f) -> owns(f,d))
```
which states that there is *one* donkey that is owned by every farmer.

Two more examples are *there is someone that everyone loves* and *there is someone that loves everyone*, which differ in the order of the individuals in the final relationship:

```formula
ex x. all y. loves(y,x)
```
```formula
ex x. all y. loves(x,y)
```

In terms of moves in a game, we have:
1. there exists an `x` (we choose)
2. for all `y` (they choose)
3. it is the case that `x` and `y` are related

Notice that in this alternation, the opponent has much more power because they can choose a `y` that depends on the `x` we chose.

#### Exercise

“There is a bird that has sat in every tree”.

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

### “For all `P`, there is a related `Q`, related to all `R`”

We can keep alternating quantifiers to get longer and longer back and forth games. For example *everyone knows someone who knows everyone*:
```formula
all x. ex y. knows(x,y) /\ (all z. knows(y,z))
```

In moves:
1. For all `x` (they choose),
2. there is a `y` (we choose),
3. for all `z` (they choose),
4. such that `x`, `y`, `z` are related.

Alternative nesting of quantifiers gives a different sequence of move.

This formula states *there is a node, such that for all nodes reachable from there, there is a safe node in one step*, where the safe node can depend on the reached node:
```formula
ex a. all b. reachable(a,b) -> (ex c. safe(c) /\ step(b,c))
```
Changing the quantifier order changes it to there being *one* safe node:
```formula
ex a. ex c. all b. reachable(a,b) -> (safe(c) /\ step(b,c))
```

### “There exists exactly one `X`”

A statement like
```formula
ex x. P(x)
```
only says that there exists at least one `x` such that `P`, but there might be many. Sometimes, we want to say that something exists uniquely. To do so, we will need to use equality as a relation.

To say *there is only one moon*, we can write:
```formula
ex x. moon(x) /\ (all y. moon(y) -> x = y)
```
which says (a) there is a moon, (b) everything (else) that is a moon is equal to it.

A similar, but different statement is:
```formula
all x. all y. moon(x) -> moon(y) -> x = y
```
which says *there is at most one moon*, but makes no commitment that one exists.

#### Exercises

1. “There is exactly one tree that is red”.

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

2. “There is at most one red tree”.

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

3. “There exist at least two different green trees”.

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


## When are two formulas the same?

You may have noticed that we have been inconsistent with our use of variable names in formulas. Does the naming of variables actually matter. Do the formulas
```formula
all x. P(x)
```
and
```formula
all y. P(y)
```
mean different things?

For Predicate Logic, the answer is **no**. For the purposes of proof and meaning, these two formulas express exactly the same thing. So we literally treat them as the same formula. However, in general, these two formulas are not the same:
```formula
P(x)
```
and
```formula
P(y)
```
This is because they refer to different things outside the formula itself. In the two other formulas above, the `x` and the `y` are *bound* within the formula, with the same quantifier at the same position, so they have the same meaning.

If a variable is not bound in a formula then it is *free*. In the formula:
```formula
ex y. R(x,y)
```
The `x` variable is *free*, but the `y` variable is *bound*. We sometimes refer to the quantifiers as *binders* of the variables, because we think of them as binding a variable with its meaning. We will also say that a variable bound by some quantifier appears in that quantifier's *scope*.

For general formulas, we are free to rename *bound* variables like this as much as we like, as long as we do it consistently.

This is analogous to programs, where we can rename variables within a program, as long as we do it consistently everywhere. However, we cannot rename references to things outside the program (such as into the standard library) because, from the program's point of view, these are free variables.

### Exercises

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

## Substitution

If have formulas with free variables, then one basic operation we will want to do is *substitute*, or *plug in* values for those variables. This is analogous to the plugging in of values into formulas in algebra.

Substitution is a fundamental operation in Predicate Logic because it is what allows us to move from *general* statements like:
```formula
all x. human(x) -> mortal(x)
```
to specific statements like:
```formula
human(socrates()) -> mortal(socrates())
```
by removing the quantifier and replacing `x` by `socrates()`.

We will write substitution with the following syntax:

```
       P[x := t]
```
which means “replace all *free* occurrences of `x` in `P` with `t`”, where `x` is a variable, `P` is a formula, and `t` is a term.

Substitution is mostly a simple operation, except for a subtlety involving bound variable names.

Substitution into atomic formulas is straightforward. We replace every `x` with the corresponding `t`. For example:
```
(mortal(x))[x := socrates()]  =  mortal(socrates())
```

In most compound formulas, it is similarly straightforward. If we take this formula:
```formula
all y. weatherIs(d,y) -> weatherIs(dayAfter(d),y)
```
and substitute `tuesday` for `y`, we get:
```formula
all y. weatherIs(tuesday(),y) -> weatherIs(dayAfter(tuesday()),y)
```

However, we can produce nonsense when the thing we are substituting in contains variable names that are already being used as *bound* variables in the formula. If we have the formula:
```formula
ex y. x = y
```
then we can substitute in any term we like for `x`. Let's choose `add(y,1)`. Doing this naively produces:
```formula
ex y. add(y,1) = y
```
which is the statement that there exists a number `y` that is equal to itself plus 1, which is probably not what we wanted to say.

The problem here is that the `y` in `add(y,1)` is *different* to the `y` in `ex y. x = y`. The first `y` refers to something outside the formula, but the second is bound inside the formula.

The solution is to rename the bound `y` before doing the substitution. We replace the original formula with:
```formula
ex z. x = z
```
which has exactly the same meaning as the original formula. We can then substitution `add(y,1)` for `x` without name capture:
```formula
ex z. add(y,1) = z
```

### Exercises

Compute the results of the following substitutions, being careful with renaming to avoid variable capture.

1.
   ```
   (∀x. P(x) -> Q(x,y))[x := f(x)]
   ```

   ```formulaentry {id=subst-ex1}
   Enter your formula here
   ```

   ````details
   Answer...

   ```formula
   all x. P(x) -> Q(x,y)
   ```

   There are no free `x`s in this formula, so the substitution does nothing.
   ````

2. ```
   (∀x. P(x) -> Q(x,y))[y := f(x)]
   ```

   ```formulaentry {id=subst-ex2}
   Enter your formula here
   ```

   ````details
   Answer...

   ```formula
   all z. P(z) -> Q(z,f(x))
   ```

   The term being substituted in contains an `x`, which also appears bound in the formula. So we have to rename the bound `x` (to `z`, for example) and then do the substitution.
   ````


3. ```
   (P(x) -> (∃x. Q(x,y)))[x := g(y)]
   ```

   ```formulaentry {id=subst-ex3}
   Enter your formula here
   ```

   ````details
   Answer...

   ```formula
   P(g(y)) -> (ex x. Q(x,y))
   ```

   The first `x` in the formula is free, but the second one is bound by the existential quantifier.
   ````

4. ```
   (P(x) -> (∃y. Q(x,y)))[x := g(y)]
   ```

   ```formulaentry {id=subst-ex4}
   Enter your formula here
   ```

   ````details
   Answer...

   ```formula
   P(g(y)) -> (ex z. Q(g(y),z))
   ```

   Both `x`s are free in this formula, but we have had to rename the bound `y` to avoid the `y` used in the term being substituted in.
   ````
