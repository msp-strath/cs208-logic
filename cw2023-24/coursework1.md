# CS208 Coursework 1

[Link to specimen solution](coursework1_solution.html)

## Logical Modelling

This is the first coursework for semester one of CS208 *Logic and
Algorithms* 2023/24.

It is worth 7.5% towards your final mark for all of CS208 (both semesters). The rest will be a second Logic coursework (worth 7.5%), Algorithms coursework in semester two (worth 15% in total), and a final exam in April/May 2024 worth 70%.

This coursework is comprised of several questions for you to do with the logical modelling tool introduced in the lectures and course notes. The questions will make use of the concepts of logical modelling described in part 1 of the course. The whole coursework is marked out of 20.

This page will remember the answers you type in, even if you leave the page and come back. Your browser's [local storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API/Using_the_Web_Storage_API) is used to store the data. If you delete saved data in your browser, or visit this page in private browsing mode and then close the window, you will lose your answers.

Once you have completed the questions, please click on the “Download” button to download your answers as a file called `cs208-2023-coursework1.answers`. When you are ready to submit your answers, please upload the file to [the MyPlace submission page](https://classes.myplace.strath.ac.uk/mod/assign/view.php?id=1774227).

The deadline is **17:00 Monday 30th October**. All extension requests should be submitted via [MyPlace](https://classes.myplace.strath.ac.uk/mod/assign/view.php?id=1774227).

```download
cs208-2023-coursework1.answers
```

### Question 0 (no marks)

Please enter your name and registration number:

- Name:
  ```entrybox {id=cw1-name}
  <name>
  ```

- Registration number:
  ```entrybox {id=cw1-regnum}
  <registration-number>
  ```

### Question 1 (5 marks)

This question is on encoding constraints using the [patterns](patterns.html) we have seen.

For each of the questions, please read it carefully and then fill in the part that says `you_fill_this_in` with your answer. You can use any `define`d definitions you like to make your code easier to read.

#### Q1a (1 mark)

Replace `you_fill_this_in` with the necessary constraints to express that *at least one* of `a`, `b`, `c`, or `d` is true.

```lmt {id=cw1-question1a}
atom a
atom b
atom c
atom d

allsat (you_fill_this_in)
  { "a": a, "b": b, "c": c, "d": d }
```

#### Q1b (1 mark)

Replace `you_fill_this_in` with the necessary constraints to express that *exactly one* of `a`, `b`, `c`, or `d` is true.

```lmt {id=cw1-question1b}
atom a
atom b
atom c
atom d

allsat (you_fill_this_in)
  { "a": a, "b": b, "c": c, "d": d }
```

#### Q1c (3 marks)

Replace `you_fill_this_in` with the necessary constraints to express that *exactly two* of `a`, `b`, and `c` are true.

```lmt {id=cw1-question1c}
atom a
atom b
atom c

allsat (you_fill_this_in)
  { "a": a, "b": b, "c": c }
```

*Hint:* think about the problem in terms of individual constraints: (1) some of the atoms must be true; (2) for each of the atoms, if it is true, then so must one of the others; and (3) at least one atom is false.

### Question 2 (4 marks)

Please read the [Package Installation Problem](packages.html) page and the page on [handling bigger problems with domains and parameters](domains-and-parameters.html) before trying this question.

Below is a simplified alternative to the package installation problem that doesn't pair packages with versions. Instead, the conflicts between packages are listed explicitly.

Fill in the parts marked `fill_this_in` as follows:

1. Complete the definition of `depends` to express that package `p` depends on package `dependency`
2. Complete the definition of `conflict` to express that package `p1` and package `p2` cannot be installed simultaneously.
3. Complete the definition of `depends_or` to express that package `p` depends on package `dependency1` OR `dependency2`.
4. Complete `dependencies_and_conflicts` to express:
   1. `ChatServer` depends on `MailServer` or `MailServer2`
   2. `ChatServer` depends on `Database1` or `Database2`
   3. `MailServer1` and `MailServer2` conflict
   4. `Database1` and `Database2` conflict
   5. `GitServer` depends on `Database2`
5. Complete `requirements` to express that `ChatServer` and `GitServer` must be installed.

```lmt {id=cw1-question2}
domain package {
  ChatServer, MailServer1, MailServer2,
  Database1, Database2, GitServer
}

atom installed(p : package)

define depends(p : package, dependency : package) {
  fill_this_in
}

define conflict(p1 : package, p2 : package) {
  fill_this_in
}

define depends_or(p : package,
                  dependency1 : package,
                  dependency2 : package) {
  fill_this_in
}

define dependencies_and_conflicts {
  fill_this_in
}

define requirements {
  fill_this_in
}

allsat(dependencies_and_conflicts & requirements)
  { for(packageName : package)
      packageName : installed(packageName)
  }
```

There should be two possible solutions.

### Question 3 (3 marks)

This question is about resource allocation using logical modelling, as described on [the page on resource allocation as graph colouring](resource-alloc.html). Instead of nodes and colours, we'll look at tasks and machines. Tasks will be assigned to machines, under some constraints. These constraints are:

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

```lmt {id=cw1-question3}
domain machine { M1, M2, M3 }
domain task { T1, T2, T3, T4, T5 }

// If assign(t,m) is true, then task 't'
// is assigned to machine 'm'.
atom assign(t : task, m : machine)

define all_tasks_some_machine {
  forall(t : task) some(m : machine) assign(t,m)
}

define all_tasks_one_machine {
  forall(t : task)
    forall(m1: machine)
      forall(m2 : machine)
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

allsat(main)
  { for (t : task)
      t:[for (m : machine)
           if (assign(t, m)) m]
  }
```

There should be two solutions.

### Question 4 (8 marks)

This question involves a more complex method to solve the 2-of-3 problem we saw in Q1c. We will encode a circuit that adds up the three binary digits, and then checks that the answer is two. For this simple problem, this is overly complicated. However, for bigger numbers, or for problems where we wish to specify constraints like "at most 25 packages are installed", then encoding arithmetic as binary circuits is often a practical method.

#### Q4a. Encoding XOR (3 marks)

Exclusive-OR (XOR) has the following truth table:

| Input1 | Input2 | XOR(Input1,Input2) |
|--------|--------|--------------------|
| F      | F      | F                  |
| F      | T      | T                  |
| T      | F      | T                  |
| T      | T      | F                  |

Encode the XOR operation as a collection of constraints. The satisfying valuations of your constraints should exactly be the lines of the truth table (in some order, not necessarily the order in this table).

*Hint:* Try writing calculating how to represent the equation `Output = Input1 XOR Input2` as clauses, as we did for the `AND`, `OR`, and `NOT` in the Tseytin transformation. You'll need to have a formula that expresses `XOR` in terms of `&`, `|` and `¬` before you can simplify. You should be able to do it with four clauses in `xor`.

```lmt {id=cw1-question4a}
domain node { Input1, Input2, Output }

atom active(n : node)

define xor(x : node, y : node, z : node) {
  fill_this_in
}

allsat (xor(Output, Input1, Input2))
 { "Input1": active(Input1),
   "Input2": active(Input2),
   "Output": active(Output) }
```

#### Q4b. Encoding a half adder (2 marks)

A half adder circuit adds two binary digits `Input1` and `Input2` to produce a two bit output consisting of a `Sum` digit and a `Carry` digit. It can be constructed from an XOR and an AND:

```pikchr
linerad=0.3
linewid=0.1cm

I1: dot rad 100% color black
"Input1" above at last dot
move down 1cm from I1.s
I2: dot rad 100% color black
"Input2" above at last dot

move from I1.e right 3cm
XOR: oval "XOR" fit
move from I2.e right 3cm
AND: oval "AND" fit

X1: I1.e + (0.5cm,0)
dot at X1
line from I1 to X1
arrow from X1 right 0cm then up until even with XOR.nw then to XOR.nw
arrow from X1 right 0cm then down until even with AND.nw then to AND.nw

X2: I2.e + (1.5cm,0)
dot at X2
line from I2 to X2
arrow from X2 right 0cm then up until even with XOR.sw then to XOR.sw
arrow from X2 right 0cm then down until even with AND.sw then to AND.sw

arrow right 1cm from XOR.e
dot rad 100% color black
"Sum" above at last dot

arrow right 1cm from AND.e
dot rad 100% color black
"Carry" above at last dot
```

As a truth table, a half adder acts as follows, where the first two columns are the input and the second two are the outputs.

| Input1 | Input2 | Sum | Carry |
|--------|--------|-----|-------|
| F      | F      | F   | F     |
| F      | T      | T   | F     |
| T      | F      | T   | F     |
| T      | T      | F   | T     |

Using your `xor` circuit and an `and`, write a definition that encodes a half adder circuit. The output from this problem should be exactly the truth table for the half-adder (again, in some order).

```lmt {id=cw1-question4b}
domain node { I1, I2, S, Cout }

atom active(n : node)

define xor(x : node, y : node, z : node) {
  put_your_xor_definition_here
}

// Use this
define and(x : node, y : node, z : node) {
  (~active(x) | active(y)) &
  (~active(x) | active(z)) &
  ( active(x) | ~active(y) | ~active(z))
}

define half-adder(input1 : node, input2 : node, sum : node, carry : node) {
  fill_this_in
}

allsat (half-adder (I1, I2, S, Cout))
  { for(n : node) n : active(n) }
```

#### Q4c. Encoding 2-of-3 (3 marks)

Using two half adders and an `OR` to create a full adder, create a circuit with three inputs and two outputs where the two outputs are the sum of the three inputs as a two-digit binary number.

By adding additional constraints on the output nodes of the circuit, constrain the problem so that the solutions are all those for which exactly 2 of the 3 inputs are true.

```lmt {id=cw1-question4c}
// You will have to add extra nodes for your circuit
domain node { Input1, Input2, Input3 }

atom active(n : node)

// You'll have to make some definitions here
// You can use the gate definitions from the Circuits, Gates, and Formulas page


define main {
  fill_this_in
}

allsat (main)
  { "Input1": active(Input1),
    "Input2": active(Input2),
    "Input3": active(Input3) }
```
