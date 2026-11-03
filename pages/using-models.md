# Topic 9 : Using Models of Predicate Logic

```aside
This page assumes that you have read the [Introduction to Predicate Logic](pred-logic-intro.html) and about the [Semantics of Predicate Logic](pred-logic-semantics.html). You can also read the [proof rules for predicate logic](pred-logic-rules.html) to get a feel for how the quantifiers in predicate logic work.
```

**DRAFT**

One reason to study the semantics of Predicate Logic is to give us some faith that the proof system we have been using actually means something. Another reason is that it gives us another view of logical formulas that is very useful for many purposes.

Given a collection of formulas `P1`, ..., `Pn`, it can be useful to build a model `M` of them. There are several uses:

1. Building a model of a collection of formulas helps us check to see whether or not the formulas make sense. If we are able to build a model of some axioms that does not match our intuition, then perhaps we have made a mistake in our axioms? Or maybe we have learnt an unexpected fact about our axioms?

2. Building a model that satisfies a collection of axioms but also falsifies another formula is a way of showing that there is no way of proving that formula from the axioms. We will look at this to show that [certain formulas are unprovable](using-models.md#using-models:proof-counter).

3. If we specify some axioms and *part of* a model, we can get the computer to complete the rest of the model for us such that the axioms are validated. This gives a way of solving problems not by explicitly programming a way of solving them, but instead by stating what it is we want solved and getting the computer to do it for us. We will look at several examples below, including [package installations](using-models.md#using-models:packages) and [resource allocation](using-models.md#using-models:resource-alloc).

## Models and Databases, Formulas and Queries {id=using-models:databases}

The *Relational Model* for databases was introduced by Edgar F. Codd in the 1969 paper [*A relational model of data for large shared data banks*](https://dl.acm.org/doi/10.1145/362384.362685). The core idea of the Relational Model is that databases are comprised of *relations* between values. A database that stores banking information could relate account holders to their names and addresses, and also relate account holders to their accounts, and each account to its transactions. The key innovation of the relational model is that these relations are unbiased, unlike the “navigational” or “hierarchical” models that predated it (or the attempts at “object oriented” databases that came after), which allow referencing of transtions *from* accounts, but not (easily) the reverse. This lack of bias makes the relational model very flexible in the face of changing requirements because it is easy to write queries that were not anticipated when the data was first collected.

The connection to Predicate Logic arises from the fact that there is a tight correspondence between logical concepts and parts of the relational model:

| Logical Concept | Database Concept |
|-----------------|------------------|
| Vocabulary      | Schema           |
| Predicate       | Table            |
| Formula         | Query            |
| Model           | Database         |

**Example**. The Structured Query Language (SQL) is the most common language for writing queries on relational databases. A simple SQL query is:
```
SELECT City.X
FROM City, Within
WHERE City.X = Within.X AND Within.Y = "scotland"
```
This query will return all the cities in Scotland in the database. This query is equivalent to asking *“what values of `x` make the following formula true in a model?”*
```formula
ex y. city(x) /\ within(y,z) /\ x = y /\ z = scotland()
```
or, more simply:
```formula
within(x,scotland()) /\ city(x)
```

**FIXME**: put in some more examples

## Building Models {id=using-models:generating}

Generating small models from collections of formulas is a useful skill for checking that such formulas make sense together, so let's step through an example using the `Places` vocabulary with the following three formulas:

1. ```formula
   ex x. ex y. city(x) /\ city(y) /\ ¬x = y
   ```
2. ```formula
   all x. city(x) -> (ex y. country(y) /\ within(x,y))
   ```
3. ```formula
   all x. ¬(city(x) /\ country(x))
   ```

To construct a model for these formulas, we work through them in turn:

1. We first try the empty model:
   ```
   model M0 for Places {
     universe = { }
	 city = { }
	 country = { }
	 within = { }
   }
   ```
   But this does not satisfy the first formula, although it does satisfy the second and third.
2. The first formula states that at least two cities exist, so we have to add them to the model:

   ```
   model M1 for Places {
     universe = { plockton, auchtermuchty }
	 city = { plockton, auchtermuchty }
	 country = { }
	 within = { }
   }
   ```
3. The model `M1` satisfies the first formula, but not the second, which states that every city is within a country. We can make this formula satisfied by resuing an element of our universe as a country:
   ```
   model M2 for Places {
     universe = { plockton, auchtermuchty }
	 city = { plockton, auchtermuchty }
	 country = { plockton }
	 within = { (auchtermuchty, plockton), (plockton, plockton) }
   }
   ```
4. The model `M2` satisfies the first two formulas, but not the third. The formula states that nothing is both a city and a country, but the model has `plockton` as both. We fix this by introducing a third entity into the universe that is a country, and alter the `within` relation to keep the second formula true:
   ```
   model M3 for Places {
     universe = { plockton, auchtermuchty, scotland }
	 city = { plockton, auchtermuchty }
	 country = { scotland }
	 within = { (auchtermuchty, plockton), (plockton, plockton),
	            (auchtermuchty, scotland), (plockton, scotland) }
   }
   ```
   This model makes all of the formulas true.
5. Finally, we can reduce the size of the model by removing the extra tuples in `within` that are not needed:
   ```
   model M4 for Places {
     universe = { plockton, auchtermuchty, scotland }
	 city = { plockton, auchtermuchty }
	 country = { scotland }
	 within = { (auchtermuchty, scotland), (plockton, scotland) }
   }
   ```

You can test each of these models by typing them into the box below. Edit the `model M { ... }` part to change what exists and what is true. Clicking **Run** will tell you which of the formulas is verified by the model.

```model-checker {id=using-models-generating-places}
theory Places {
  predicate city/1
  predicate country/1
  predicate within/2
}

model M for Places {
  universe = { }
  city = { }
  country = { }
  within = { }
}

check M |= "ex x. ex y. city(x) /\ city(y) /\ ¬x = y"

check M |= "all x. city(x) -> (ex y. country(y) /\ within(x,y))"

check M |= "all x. ¬(city(x) /\ country(x))"
```

The three formulas listed above have finite models, but not all collections of formulas have finite models. An example is given in the box below, using the `Ordering` vocabulary. The first formula says that at least one thing exists. The second says that the `lessthan` relation “stacks”: if `x < y` and `y < z` then `x < z`. The third says that nothing is less than itself. The fourth says that everything has something greater than it.

The effect of these formulas on the model is:
1. The model cannot be empty.
2. Chains of `lessthan` can be combined
3. ... and circles are not allowed
4. ... and chains go on forever.

*Combined*, these formulas prevent any model from being empty or finite.

```model-checker {id=using-models-generating-order}
theory Ordering {
  lessthan/2
}

model M for Ordering {
  universe = { }
  lessthan = { }
}

// Something exists
check M |= "ex x. T"

// Transitivity
check M |= "all x. all y. all z. lessthan(x,y) -> lessthan(y,z) -> lessthan(x,z)"

// Irreflexive: nothing is less than itself
check M |= "all x. ¬lessthan(x,x)"

// No maximum: everything has something greater than it
check M |= "all x. ex y. lessthan(x,y)"
```

**Exercise**. Convince yourself that there are no finite models that make all of these formulas true simultaneously. For each three of four of the formulas, write a model that satisfies those formulas.

```details
Solution...

FIXME
```

## (Un)Proof and Counterexamples {id=using-models:proof-counter}

Proof is a way to show that a formula is true in all models. Conversely, we can use models to show that certain formulas are not provable. To do this, it is not enough to simply fail to prove the formula, because it may be the case that a proof exists and we just did not work hard enough to find it.

We can use the soundness of the proof system to show that a certain judgement `P1, ..., Pn ⊢ Q` is **not** provable as follows:

1. Find a model `Mᶜ` that makes all of the `P1`, ..., `Pn` true (meaning `Mᶜ ⊧ Pi`, for all `i`), but does *not* make `Q` true (so `Mᶜ ⊭ Q`).
2. *If* we could prove `P1, ..., Pn ⊧ Q` then, by soundness, for every model `M` if `M ⊧ P1`, ..., and `M ⊧ Pn` then `M ⊧ Q`.
3. We have a model `Mᶜ` that supports `P1`, ..., `Pn`, so if the judgement is provable, we would have `Mᶜ ⊧ Q`.
4. It is contradictory to have both `Mᶜ ⊧ Q` and `Mᶜ ⊭ Q`, so it must be the case that `P1, ..., Pn ⊧ Q` is not provable.

**Example**. It is not possible to prove the formula
```formula
¬ (ex x. country(x))
```
from the assumptions
1. ```formula
   ex x. ex y. city(x) ∧ city(y) ∧ ¬x = y
   ```
2. ```formula
   all x. city(x) -> (ex y. country(y) ∧ within(x,y))
   ```
3.
   ```formula
   all x. ¬(city(x) ∧ country(x))
   ```

This is because the model we [constructed above](using-models.md#using-models:generating) supports the three listed formulas, but not `¬ (∃ x. country(x))` (because there exists a `country` in the model). Therefore, the argument we just made shows that it is not possible to prove this formula.

**Exercise**: FIXME

## Package Installations {id=using-models:packages}

**FIXME**

### Version 1 {id=using-models:packages:version-1}

TBD: explain `depends/2`, `conflict/2` and `required/1`.

```model-checker {id=packages-model-v1}
theory Packages {
  predicate depends/2
  predicate conflict/2

  predicate required/1

  predicate installed/1

  axiom required_installed :
    "all p. required(p) -> installed(p)"

  axiom dependency_installed :
    "all p. all q. installed(p) -> depends(p,q) -> installed(q)"

  axiom no_conflicts :
    "all p. all q. installed(p) -> installed(q) -> ¬conflict(p,q)"
}

model Example1 for Packages {
  universe = { a, b, c }
  depends = { (a,b), (b, c) }
  conflict = { }
  required = { a }
  installed = ?
}
```

### Version 2 {id=using-models:packages:version-2}

The package installation scenarios we described above are not very realistic because for each package, all of the things it depended on needed to be installed. There was no way of saying, for example, that the `ChatServer` can depend on either `MySQL` or `PostgreSQL` databases. Or to say that a package can depend on

```model-checker {id=packages-model-v2}
```

### Exercise: Package Versions {id=using-models:package:exercise}

As an exercise, extend the `Packages` theory from above with the ability to specify versions of packages, where each

### Further Reading {id=using-models:packages:reading}

1. The original source for logical modelling of the Package Installation Problem is the paper "[OPIUM: Optimal Package Install/Uninstall Manager](http://cseweb.ucsd.edu/~lerner/papers/opium.pdf)" by Tucker, Shuffelton, Jhala, and Lerner. The paper also describes some refinements, such as how to minimise solutions in terms of number of packages or size of downloads. Some experimental results are also given.

2. The post [Version SAT](https://research.swtch.com/version-sat) by Russ Cox, a member of the Google Go team, explains how to encode *any* NP problem (see [SAT Solver](sat.md) for what NP means) into a package installation problem. This means that solving a package installation problem may be very hard indeed (for the computer) in the general case.

3. FIXME: package calculus paper

## Resource Allocation {id=using-models:resource-alloc}

Many kinds of problem that we might ask a computer to solver can be seen as a kind of “resource allocation” problem, where we have some number of resources to distribute among some number of tasks according to some constraints. Logical modelling is a good way of expressing these problems in cases where the constraints complicated.

### Graph Colouring {id=using-models:resource-alloc:graph-coloring}

One way of thinking about resource allocation is to think of colouring the nodes of a graph in such a way that no two connected nodes have the same colour. We think of the nodes as "tasks" and the colours as "resources". An edge between two nodes means that those two nodes cannot be assigned the same colour. In terms of resources, this might be because those two tasks must run at the same time and so cannot be assigned the same physical space, for example.

As a running example, lets take this graph with the nodes labelled `N1` up to `N5`:

```pikchr
N1: circle "N1" fit
move from N1 right 1.2cm up 0.6cm
N2: circle "N2" fit
move from N1 right 2cm
N3: circle "N3" fit
move from N1 down 1cm
N4: circle "N4" fit
move from N4 right 2cm
N5: circle "N5" fit

line from N1.ne to N2.sw
line from N2.se to N3.nw
line from N1.e to N3.w
line from N1.se to N5.nw
line from N4.e to N5.w
line from N3.s to N5.n
```

If we have three colours `Red`, `Green`, `Blue` to assign to these nodes, then there are many ways to do it. For example:

```pikchr
N1: circle "N1" fit fill green
move from N1 right 1.2cm up 0.6cm
N2: circle "N2" fit fill blue
move from N1 right 2cm
N3: circle "N3" fit fill red
move from N1 down 1cm
N4: circle "N4" fit fill green
move from N4 right 2cm
N5: circle "N5" fit fill blue

line from N1.ne to N2.sw
line from N2.se to N3.nw
line from N1.e to N3.w
line from N1.se to N5.nw
line from N4.e to N5.w
line from N3.s to N5.n
```

(here `N1` is `Green`, `N2` is `Blue`, `N3` is `Red`, `N4` is `Green` and `N5` is `Blue`.)

In fact, there are 12 ways of assigning three colours to this graph.

If we add another edge then it is not possible to colour this graph with three colours:

```pikchr
N1: circle "N1" fit
move from N1 right 1.2cm up 0.6cm
N2: circle "N2" fit
move from N1 right 2cm
N3: circle "N3" fit
move from N1 down 1cm
N4: circle "N4" fit
move from N4 right 2cm
N5: circle "N5" fit

line from N1.ne to N2.sw
line from N2.se to N3.nw
line from N1.e to N3.w
line from N1.se to N5.nw
line from N4.e to N5.w
line from N3.s to N5.n
line from N2.s to N5.nw
```

This is because `N1`, `N2`, `N3`, and `N5` are all connected to each other which means that they all need different colours, but there are four of them and only three colours.

### Encoding Graph Colouring in Logic {id=using-models:resource-alloc:logic}

### Putting it all together {id=using-models:resource-alloc:completed}

Putting together all the parts above, we get the following theory and example partial model. If you click ‘Run’, the computer will fill in the missing definition of `is-colour` in a way that satisifies the given axioms.

```model-checker {id=using-models-resource-alloc}
theory Colouring {
  predicate node/1
  predicate colour/1

  predicate different-colours/2

  predicate is-colour/2

  axiom nodes-are-coloured :
    "all x. all y. is-colour(x,y) -> (node (x) /\ colour(y))"

  axiom all-nodes-some-colour :
    "all n. node(n) -> (ex c. colour(c) /\ is-colour(n,c))"

  axiom all-nodes-at-most-one-colour :
    "all n. all c1. all c2. is-colour(n,c1) -> is-colour(n,c2) -> c1 = c2"

  axiom diff-colours :
    "all n1. all n2. all c1. all c2.
	  is-colour(n1,c1) ->
	  is-colour(n2,c2) ->
	  different-colours(n1,n2) ->
	  c1 != c2"
}

model TestGraph for Colouring {
  universe = { N1, N2, N3, N4, N5, Red, Green, Blue }
  node = { N1, N2, N3, N4, N5 }
  colour = { Red, Green, Blue }

  different-colours = {
    (N1, N2),
    (N2, N3),
    (N4, N5),
    (N1, N3),
    (N1, N5),
    (N5, N3)
  }

  is-colour = ?
}
```

If you add `(N5,N2)` to the `different-colours` definition, then you'll get no solutions as in the graph above, because there is no way to colour that graph with three colours.

### Exercise : Tasks and Machines {id=using-models:resource-alloc:exercise}

Instead of nodes and colours, we'll look at tasks and machines, and some more flexible ways of stating constraints on the allocation than just edges in a graph. Tasks will be assigned to machines, under some constraints. These constraints are:

- The following pairs of tasks cannot be assigned to the same machine (because they need to be completed at the same time):

  1. `T1` and `T2`
  2. `T2` and `T3`
  3. `T2` and `T5`
  4. `T3` and `T4`
  5. `T3` and `T5`

- Every solution must also satisfy these special cases:

  1. `T1` must never be assigned to machine `M1` or machine `M3`.
  2. `T2` must never be assigned to machine `M1`.
  3. `T3` must never be assigned to machine `M3`.
  4. If `T2` is assigned to a machine `m`, then `T4` must also be assigned to machine `m`.

Edit the code below to add constraints to encode these additional properties, so that the computer finds a satisfying valuation. The `all_tasks_some_machine`, `all_tasks_one_machine` and `separate_machines` parts have already been filled in. You will need to fill in all the bits that say `fill_this_in`.

**FIXME**: put the code here
