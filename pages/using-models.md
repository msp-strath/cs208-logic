# Topic 9 : Using Models of Predicate Logic

```aside
This page assumes that you have read the [Introduction to Predicate Logic](pred-logic-intro.html) and about the [Semantics of Predicate Logic](pred-logic-semantics.html). You can also read the [proof rules for predicate logic](pred-logic-rules.html) to get a feel for how the quantifiers in predicate logic work.
```

**DRAFT**

One reason to study the semantics of Predicate Logic is to give us some faith that the proof system we have been using actually means something. Another reason is that it gives us another view of logical formulas that is very useful for many purposes.

Given a collection of formulas `P1`, ..., `Pn`, it can be useful to build a model `M` of them. There are several uses:

1. Building a model that satisfies a collection of axioms but also falsifies another formula is a way of showing that there is no way of proving that formula from the axioms. We saw this in the previous topic to show that [certain formulas are unprovable](pred-logic-semantics.md#pred-sem:proof-counter).

2. Building a model of a collection of formulas helps us check to see whether or not the formulas make sense. If we are able to build a model of some axioms that does not match our intuition, then perhaps we have made a mistake in our axioms? Or maybe we have learnt an unexpected fact about our axioms?

3. If we specify some axioms and *part of* a model, we can get the computer to complete the rest of the model for us such that the axioms are validated. This gives a way of solving problems not by explicitly programming a way of solving them, but instead by stating what it is we want solved and getting the computer to do it for us. We will look at several examples below, including [package installations](using-models.md#using-models:packages) and [resource allocation](using-models.md#using-models:resource-alloc). This is a kind of [*Logic Programming*](using-models.md#using-models:logic-programming).

## Models and Databases {id=using-models:databases}

The *Relational Model* for databases was introduced by Edgar F. Codd in the 1969 paper [*A relational model of data for large shared data banks*](https://dl.acm.org/doi/10.1145/362384.362685). The core idea of the Relational Model is that databases are comprised of *relations* between values. A database that stores banking information could relate account holders to their names and addresses, and also relate account holders to their accounts, and each account to its transactions. The key innovation of the relational model is that these relations are unbiased, unlike the “navigational” or “hierarchical” models that predated it (or the attempts at “object oriented” databases that came after), which allow querying of transactions connected to an account, but not (easily) the reverse. This lack of bias makes the relational model very flexible in the face of changing requirements because it is easy to write queries that were not anticipated when the data was first collected.

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

## Logic Programming {id=using-models:logic-programming}

Database query languages like SQL are an example of the style of programming called *Logic Programming*. Instead of writing down explicitly *how* to solve a problem, the programmer specifies *what* they want to see and it is the computer's job to find a solution. This idea is sometimes referred to as “declarative” programming. The programmer *declares* what they want, and the computer delivers it.

Concretely, the alternative to a language like SQL is for the programmer to write out explicitly all the steps involved in answering the query, explicitly saying at each stage where the data are coming from, how they are being looked up, where the data are going to, etc. As we saw above, SQL queries are essentially Predicate Logic formulas in disguise and therefore have an [interpretation](pred-logic-semantics.md#pred-sem:interp) independent of any particular implementation. Given an SQL query, the Database Management System (DBMS) is free to answer the query in any way it sees fit and in particular is able to optimise the way the query is answered according to how the data is stored. Therefore, the concerns of “what” and “how” are separated. One major benefit of this separation is that the data layout, indexes, and even schema can be rearranged without affecting the queries written on top. If the queries were written with a specific layout assumed, this would be much harder.

Another form of declarative programming is the use of *Cascading Style Sheets* (CSS) for styling web pages. A CSS author does not specify *how* to apply styles to a page, they just *declare* certain facts that ought to be true about stylying (e.g., “all elements with class `alert` are coloured red”), and the rendering engine makes it so. As with SQL, CSS's declarative approach ensures that stylesheets are robust to changes in the underlying document structure and styling can be changed independently of the document content.

CSS and SQL are special purpose programming languages designed for tasks in a single domain. It is difficult to see how one could code an entire application in them. The [Prolog programming language](https://www.metalevel.at/prolog) is a general purpose programming language based on the idea of proof search in a restricted subset of Predicate Logic. A Prolog program is a collection of logical rules, and program execution works by asking “for which values is this statement provable?”.

The class of Logic Programming we will look at here is sometimes called “solver-based” or “constraint-based” programming. It is another example of a domain-specific language, albeit for a domain chosen by the user. A program is a vocabulary and a collection of axioms (i.e., a theory) and a partial model describing the problem. Execution of a program results either in a completed model of the axioms, or a statement that a solution is not possible. So by setting up the axioms to accurately describe what solutions ought to look like, the language gives us a solver “for free”. There are many different kinds of solver, depending on the exact form that the axioms or constraints can take. Here, we will look at the use of Predicate Logic axioms over *finite* models (i.e., models with finite universes).

The language we will use is a minor extension to the notation we used for [models](pred-logic-semantics.md#pred-sem:models). Instead of completely defining a model, we will leave some of the predicates undefined with a `?` symbol. When the computer checks the model, it tries to find a definition that satisfies all the axioms of the theory. The universe and the predicates that are defined are the “inputs” to the program, and the predicate to be defined is the “output”.

For example, this theory says that there is exactly one thing that is in the `p` predicate. The `ExampleModel` says that there are three things in the universe, but that the `p` predicate's interpretation is not defined. Clicking **Run** will generate a definition of `p` that satisfies `ExampleTheory`.

```model-checker {id=using-models-generation-example}
theory ExampleTheory {
  predicate p/1
  axiom one-p : "ex x. p(x) /\ (all y. p(y) -> x = y)"
}

model ExampleModel for ExampleTheory {
  universe = { a, b, c }
  p = ?
}
```

**Exercise**: Try rerunning the example with an empty universe in `ExampleModel`. Is it able to generate a completed model?

The remainder of this page describes several examples of how to describe problems as logical theories in such a way that models of those theories are solutions to the problems. The range of problems that can be handled in this way is surprisingly diverse.

## Package Installations {id=using-models:packages}

The Package Installation Problem goes as follows:

1. There is a collection of packages that can be installed on a computer system. For example, `firefox`, `chrome`, `libc-v12`, `libc-v13`, `libc-v14`, ... .
2. Some packages *depend* on other packages to work properly, so if one package is installed then all packages it depends on must be installed too. For example, `firefox` depends on `libc-v14`, or `chrome` depends on `libc-v12`.
3. Some packages cannot be installed at the same time: they *conflict*. For example, only one of `libc-v12`, `libc-v13` and `libc-v14` can be installed at once.
4. The user wants some packages installed. For example, `firefox` and `chrome`.

Is it possible to fulfil the user's requirements, while also installing all the required dependencies and avoiding any conflicts?

What makes this problem interesting is that conflicts between packages cause their dependents to be in conflict as well. In this example, because `libc-v12` and `libc-v14` conflict, their respective dependents `firefox` and `chrome` conflict as well. Therefore the user's wish to install both `firefox` and `chrome` cannot be fulfilled. If they relax their requirements to only install `firefox`, then it can be fulfilled as long as they install `libc-v14` as well.

### Version 1 {id=using-models:packages:version-1}

We will describe this problem in logic by making the following modelling decisions:

1. The elements of the universe are the individual packages.
2. We will have three predicates that describe the inputs to the problem:
   - `depends/2`: `depends(p,q)` is true when package `p` depends on package `q`.
   - `conflict/2`: `conflict(p,q)` is true when package `p` and package `q` conflict.
   - `required/1`: `required(p)` is true when package `p` is required by the user.
3. The output is described by a single predicate:
   - `installed/1`: `installed(p)` is true if package `p` should be installed, and false if it shouldn't.

To make sure that `installed/1` describes correct package installations, we need three axioms:

1. If a package is required, it is installed:
   ```formula
   all p. required(p) -> installed(p)
   ```
2. If a package is installed, then all its dependencies are installed:
   ```formula
   all p. all q. installed(p) -> depends(p,q) -> installed(q)
   ```

   ````details
   Note:

   It is *really* tempting to write this the other way round, to express the idea that if `q` is installed, and `p` depends on `q`, then `p` *can be* installed. As a formula:
   ```formula
   all p. all q. installed(q) -> depends(p,q) -> installed(p)
   ```
   But this doesn't work! For a correct installation, we need to make sure that if a package is installed, then its dependencies are installed too, in order for it to work properly. This alternative version says that, for example, if the C library is installed, then everything that depends on it must be installed too, which would be nearly everything!
   ````
3. If two packages are installed, then they do not conflict:
   ```formula
   all p. all q. installed(p) -> installed(q) -> ¬conflict(p,q)
   ```

By setting up the `Packages` theory with these three axioms, and setting up a partial model with definitions of the `depends/2`, `conflict/2`, and `required/1` predicates, we can get the computer to deduce a possible solution to the Package Installation Problem:

```model-checker {id=packages-model-v1}
theory Packages {
  predicate depends/2
  predicate conflict/2

  predicate required/1

  predicate installed/1

  // Everything that is required is installed
  axiom required_installed :
    "all p. required(p) -> installed(p)"

  // If something is installed, then everything it
  // depends on is installed
  axiom dependency_installed :
    "all p. all q. installed(p) -> depends(p,q) -> installed(q)"

  // If two packages are installed, they must not conflict
  axiom no_conflicts :
    "all p. all q. installed(p) -> installed(q) -> ¬conflict(p,q)"
}

// This one will work
model Example1 for Packages {
  universe = { firefox, chrome, libc-v12, libc-v13, libc-v14  }
  depends = { (firefox, libc-v14), (chrome, libc-v12) }
  conflict = { (libc-v12, libc-v14) }
  required = { firefox }
  installed = ?
}

// But this will not
model Example2 for Packages {
  universe = { firefox, chrome, libc-v12, libc-v13, libc-v14  }
  depends = { (firefox, libc-v14), (chrome, libc-v12) }
  conflict = { (libc-v12, libc-v14) }
  required = { firefox, chrome }
  installed = ?
}
```

### Version 2 {id=using-models:packages:version-2}

The package installation scenarios we described above are not very realistic because for each package, there was one fixed set of dependencies. There was no way of saying that `firefox` could depend on `libc-v14` *or* `libc-v12`.

We can fix this by adding another input predicate `depends-or/3`, where `depends-or(p,q1,q2)` means that installing `p` requires either `q1` or `q2` to be installed. As a formula:
```formula
all p. all q1. all q2. installed(p) -> depends-or(p,q1,q2) -> (installed(q1) \/ installed(q2))
```
Adding the predicate `depends-or/3` to the theory with this axiom allows more kinds of package installation problems to be expressed:

```model-checker {id=packages-model-v2}
theory Packages {
  predicate depends/2
  predicate depends-or/3
  predicate conflict/2

  predicate required/1

  predicate installed/1

  // Everything that is required is installed
  axiom required_installed :
    "all p. required(p) -> installed(p)"

  // If something is installed, then everything it
  // depends on is installed
  axiom dependency_installed :
    "all p. all q. installed(p) -> depends(p,q) -> installed(q)"

  // If two packages are installed, they must not conflict
  axiom no_conflicts :
    "all p. all q. installed(p) -> installed(q) -> ¬conflict(p,q)"

  // One of the OR dependencies is installed:
  axiom dependency_or :
    "all p. all q1. all q2.
	  installed(p) ->
	  depends-or(p,q1,q2) ->
	  (installed(q1) \/ installed(q2))"
}

// We can now install both firefox and chrome
model Example2 for Packages {
  universe = { firefox, chrome, libc-v12, libc-v13, libc-v14  }
  depends = { (chrome, libc-v12) }
  depends-or = { (firefox, libc-v14, libc-v12) }
  conflict = { (libc-v12, libc-v14) }
  required = { firefox, chrome }
  installed = ?
}
```

### Exercise {id=using-models-packages-exercise}

Write another model that describes the following instance of the Package Installation Problem:

1. `texteditor` depends on `libGUIv1` or `libGUIv2`
2. `musicplayer` depends on `libGUIv2`
3. `libGUIv1` and `libGUIv2` cannot be installed at the same time
4. `texteditor` and `musicplayer` must be installed.

```model-checker {id=using-models-packages-exercise}
theory Packages {
  predicate depends/2
  predicate depends-or/3
  predicate conflict/2

  predicate required/1

  predicate installed/1

  // Everything that is required is installed
  axiom required_installed :
    "all p. required(p) -> installed(p)"

  // If something is installed, then everything it
  // depends on is installed
  axiom dependency_installed :
    "all p. all q. installed(p) -> depends(p,q) -> installed(q)"

  // If two packages are installed, they must not conflict
  axiom no_conflicts :
    "all p. all q. installed(p) -> installed(q) -> ¬conflict(p,q)"

  // One of the OR dependencies is installed:
  axiom dependency_or :
    "all p. all q1. all q2.
	  installed(p) ->
	  depends-or(p,q1,q2) ->
	  (installed(q1) \/ installed(q2))"
}

model Solution for Packages {
   // Fill this in
}
```

````details
Solution

The universe needs to contain all the packages mentioned, and each of the predicate definitions (except `installed/1`, which the computer will compute for us) is filled in as described.

```
model Solution for Packages {
  universe = { texteditor, libGUIv1, libGUIv2, musicplayer }
  depends = { (musicplayer, libGUIv2) }
  depends-or = { (texteditor, libGUIv1, libGUIv2) }
  conflict = { (libGUIv1, libGUIv2) }
  required = { texteditor, musicplayer }
  installed = ?
}
```
````

### Further Reading {id=using-models:packages:reading}

1. The original source for logical modelling of the Package Installation Problem is the paper "[OPIUM: Optimal Package Install/Uninstall Manager](http://cseweb.ucsd.edu/~lerner/papers/opium.pdf)" by Tucker, Shuffelton, Jhala, and Lerner. The paper also describes some refinements, such as how to minimise solutions in terms of number of packages or size of downloads. Some experimental results are also given.

2. The post [Version SAT](https://research.swtch.com/version-sat) by Russ Cox, a member of the Google Go team, explains how to encode *any* NP problem (see [the page on SAT Solvers](sat.md) for what NP means) into a package installation problem. This means that solving a package installation problem may be very hard indeed (for the computer) in the general case.

3. More recently, the 2026 paper [Package Managers à la Carte: A Formal Model of Dependency Resolution](https://dl.acm.org/doi/10.1145/3828699) describes a general way of translating many different kinds of package management into logic.

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

### Logical Representation {id=using-models:resource-alloc:logic}

**FIXME**: explain how to encode this in logic

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

### Exercise {id=using-models:resource-alloc:exercise}

**FIXME**: Adding requirements and anti-requirements

Instead of nodes and colours, let's look at tasks and machines, and some more flexible ways of stating constraints on the allocation than just edges in a graph. Tasks will be assigned to machines, under some constraints. These constraints are:

- The following pairs of tasks cannot be assigned to the same machine (because they need to be completed at the same time):

  1. `T1` and `T2`
  2. `T2` and `T3`
  3. `T2` and `T5`
  4. `T3` and `T4`
  5. `T3` and `T5`

- Every solution must also satisfy these special cases:

  6. `T1` must never be assigned to machine `M1` or machine `M3`.
  7. `T2` must never be assigned to machine `M1`.
  8. `T3` must never be assigned to machine `M3`.
  9. If `T2` is assigned to a machine `m`, then `T4` must also be assigned to machine `m`.

Edit the code below to add constraints to encode these additional properties, so that the computer finds a satisfying valuation. The `all_tasks_some_machine`, `all_tasks_one_machine` and `separate_machines` parts have already been filled in. You will need to fill in all the bits that say `fill_this_in`.

```model-checker {id=using-models-tasks}
theory TasksAndMachines {


}
```
