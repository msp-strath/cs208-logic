# Resource Allocation Problems

Many kinds of problem that we might ask a computer to solver can be seen as a kind of “resource allocation” problem, where we have some number of resources to distribute among some number of tasks according to some constraints. Logical modelling is a good way of expressing these problems in cases where the constraints complicated.

## Graph Colouring

One way of thinking about resource allocation is to think of colouring the nodes of a graph in such a way that no two connected nodes have the same colour. We think of the nodes as "tasks" and the colours as "resources". An edge between two nodes means that those two nodes cannot be assigned the same colour. In terms of resources, this might be because those two tasks must run at the same time and so cannot be assigned the same physical space, for example.

As a running example, lets take the this graph with the nodes labelled `N1` up to `N5`:

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

We will see below that there are 12 ways of assigning three colours to this graph.

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

### Encoding Graph Colouring in Logic

Graph colouring is a good fit for Logical Modelling because we can express possible colourings as atomic propositions and constraints on the colourings as logical formulas.

As with the [package installation problem](domains-and-parameters.html), we will use domains to express the ranges of nodes and colours in this problem:

```
domain colour { Red, Green, Blue }

domain node { N1, N2, N3, N4, N5 }
```

With these, we define a parameterised atom that is true exactly when a node is coloured with the specified colour:

```
atom is_colour(n : node, c : colour)
```

Now we need two constraints to specify what a colouring is. First, to be a proper colouring, we need to make sure that every node has a colour:

```
define all_nodes_some_colour {
  forall(n : node) some(c : colour) is_colour(n, c)
}
```

Literally: "for every node, there is some colour that is colouring that node".

Second, we need to make sure that no node has more than one colour. This is almost identical to the `incompatibilities` constraint we saw for the [package installations with domains and parameters](domains-and-parameters.html):

```
define all_nodes_at_most_one_colour {
  forall (n : node)
    forall (c1 : colour)
      forall (c2 : colour)
        (c1 = c2 | ~is_colour(n,c1) | ~is_colour(n,c2))
}
```

Now we need a way to say that two nodes may not be assigned the same colour. We can do this with a general parameterised definition that says that for nodes `a` and `b`, then for every colour we never have both nodes that colour:

```
define conflict(a : node, b : node) {
  forall(c : colour) ~is_colour(a, c) | ~is_colour(b, c)
}
```

Then we can state all of the constraints in our graph by using `conflict` repeatedly:

```
define conflicts {
    conflict(N1,N2)
  & conflict(N2,N3)
  & conflict(N4,N5)
  & conflict(N1,N3)
  & conflict(N1,N5)
  & conflict(N5,N3)
}
```

### Putting it all together

Putting together all the parts above, we get the following program. The final `ifsat` gathers together the

```lmt {id=resource-alloc1}
domain node { N1, N2, N3, N4, N5 }
domain colour { Red, Green, Blue }

atom is_colour(n : node, c : colour)

define all_nodes_some_colour {
  forall(n : node) some(c : colour) is_colour(n, c)
}

define all_nodes_at_most_one_colour {
  forall (n : node)
    forall(c1 : colour)
      forall(c2 : colour)
        (c1 = c2 | ~is_colour(n,c1) | ~is_colour(n,c2))
}

define conflict(a : node, b : node) {
  forall(c : colour) ~is_colour(a, c) | ~is_colour(b, c)
}

define conflicts {
    conflict(N1,N2)
  & conflict(N2,N3)
  & conflict(N4,N5)
  & conflict(N1,N3)
  & conflict(N1,N5)
  & conflict(N5,N3)
}

ifsat(all_nodes_some_colour &
      all_nodes_at_most_one_colour &
	  conflicts)
  { for (n : node)
      n:[for (c : colour) if (is_colour(n,c)) c ]
  }
```

- If you add `& conflict(N5,N2)` to the `conflicts` definition, then you'll get no solutions as in the graph above.
- If you switch the `ifsat` to `allsat` you'll get all twelve possible solutions. In some cases, this is *too many* solutions, because it does't really matter *which* colour is assigned to each node, just that some colour is. If we generate all solutions, then some will be just rearrangements of other solutions and not really new solutions. One way of reducing the number of redundant solutions by picking a "seed" colour for one of the nodes (e.g., `is_colour(N1,Red)`). This doesn't affect solvability of the problem, but does avoid (for example) getting essentially the same colouring but with `Red` and `Green` swapped. In general, this problem of avoiding repeated solutions that are rearrangments of other solutions is called "symmetry breaking" and is important when making solvers efficient.

## An exercise: tasks and machines

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

```lmt {id=resource-alloc2}
domain machine { M1, M2, M3 }
domain task { T1, T2, T3, T4, T5 }

// If assign(t,m) is true, then task 't'
// is assigned to machine 'm'.
atom assign(t : task, m : machine)

define all_tasks_some_machine {
  forall(t : task) some(m : machine) assign(t,m)
}

define all_tasks_one_machine {
  forall (t : task)
    forall (m1: machine)
      forall (m2 : machine)
        m1 = m2 | ~assign(t,m1) | ~assign(t,m2)
}

define separate_machines(task1 : task, task2 : task) {
  forall(m : machine) ~assign(task1, m) | ~assign(task2, m)
}

define conflicts {
  fill_this_in
}

define special_cases {
  fill_this_in
}

define main {
  all_tasks_some_machine &
  all_tasks_one_machine &
  conflicts &
  special_cases
}

allsat (main)
  { for (t : task)
      t:[for (m : machine)
           if (assign(t, m)) m]
  }
```

There should be two ways to assign tasks to machines satisfying all the constraints listed above.

````details
Solution

```
define conflicts {
  separate_machines(T1,T2) &
  separate_machines(T2,T3) &
  separate_machines(T2,T5) &
  separate_machines(T3,T4) &
  separate_machines(T3,T5)
}

define special_cases {
  ~assign(T1,M3) &
  ~assign(T1,M1) &
  ~assign(T2,M1) &
  ~assign(T3,M3) &
  (forall(m : machine) ~assign(T2,m) | assign(T4,m))
}
```


````
