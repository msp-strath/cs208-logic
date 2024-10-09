# Circuits, Gates and Formulas

In [Converting to CNF](converting-to-cnf.html), we saw that logical connectives can be translated into clauses by treating them as equations.

Let's now look at how to do this in the Logical Modelling Tool. We'll use a [domain](domains-and-parameters.html) to write down all the variables involved, and a parameterised atom `active(n : var)` which is true if that variable is true, and false otherwise.

## Encoding NOT

We can encode `Out = ¬ In` as clauses like so, using the translation given in [Conversion to CNF](converting-to-cnf.html):

```lmt {id=circuits-not}
domain var { In, Out }

atom active(n : var)

define not(out : var, in : var) {
    (~active(out) | ~active(in))
  & ( active(in) | active(out))
}

allsat(not(Out, In))
  { for(n : var) n : active(n) }
```

Clicking **Run** should give exactly the truth table for NOT.

## Encoding AND

Similarly, we can encode AND as clauses, using the translation given in [Conversion to CNF](converting-to-cnf.html):

```lmt {id=circuits-and}
domain var { In1, In2, Out }

atom active(n : var)

define and(out : var, in1 : var, in2 : var) {
  (~active(out) | active(in1)) &
  (~active(out) | active(in2)) &
  ( active(out) | ~active(in1) | ~active(in2))
}

allsat(and(Out, In1, In2))
  { for(n : var) n : active(n) }
```

Clicking **Run** should give exactly the truth table for AND.

## Encoding OR

And we can encode OR as clauses:

```lmt {id=circuits-or}
domain var { In1, In2, Out }

atom active(n : var)

define or(out : var, in1 : var, in2 : var) {
    (~active(out) | active(in1) | active(in2))
  & ( active(out) | ~active(in1))
  & ( active(out) | ~active(in2))
}

allsat(or(Out, In1, In2))
  { for(n : var) n : active(n) }
```

Clicking **Run** should give exactly the truth table for OR.

## Encoding a Formula

Let's say we want to encode the formula `Out = (¬In1 \/ In2) /\ (¬In2 \/ In1)`, and to find out all the values of `In1` and `In2` that make `Out` true.

To encode the formula as clauses, we break it down into individual components like so:

1. `Out = X1 /\ X2`
2. `X1 = X3 \/ In2`
3. `X3 = ¬In1`
4. `X2 = X4 \/ In1`
5. `X4 = ¬In2`

Now we can encode this formula using variables `In1`, `In2`, `Out`, `X1`, `X2`, `X3`, `X4` and the logic gates defined above. We also assert that `active(Out)` is true to tell the solver that we want to find solutions when `Out` is true. Finally, we print out all solutions, but only to `In1` and `In2`.

```lmt {id=circuits-example}
domain var { In1, In2, Out, X1, X2, X3, X4 }

atom active(n : var)

define not(out : var, in : var) {
    (~active(out) | ~active(in))
  & (active(in) | active(out))
}

define or(out : var, in1 : var, in2 : var) {
    (~active(out) | active(in1) | active(in2))
  & ( active(out) | ~active(in1))
  & ( active(out) | ~active(in2))
}

define and(out : var, in1 : var, in2 : var) {
  (~active(out) | active(in1)) &
  (~active(out) | active(in2)) &
  ( active(out) | ~active(in1) | ~active(in2))
}

define formula {
  and(Out, X1, X2) &
  or(X1, X3, In2) &
  not(X3, In1) &
  or(X2, X4, In1) &
  not(X4, In2)
}

allsat (formula & active(Out))
  { "In1": active(In1), "In2": active(In2) }
```

The results should say that `Out` is true exactly when `In1` is equal to `In2`.

## Extended Exercise: Adder Circuits

As we saw in when looking at [patterns of constraints](patterns.html), it can be difficult to encode constraints like "exactly one of two", compared to "at most one". Constraints like "exactly two of three" or more get even harder, and the number of individual clauses we need can explode.

This exercise looks at a less elementary, but much more scalable approach to encode the 2-of-3 problem which generalises to any "`n`-of-`m`" problem.

The basic idea is simple: we will encode a circuit that adds up the three binary digits, and then checks that the answer is two. For this simple problem, this is overly complicated. However, for bigger numbers, or for problems where we wish to specify constraints like "at most 25 packages are installed", then encoding arithmetic as binary circuits is often a practical method.

