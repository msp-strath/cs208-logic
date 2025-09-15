# CS208 Coursework 1

## Logical Modelling

This is the first coursework for semester one of CS208 *Logic and
Algorithms* 2024/25.

It is worth 7.5% towards your final mark for all of CS208 (both semesters). The rest will be a second Logic coursework (worth 7.5%), Algorithms coursework in semester two (worth 15% in total), and a final exam in April/May 2025 worth 70%.

This coursework is comprised of several questions for you to do with the logical modelling tool introduced in the lectures and course notes. The questions will make use of the concepts of logical modelling described in part 1 of the course. The whole coursework is marked out of 20.

This page will remember the answers you type in, even if you leave the page and come back. Your browser's [local storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API/Using_the_Web_Storage_API) is used to store the data. If you delete saved data in your browser, or visit this page in private browsing mode and then close the window, you will lose your answers.

Once you have completed the questions, please click on the “Download” button to download your answers as a file called `cs208-2024-coursework1.answers`. When you are ready to submit your answers, please upload the file to [the MyPlace submission page](https://classes.myplace.strath.ac.uk/mod/assign/view.php?id=1774227).

The deadline is **FIXME**. All extension requests should be submitted via [MyPlace](https://classes.myplace.strath.ac.uk/mod/assign/view.php?id=1774227).

```download
cs208-2024-coursework1.answers
```

### Question 0 (no marks)

Please enter your name and registration number:

- Name:
  ```entrybox {id=cw1-2024-name}
  <name>
  ```

- Registration number:
  ```entrybox {id=cw1-2024-regnum}
  <registration-number>
  ```

### Question 1 (4 marks)

This question is on encoding constraints using the [patterns](patterns.html) we have seen.

For each of the questions, please read it carefully and then fill in the part that says `you_fill_this_in` with your answer. You can use any `define`d definitions you like to make your code easier to read.

#### Q1a (1 mark)

Replace `you_fill_this_in` with the necessary constraints to express that *at least one* of `w`, `x`, `y`, or `z` is true.

```lmt {id=cw1-2024-question1a}
atom w
atom x
atom y
atom z

allsat (w | x | y | z)
  { "w": w, "x": x, "y": y, "z": z }
```

#### Q1b (1 mark)

Replace `you_fill_this_in` with the necessary constraints to express that *exactly one* of `w`, `x`, `y`, or `z` is true.

```lmt {id=cw1-2024-question1b}
atom w
atom x
atom y
atom z

allsat (you_fill_this_in)
  { "w": w, "x": x, "y": y, "z": z }
```

#### Q1c (2 marks)

Replace `you_fill_this_in` with the necessary constraints to express that *exactly two* of `x`, `y`, and `z` are true.

```lmt {id=cw1-2024-question1c}
atom x
atom y
atom z

allsat (you_fill_this_in)
  { "x": x, "y": y, "z": z }
```

*Hint:* think about the problem in terms of individual constraints: (1) some of the atoms must be true; (2) for each of the atoms, if it is true, then so must one of the others; and (3) at least one atom is false.

### Question 2: Register Allocation (5 marks)

Compilers have to translate from high level code that uses any amount of variables to low-level machine code that only has as many registers as the CPU has. This is a kind of [resource allocation](resource-alloc.html) problem. One way to solve this problem is to use logical modelling.

```details
The Truth...

Real compilers don't, in general, use logical modelling in the way explained here, at least not directly. Register allocation is only part of the problem that compilers have to solve, which also includes instruction selection and scheduling that interact with register allocation. In practice, real compilers use a collection of greedy algorithms and heuristics to make sure they do not take too long to compile code. They also have to deal with the case when there are too few registers for the variables used in the program, in which case they have to “spill” to memory. However, logical modelling is a nice way of thinking about the problem conceptually before committing to a particular solution strategy.
```

As an example, we will look at the following program (though the solution you will write should work for any program by changing the constraints). The program uses six variables, and is written in [Static Single Assignment (SSA)](FIXME) form. This means that every variable is only written to once, which makes things easier (most modern compilers use SSA internally).

```
1. X = 5
2. Y = 6
3. Z = X + Y
4. W = X + Z
5. U = W + Z
6. V = U + X
7. return V
```

Let's say we are compiling to a machine with only three registers `R1`, `R2`, `R3`. To systematically work out how to assign registers to variables, we need to work out the "live ranges" of each variable: the range of instructions for which a variable is required to have a place to call its own. If two variables have overlapping live ranges then they must be stored in separate registers. If not they can "share" a register.

For this program, the live ranges for each variable are as follows, where the starting instruction is when it gets assigned and the finish instruction is the last time it is used.

```
X : 1 to 6
Y : 2 to 3
Z : 3 to 5
W : 4 to 5
U : 5 to 6
V : 6 to 7
```

If two variables have ranges `(s1,e1)` and `(s2,e2)`, then they can only share a register if either `e1 <= s2` or `e2 <= s1` (it is ok for the start of one to be the same as the end of another if we assume that the add instruction can write to the same register as one of its arguments).

Complete the solver program below to solve the register allocation in this case. You should write the constraints so that they generate all possible solutions, not just one of them. Use the examples on the [resource allocation](resource-alloc.html) page as a guide.

```lmt {id=cw1-2024-question2}
domain variable { X, Y, Z, W, U, V }

domain register { R1, R2, R3 }

atom allocated(v : variable, r : register)

// Every variable goes in a register
define all_variables_allocated {
  forall (v : variable) some (r : register) allocated(v, r)
}

define all_variables_at_most_one_register {
  forall (v : variable)
    forall (r1 : register)
      forall (r2 : register)
        (r1 = r2 | ~allocated(v,r1) | ~allocated(v,r2))
}

define overlapping_live_ranges(v1 : variable, v2 : variable) {
   forall (r : register)
     ~allocated(v1, r) | ~allocated(v2, r)
}

define constraints {
  overlapping_live_ranges(X, Y) &
  overlapping_live_ranges(X, W) &
  overlapping_live_ranges(X, U) &
  overlapping_live_ranges(X, Z) &
  overlapping_live_ranges(Z, W)
}

ifsat (all_variables_allocated &
       all_variables_at_most_one_register &
       constraints)
  { for (v : variable)
      v : [ for (r : register) if (allocated(v, r)) r ] }
```

### Question 3: Robot World (5 marks)

#### The setup

The world consists of three places: the store, the factory, and the loading bay. We will represent this with a domain definition:

```
domain location { Store, Factory, LoadingBay }
```

In the world, there are two objects that may be in places or be carried by the robot: some putty and a widget:

```
domain object { Putty, Widget }
```

The possible states of the world are described by the following parameterised atoms, which can be either true or false:

```
atom robotIn(l : location)
atom objectIn(l : location, o : object)
atom robotHolding(o : object)
```

The first, `robotIn(l)` is true when the robot is in location `l`, and false otherwise. The second, `objectIn(l,o)` is true when the object `o` is in location `l` and false otherwise. The third, `robotHolding(o)` is true when the robot is holding the object `o` and false otherwise.

#### Writing our own Physical Laws

Not all possible valuations of the atoms listed above describing possible worlds make sense. We want to impose some physical laws on our worlds stating things like the robot can only be in one place. The laws we want to state are:

1. The robot is in some place.
2. The robot is in at most one place.
3. Every object is either being held by the robot or is in some location.
4. Every object is in at most one location.
5. Every object is never being held and in a location.

#### Physics as Logic

Fill in the definitions below to express these constraints. When 'Run' is clicked, all the worlds that are generated are ones that are physically possible given our laws of physics above.

**Hint:** there are many worlds that satisfy all the constraints (48 in total (why?)). To debug your solutions you can add other constraints to whittle down the number of potential solutions. For example, add `robotIn(Store)` to restrict to the robot being in the `Store` (and nowhere else, if you have implemented Law 2 correctly).

```lmt {id=cw1-2024-question3}
domain location { Store, Factory, LoadingBay }

domain object { Putty, Widget }

atom robotIn(l : location)
atom objectIn(l : location, o : object)
atom robotHolding(o : object)

define robot_is_somewhere {
  some (l : location) robotIn(l)
}

define robot_never_in_multiple_places {
  forall (l1 : location)
    forall (l2 : location)
      l1 = l2 | ~robotIn(l1) | ~robotIn(l2)
}

define every_object_is_somewhere {
  forall (o : object)
    robotHolding(o) | (some (l : location) objectIn(l, o))
}

define objects_never_in_multiple_places {
  forall (o : object)
    forall (l1 : location)
      forall (l2 : location)
        l1 = l2 | ~objectIn(l1, o) | ~objectIn(l2, o)
}

define objects_never_held_and_not_held {
  forall (o : object)
    forall (l : location)
      ~robotHolding(o) | ~objectIn(l, o)
}

allsat (robot_is_somewhere &
        robot_never_in_multiple_places &
        every_object_is_somewhere &
        objects_never_in_multiple_places &
        objects_never_held_and_not_held)
  { "robotIn":
       [ for (l : location) if (robotIn(l)) l ],
    "objectIn":
       { for (obj : object)
           obj : [ for (l : location)
             if(objectIn(l, obj)) l ] },
    "robotHolding":
       [ for (o : object)
       if (robotHolding(o)) o ]
  }
```

### Question 4: Finding Paths (6 marks)

We now look at a simplified version of the Robot World, where we only worry about where the robot is, and where it can move to. We will look at how to use logical modelling for simplified route finding and planning problems.

#### The setup

We have more locations:

```
domain location {
  Store, Factory, LoadingBay, Road,
  Yard, WasteHeap
}
```

And now we add time to our problems. In the end, we have to make logical formulas that only have a finite number of constraints, so we fix the number of timesteps available up front:

```
domain timestep { T1, T2, T3, T4, T5, Tend }
```

We can now express the movement of the robot throughout time using an atom parameterised by the timestep and the location:

```
atom robotIn(t : timestep, l : location)
```

#### The map

In order to describe the ways that the robot can move, we need to get the possible links between locations into the solver. We will use a special feature that makes a definition from a table of values that make it true:

```
define linked(l1 : location, l2 : location)
  table {
    (Store, Factory)
    (Factory, Store)
    (Factory, LoadingBay)
    (Store, Yard)
    (Yard, Factory)
    (Yard, Store)
    (LoadingBay, Factory)
    (LoadingBay, Road)
  }
```

````details
More explanation

To see how this works, you can print out the value of `linked(x,y)` for specific locations `x` and `y` like so:

```lmt
domain location { Store, Factory, LoadingBay, Road, Yard }

define linked(l1 : location, l2 : location)
  table {
    (Store, Factory)
    (Factory, Store)
    (Factory, LoadingBay)
    (Store, Yard)
    (Yard, Factory)
    (Yard, Store)
    (LoadingBay, Factory)
    (LoadingBay, Road)
  }

print (linked(Store, Factory))    // will print 'true'
print (linked(Store, LoadingBay)) // will print 'false'
```

````

#### Time is a sequence

For our purposes, time is a sequence `T1`, `T2`, ..., `Tend`. We could write out the passage of time as a table as we did for `linked`, but there is a special feature of the solver tool that does this for us automatically. If we write `next(tNow, Next)` then this is true exactly when `tNow` and `tNext` are in sequence.

````details
Example

```lmt
domain timestep { T1, T2, T3, T4, T5, Tend }

print (next(T1, T2))   // will print 'true'
print (next(T3, T5))   // will print 'false'
```
````

#### Route planning

Your task is to write a solver program that computes timelines of robot positions that satisfy the following constraints:

1. The robot is always somewhere.
2. The robot is never in two places.
3. For each pair of timesteps in sequence (i.e. for which `next(t1,t2)` is true), the two locations the robot is in are linked by the map (i.e. the `linked` definition).
4. The robot is in the `Store` at timestep `T1`.
5. The robot is in the `Road` at timestep `Tend`.

There are seven routes from the `Store` to the `Road`.

Finally, there is an additional task: to compute only those routes that do not visit the same place more than once.

```lmt {id=cw1-2024-question4}
domain location { Store, Factory, LoadingBay, Road, Yard, WasteHeap }

// This defines the map
define linked(l1 : location, l2 : location)
  table {
    (Store, Factory)
    (Store, Yard)
    (Factory, Store)
    (Factory, LoadingBay)
    (Yard, Factory)
    (Yard, Store)
    (Yard, WasteHeap)
    (WasteHeap, Road)
    (WasteHeap, Yard)
    (LoadingBay, WasteHeap)
    (LoadingBay, Factory)
    (LoadingBay, Road)
  }

// The possible timesteps
domain timestep { T1, T2, T3, T4, T5, Tend }

// The atoms describing where the robot is
atom robotIn(t : timestep, l : location)

// Constraint 1 : the robot is always somewhere
define always_somewhere {
  forall (t : timestep) some (l : location) robotIn(t, l)
}

// Constraint 2 : the robot is never in more than one palce
define never_in_more_than_one_place {
  forall (t : timestep)
    forall (l1 : location)
      forall (l2 : location)
        l1 = l2 | ~robotIn(t, l1) | ~robotIn(t, l2)
}

// Constraint 3 : sequential timesteps' locations are
// linked in the map
define good_steps {
  forall (t1 : timestep)
    forall (t2 : timestep)
      forall (src : location)
        forall (tgt : location)
           ~next(t1, t2)
         | ~robotIn(t1, src)
         | ~robotIn(t2, tgt)
         | linked(src,tgt)
}

// Constraint 4 : the robot is initially in the Store
define initialState {
  robotIn(T1, Store)
}

// Constraint 5 : the robot is on the Road at 'Tend'
define targetState {
  robotIn(Tend, Road)
}

// Constraint 6 : the robot never visits the same place twice
define never_visit_same_place_twice {
  forall (t1 : timestep)
    forall (t2 : timestep)
      forall (l : location)
        t1 = t2 | ~robotIn(t1, l) | ~robotIn(t2, l)
}

print("All routes from Store to Road:")
allsat (always_somewhere &
        never_in_more_than_one_place &
        good_steps &
        initialState &
        targetState)
  [ for (t : timestep)
       [for (loc : location) if (robotIn(t, loc)) loc ] ]

print("Routes with no repeats:")
allsat (always_somewhere &
        never_in_more_than_one_place &
        good_steps &
        initialState &
        targetState &
	never_visit_same_place_twice)
  [ for (t : timestep)
       [for (loc : location) if (robotIn(t, loc)) loc ] ]
```

---

**Remember to download your answers and submit them to MyPlace**.
