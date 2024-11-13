# CS208 Coursework 2

## Proofs in Predicate Logic

This is the second coursework for semester one of CS208 *Logic and
Algorithms* 2024/25.

It is worth 7.5% towards your final mark for all of CS208 (both semesters). The rest was the [first Logic coursework](coursework1.html) (worth 7.5%), Algorithms coursework in semester two (worth 15% in total), and a final exam in April/May 2025 worth 70%.

This coursework is comprised of several proofs for you to complete using the tool introduced in the lectures and videos.

The whole page is marked out of 20.

This page will remember the answers you type in, even if you leave the page and come back. Your browser's [local storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API/Using_the_Web_Storage_API) is used to store the data. If you delete saved data in your browser, or visit this page in private browsing mode and then close the window, you will lose your answers.

Once you have completed the questions, please click on the “Download” button to download your answers as a file called `cs208-2024-coursework2.answers`. When you are ready to submit your answers, please upload the file to [the MyPlace submission page](https://classes.myplace.strath.ac.uk/mod/assign/view.php?id=1774245).

The deadline is **17:00 Wednesday 27th November 2024**. All extension requests should be submitted via [MyPlace](https://classes.myplace.strath.ac.uk/mod/assign/view.php?id=1774245).

```download
cs208-2024-coursework2.answers
```

## Question 0 (no marks)

Please enter your name and registration number:

- Name:
  ```entrybox {id=cw2-name}
  <name>
  ```

- Registration number:
  ```entrybox {id=cw2-regnum}
  <registration-number>
  ```

## Question 1 : Proofs about Edges in Graphs (6 marks)

The following questions all use the rules for [“for all” and “exists”](pred-logic-rules.html), as well as the rules for the propositional connectives.

### Question 1(a) (1 mark)

“If every time there is an edge from *x* to *y* there is an edge from *y* to *x*, and every x has an edge from it to somewhere, then every *x* has an edge leading to it.”

```focused-nd {id=cw2-1a marks=1}
(config
 (name "Question 1(a)")
 (assumptions
  (symmetry "all x. all y. edge(x,y) -> edge(y,x)"))
 (goal "(all x. ex y. edge(x,y)) -> (all x. ex y. edge(y,x))"))
```

### Question 1(b) (1 mark)

“If every time there is an edge from *x* to *y*, there is an edge from *y* to *x*, and there is no edge from a() to b(), then there is no edge from b() to a().”

```focused-nd {id=cw2-1b marks=1}
(config
 (name "Question 1(b)")
 (assumptions
  (symmetry "all x. all y. edge(x,y) -> edge(y,x)"))
 (goal "¬edge(a(),b()) -> ¬edge(b(),a())"))
```

### Question 1(c) (1 mark)

“If every time there is edge from *x* to *y* and an edge from *y* to *z*, there is an edge from *x* to *z*, then if there is an edge from a() to b() and an edge from b() to c(), there is an edge from a() to c().”

```focused-nd {id=cw2-1c marks=1}
(config
 (name "Question 1(c)")
 (assumptions
  (transitivity "all x. all y. all z. edge(x,y) -> edge(y,z) -> edge(x,z)"))
 (goal "edge(a(),b()) -> edge(b(),c()) -> edge(a(),c())"))
```

### Question 1(d) (1 mark)

“If every time there is edge from *x* to *y* and an edge from *y* to *z*, there is an edge from *x* to *z*, and if every time there is an edge from *x* to *y* there is an edge from *y* to *x*, and every *x* has an edge to some *y*, then for all *z*, there is an edge from *z* to *z*.”

```focused-nd {id=cw2-1d marks=1}
(config
 (name "Question 1(d)")
 (assumptions
  (transitivity "all x. all y. all z. edge(x,y) -> edge(y,z) -> edge(x,z)")
  (symmetry "all x. all y. edge(x,y) -> edge(y,x)"))
 (goal "(all x. ex y. edge(x,y)) -> (all z. edge(z,z))"))
```

### Question 1(e) (1 mark)

“If, for all *x* and *y* there is either an edge from *x* to *y* or an edge from *y* to *x*, and there is no edge from a() to b(), then there is an edge from b() to a().”

```focused-nd {id=cw2-1e marks=1}
(config
 (name "Question 1(e)")
 (assumptions
  (either-edge "∀x. ∀y. edge(x, y) ∨ edge(y, x)"))
 (goal "¬edge(a(), b()) → edge(b(), a())"))
```

### Question 1(f) (1 mark)

“If, for all *x* and *y* there is either an edge from *x* to *y* or an edge from *y* to *x*, and for every *x* and *y*, if there is an edge from *x* to *y* there is an edge from *y* to *x*, then for all *x* and *y*, there is an edge from *x* to *y*.”

```focused-nd {id=cw2-1f marks=1}
(config
 (name "Question 1(f)")
 (assumptions
  (either-edge "∀x. ∀y. edge(x, y) ∨ edge(y, x)")
  (symmetry "all x. all y. edge(x,y) -> edge(y,x)"))
 (goal "all x. all y. edge(x,y)"))
```

## Question 2, Children and Dragons (2 marks)

### Question 2(a) (1 mark)

“If every dragon has a child that rides it, and there exists a dragon, then there exists a child.”

```focused-nd {id=cw2-2a marks=1}
(config
 (name "Question 2(a)")
 (assumptions
  (every-dragon-has-a-child "∀i. dragon(i) → (∃c. child(c) ∧ rides(c, i))")
  (exists-a-dragon "∃i. dragon(i)"))
 (goal "∃c. child(c)"))
```

### Question 2(b) (1 mark)

“If every child rides a dragon, and there is a child who doesn't ride a dragon, then the earth is hollow.”

```focused-nd {id=cw2-2b marks=1}
(config
 (name "Question 2(b)")
 (assumptions
  (every-child-rides-a-dragon "∀c. child(c) → (∃i. dragon(i) ∧ rides(c, i))")
  (exists-child-without-dragon "∃c. child(c) ∧ (∀i. dragon(i) → ¬rides(c, i))"))
 (goal "∃p. earth(m) ∧ hollow(m)"))
```

## Question 3, Equality (2 marks)

The following proofs all use the rules for [equality](equality.md).

### Question 3(a) (1 mark)

Equalities can be chained together:

```focused-nd {id=cw2-3a marks=1}
(config
 (name "Question 3(a)")
 (goal "∀x. ∀y. ∀z. x = y → y = z → P(x) → P(z)"))
```

### Question 3(b) (1 mark)

This question asks you to prove that a mirroring function mirrors a specific input, using some axioms that describe how mirroring works on nodes and leaves:

```focused-nd {id=cw2-3b marks=1}
(config
 (name "Question 3(b)")
 (assumptions
  (mirror-leaf "mirror(leaf()) = leaf()")
  (mirror-node "∀x. ∀y. mirror(node(x, y)) = node(mirror(y), mirror(x))"))
 (goal "mirror(node(leaf(), node(leaf(), leaf()))) = node(node(leaf(), leaf()), leaf())"))
```

## Question 4, Monoids (3 marks)

The following proofs all use the rules for [equality](equality.md), and the axioms of a commutative monoid, which is like an abelian group except that there are no inverses (think of positive numbers with addition).

This question and the two following are about a definition of “less than or equal” in terms of addition. We define “*x* <= *y*” to be the formula “*∃ k.  x + k = y*”. So *x* is less than *y* if there is a difference of *k* between them.

### Question 4(a) (1 mark)

The first theorem to prove is that everything is less than or equal to itself for this definition of less than or equal:

```focused-nd {id=cw2-4a marks=1}
(config
 (name "Question 4(a)")
 (assumptions
  (add-zero "∀x. add(x, 0) = x")
  (add-comm "∀x. ∀y. add(x, y) = add(y, x)")
  (add-assoc "∀x. ∀y. ∀z. add(x, add(y, z)) = add(add(x, y), z)"))
 (goal "∀x. ∃k. add(x, k) = x"))
```

### Question 4(b) (1 mark)

Next, zero is less than or equal to everything (so that *0* is the bottom element of the ordering):

```focused-nd {id=cw2-4b marks=1}
(config
 (name "Question 4(b)")
 (assumptions
  (add-zero "∀x. add(x, 0) = x")
  (add-comm "∀x. ∀y. add(x, y) = add(y, x)")
  (add-assoc "∀x. ∀y. ∀z. add(x, add(y, z)) = add(add(x, y), z)"))
 (goal "∀x. ∃k. add(0, k) = x"))
```

### Question 4(c) (1 mark)

And this ordering is transitive, *x <= y* and *y <= z*, then *x <= z*:

```focused-nd {id=cw2-4c marks=1}
(config
 (name "Question 4(c)")
 (assumptions
  (add-zero "∀x. add(x, 0) = x")
  (add-comm "∀x. ∀y. add(x, y) = add(y, x)")
  (add-assoc "∀x. ∀y. ∀z. add(x, add(y, z)) = add(add(x, y), z)"))
 (goal "∀x. ∀y. ∀z. (∃k. add(x, k) = y) → (∃k. add(y, k) = z) → (∃k. add(x, k) = z)"))
```

## Question 5, Induction (7 marks)

The following questions all require proofs by [induction using the Peano axioms for arithmetic](induction.html). In some cases, additional consequences of those axioms that were proved on that page are required. These have been provided as additional assumptions.

### Question 5(a) (1 mark)

“Every number is even or odd”.

```focused-nd {id=cw2-5a marks=1}
(config
 (name "Question 5(a)")
 (assumptions
  (add-zero "∀x. add(0, x) = x")
  (add-succ "∀x. ∀y. add(S(x), y) = S(add(x, y))")
  (add-x-zero "∀x. add(x, 0) = x")
  (add-x-succ "∀x. ∀y. add(x, S(y)) = S(add(x, y))"))
 (goal "∀x. ∃k. x = add(k, k) ∨ x = S(add(k, k))"))
```

### Question 5(b) (1 mark)

“x*0 = 0”.

```focused-nd {id=cw2-5b marks=1}
(config
 (name "Question 5(b)")
 (assumptions
  (add-zero "∀x. add(0, x) = x")
  (add-succ "∀x. ∀y. add(S(x), y) = S(add(x, y))")
  (mul-zero "all x. mul(0,x) = 0")
  (mul-succ "all x. all y. mul(S(x),y) = add(y,mul(x,y))"))
 (goal "∀x. mul(x, 0) = 0"))
```

### Question 5(c) (1 mark)

“x * (1 + y) = x + (x * y)”.

```focused-nd {id=cw2-5c marks=1}
(config
 (name "Question 5(c)")
 (assumptions
  (add-zero "∀x. add(0, x) = x")
  (add-succ "∀x. ∀y. add(S(x), y) = S(add(x, y))")
  (mul-zero "all x. mul(0,x) = 0")
  (mul-succ "all x. all y. mul(S(x),y) = add(y,mul(x,y))")
  (add-assoc "all x. all y. all z. add(x,add(y,z)) = add(add(x,y),z)")
  (add-comm "all x. all y. add(x,y) = add(y,x)"))
 (goal "∀x. ∀y. mul(x, S(y)) = add(x, mul(x, y))"))
```

### Question 5(d) (2 marks)

“if x + y = 0, then x = 0”.

```focused-nd {id=cw2-5d marks=2}
(config
 (name "Question 5(d)")
 (assumptions
  (zero-ne-succ "∀x. ¬0 = S(x)")
  (add-zero "∀x. add(0, x) = x")
  (add-succ "∀x. ∀y. add(S(x), y) = S(add(x, y))"))
 (goal "∀x. ∀y. add(x, y) = 0 → y = 0"))
```

### Question 5(e) (2 marks)

“if x + y = x, then y = 0”.

```focused-nd {id=cw2-5e marks=2}
(config
 (name "Question 5(e)")
 (assumptions
  (succ-injective "∀x. ∀y. S(x) = S(y) → x = y")
  (add-zero "∀x. add(0, x) = x")
  (add-succ "∀x. ∀y. add(S(x), y) = S(add(x, y))"))
 (goal "∀x. ∀y. add(x, y) = x → y = 0"))
```