### Step 1: Encoding XOR

Exclusive-OR (XOR) has the following truth table:

| Input1 | Input2 | XOR(Input1,Input2) |
|--------|--------|--------------------|
| F      | F      | F                  |
| F      | T      | T                  |
| T      | F      | T                  |
| T      | T      | F                  |

Encode the XOR operation as a collection of constraints. The satisfying valuations of your constraints should exactly be the lines of the truth table (in some order, not necessarily the order in this table).

*Hint:* Try writing calculating how to represent the equation `Output = Input1 XOR Input2` as clauses, as we did for the `AND`, `OR`, and `NOT` in the Tseytin transformation. You'll need to have a formula that expresses `XOR` in terms of `&`, `|` and `¬` before you can simplify. You should be able to do it with four clauses in `xor`.

```lmt {id=circuits-xor}
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

````details
Solution

```
define xor(x : node, y : node, z : node) {
  (~active(x) |  active(y) |  active(z)) &
  (~active(x) | ~active(y) | ~active(z)) &
  ( active(x) |  active(y) | ~active(z)) &
  ( active(x) | ~active(y) |  active(z))
}
```

````

### Step 2: Encoding a Half-adder

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

```lmt {id=circuits-half-adder}
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

define half-adder(input1 : node,
                  input2 : node,
                  sum : node,
                  carry : node) {
  fill_this_in
}

allsat (half-adder (I1, I2, S, Cout))
  { for(n : node) n : active(n) }
```

````details
Solution

```
define half-adder(input1 : node,
                  input2 : node,
                  sum : node,
                  carry : node) {
  xor(sum, input1, input2) &
  and(carry, input1, input2)
}
```
````

### Step 3: Encoding 2-of-3

Using two half adders and an `OR` to create a full adder, create a circuit with three inputs and two outputs where the two outputs are the sum of the three inputs as a two-digit binary number.

By adding additional constraints on the output nodes of the circuit, constrain the problem so that the solutions are all those for which 2 of the 3 inputs are true.

```lmt {id=circuits-2-of-3-ex}
// You will have to add extra nodes for your circuit
domain node { Input1, Input2, Input3 }

atom active(n : node)

// You'll have to define something here, using the
// bits from above.

define main {
  main
}

allsat (main)
  { "Input1": active(Input1),
    "Input2": active(Input2),
    "Input3": active(Input3) }
```

````details
Solution

This is a complete solution. Comments have been added to explain it.

```lmt {id=circuits-2-of-3-solution}
// The nodes X, Y, Z are internal to the circuit.
// Out1 and Out2 are the outputs.
domain node { Input1, Input2, Input3, X, Y, Z, Out0, Out1 }

atom active(n : node)

// This is the XOR from above
define xor(x : node, y : node, z : node) {
  (~active(x) |  active(y) |  active(z)) &
  (~active(x) | ~active(y) | ~active(z)) &
  ( active(x) |  active(y) | ~active(z)) &
  ( active(x) | ~active(y) |  active(z))
}

// We'll also need OR gates and AND gates
define or(x : node, y : node, z : node) {
  (~active(x) | active(y) | active(z)) &
  ( active(x) | ~active(y)) &
  ( active(x) | ~active(z))
}

define and(x : node, y : node, z : node) {
  (~active(x) | active(y)) &
  (~active(x) | active(z)) &
  ( active(x) | ~active(y) | ~active(z))
}

// The half adder
define half-adder(input1 : node,
                  input2 : node,
                  sum : node,
                  carry : node) {
  xor(sum, input1, input2) &
  and(carry, input1, input2)
}

// A full adder built from two half-adders and an OR gate
define full-adder {
  half-adder(Input1, Input2, X, Y) &
  half-adder(X, Input3, Out0, Z)   &
  or(Out1, Y, Z)
}

define main {
  // we have a full-adder circuit
  full-adder &

  // This line says that the output must be "two"
  // in binary (i.e., 10)
  active(Out1) & ~active(Out0)
}

// Finally, we try to work out what the inputs must be if the output is '2'
allsat (main)
  { "Input1": active(Input1),
    "Input2": active(Input2),
    "Input3": active(Input3) }
```
````
