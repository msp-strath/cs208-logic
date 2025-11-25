# Hoare Logic with Arrays

```aside
This page assumes that you have understood the pages on [Hoare Logic](hoare-logic.html) and [Loops in Hoare Logic](hoare-loops.html). Understanding how to use [Assertions and Automaton](hoare-assert-and-auto.html) will be useful.
```

The programs we have looked at so far have only used variables that store individual values like booleans and integers. Any reasonable program will need compound data structures like arrays, queues, stacks, trees, and so on. Arrays are perhaps the most basic of these data structures, and are used in most languages to implement the more specialised ones.

Arrays are also a prototypical example of one of the things that makes rigorous reasoning about programs hard: *aliasing*. This is the name for when a single object can be referred to by multiple names.

## What are Arrays? {id=hoare-arrays:what}

In most programming languages, arrays are an interface to a sequence of values that are indexed by numbers in the range `0` (inclusive) to `LEN` (exclusive), where `LEN` is the length of the array. (Some languages, e.g. Lua, index from `1`.) Arrays support random access, meaning that it is possible to read from any point in the array and to update at any point in the array. It is usually informally assumed that the cost of reading and writing to arrays does not depend on the index `i`. This is not true on almost all modern hardware, due to the way that accesses to main memory are mediated by layers of caches, but it is a useful fiction.

## The Aliasing Problem {id=hoare-arrays:aliasing}

As we will see in the examples below, the main work of verifying programs that manipulate arrays is that we always have to show that updating an array does not break any important fact that we previously knew about the array. We will spend much of our time reasoning about whether or not two indexes are equal.

To illustrate the problem with arrays, and aliasing in general, consider this simple program in a C or Java-like syntax:
```
x = 1;
y = 2;
```
In almost all languages, if `x` and `y` are local variables, it is safe to assume that updates to `x` do not affect `y` and vice versa. So we can conclude after this piece of code executes that `x = 1` and `y = 2`.

```details
Almost all?

Some languages (e.g., C++) allow you to overload the assignment operator `=` to run arbitrary code, so it could indeed be possible that `x` and `y` may interfere with each other. However, doing this is considered bad style in those languages. Of course, that doesn't mean it doesn't happen.
```

Contrast this with similar code that uses arrays instead:
```
a[i] = 1;
a[j] = 2;
```
It might feel reasonable to assume that after this program executes then `a[i] = 1` and `a[j] = 2`. But this is only true if `i` and `j` are not equal! If they are equal, we say that `i` and `j` are aliases for the same element of the array, and updates to one interfere with updates to the other.

The problem of reasoning about updates to mutable data is significantly complicated by the presence of multiple ways of referring to the same underlying object. In arrays, we can have multiple index variables that refer to the same element of the array. If we are not expecting this, then we can accidentally overwrite data. The phenomenon of having multiple ways of referencing the same underlying data is known as *aliasing*, and it can make reasoning about programs very hard.

Aliasing is pervasive in any programming language that allows references to data (e.g., arrays, Java/Python/Javascript object references, C pointers) that is *mutable* (i.e., we can change it). This is such a problem, especially when combined with concurrency where multiple threads can access the same data simultaneously, that modern programming languages are exploring ways to address it. One way, as you will see in CS260 *Functional Thinking* is to prohibit mutability altogether. Another way, which is demonstrated in the language [Rust](https://rust-lang.org) is only allow aliasing or mutability, but never both at the same time.

## Axioms for Arrays {id=hoare-arrays:axioms}

There are only two axioms that describe how arrays work, but they are complicated by the need to explicitly say when two indexes are not equal to handle the aliasing problem.

The usual syntax for reading an array is `a[i]`, where `a` is the array and `i` is the index. Here, we will write this as `get(a,i)`.

The usual syntax for writing to an array is `a[i] = E;`, where `a` is the array, `i` is the index and `E` is the expression whose value is to be written to the array. For our purposes here, we separate the acts of updating an array and updating the name referring to the array. We will use `set(a,i,x)` for the operation that *returns a new array* updating the `i`th element of the array `a` to `x`. To assign the result to an program variable, we write this as:
```
A := set(A,I,E)
```
which simulates the meaning of the more usual `A[I] = E` statement in a language like C or Java.

To be able to reason about arrays, we need to know how `get(a,i)` and `set(a,i,x)` interact. This is described by the following two axioms:

1. The `get-set` axiom states that if we update the `i` element to `x` and then read the `i`th element of the result, then the value is `x`:
   ```formula
   all a. all i. all x. get(set(a,i,x),i) = x
   ```
2. The `get-get` axiom says that if we update the `i`th element of `a` but read the `j`th element, where `i` and `j` are **not equal**, then the result is the same as reading the `j`th element of `a`:
   ```formula
   all a. all i. all j. all x. ¬i = j -> get(set(a,i,x),j) = get(a,j)
   ```

## Updating an Array {id=hoare-arrays:updating}

To understand the subtleties in reasoning about aliasing and update, consider the following program, which sets the `I`th element of `A` to `1` and the `J`th element to `2`. It is the version of the code above, but written in a way that is compatible with the proof tool:
```
A := set(A,I,1)
A := set(A,J,2)
```

As we stated above, we might naively expect that a suitable postcondition for this program is:
```formula
get(A,I) = 1 /\ get(A,J) = 2
```
which is only true if `I` and `J` are not equal.

We can prove that the above program achieves this postcondition, but we need to assume a precondition that states that `¬I = J`.

As you enter the program, you will see that the formula describing the state evolves to indicate that the variable `A` is the result of two updates to the original value of the array. You will need to do multiple unpackings of the formula to access the older states.

```hoare {id=hoare-arrays-update-1}
(hoare
 (assumptions
  (get-set "all a. all i. all x. get(set(a,i,x),i) = x")
  (get-get "all a. all i. all j. all x. ¬i = j -> get(set(a,i,x),j) = get(a,j)"))
  (program_vars A I J)
  (precond "¬I = J")
  (postcond "get(A,I) = 1 /\ get(A,J) = 2")
  (solution (Rule(Program_rule(Assign A(Fun set((Var A)(Var I)(Fun 1())))))((Rule(Program_rule(Assign A(Fun set((Var A)(Var J)(Fun 2())))))((Rule(Program_rule End)((Rule(Proof_rule(Use H))((Rule(Proof_rule(ExElim oldA H))((Rule(Proof_rule(Use H))((Rule(Proof_rule Conj_elim2)((Rule(Proof_rule(ExElim olderA H2))((Rule(Proof_rule Split)((Rule(Proof_rule(Use get-get))((Rule(Proof_rule(Instantiate(Var oldA)))((Rule(Proof_rule(Instantiate(Var J)))((Rule(Proof_rule(Instantiate(Var I)))((Rule(Proof_rule(Instantiate(Fun 2())))((Rule(Proof_rule(Store fact1))((Rule(Proof_rule(Use get-set))((Rule(Proof_rule(Instantiate(Var olderA)))((Rule(Proof_rule(Instantiate(Var I)))((Rule(Proof_rule(Instantiate(Fun 1())))((Rule(Proof_rule(Store fact2))((Rule(Proof_rule Auto)())))))))))))))))))))))))(Rule(Proof_rule(Use get-set))((Rule(Proof_rule(Instantiate(Var oldA)))((Rule(Proof_rule(Instantiate(Var J)))((Rule(Proof_rule(Instantiate(Fun 2())))((Rule(Proof_rule(Store fact))((Rule(Proof_rule Auto)())))))))))))))))))))))))))))))))
```

## Filling an Array {id=hoare-arrays:filling}

Arrays have many values in them, so to use them effectively often requires loops. We will see in the next few examples that the aliasing problem is often avoided, or at least made easier to handle, by the fact that access to arrays is often performed with a very regular access pattern. Usually this is moving through the array sequentially from the start to the end.

This program fills in the elements of an array from `0` (inclusive) to `LEN` (exclusive) with some value `VALUE`:
```
I := 0
while (I != LEN) {
  A := set(A,I,VALUE)
  I := add(I,1)
}
```

To describe the desired postcondition of this program, we define a predicate `equalTo(a,start,end,v)` which uses the `between` predicate we have seen before to say that all the elements of `a` between `start` (inclusive) and `end` (exclusive) are equal to `v`. The predicate `equalTo(a,start,end,v)` is defined to be:
```formula
all i. between(i,start,end) -> get(a,i) = v
```

The postcondition we want to obtain is:
```formula
equalTo(A,0,LEN,VALUE)
```

As in the [previous loop examples](hoare-loops.md), we annotate the program with the loop invariant and an additional assertion that makes the proof easier:
```
I := 0
assert (equalTo(A,0,I,VALUE))
while (I != LEN) {
  A := set(A,VALUE)
  assert (equalTo(A, 0, add(I, 1), VALUE))
  I := add(I,1)
}
```

The reason to introduce the `equalTo` predicate is so that we can state and prove two properties of it that will make our program verification much easier:

1. The first property of `equalTo` is that any array is equal to `v` between `i` and `i`, because the second `i` is exclusive:
   ```formula
   all a. all i. all v. equalTo(a,i,i,v)
   ```
   We will use this property when establishing the loop invariant at the beginning of the loop before it has done any work.

   We can prove this from the axioms of `between`:
   ```focused-nd {id=hoare-arrays-equalTo-start}
   (config
    (assumptions
	 (between-empty "all i. all j. ¬between(i,j,j)")
	 (between-step "all x. all s. all i. between(x, s, add(i,1)) -> ((between(x,s,i) /\ ¬(x = i)) \/ x = i)"))
    (goal "all a. all i. all v. all j. between(j,i,i) -> get(a,j) = v")
	(solution (Rule(Introduce a)((Rule(Introduce i)((Rule(Introduce v)((Rule(Introduce j)((Rule(Use between-empty)((Rule(Instantiate(Var j))((Rule(Instantiate(Var i))((Rule(Store fact)((Rule Auto())))))))))))))))))))
   ```

2. The second property of `equalTo` is that if an array is equal to `v` up to `end`, then updating that array with `v` at `end` is equal to `v` up to `add(end,1)`:
   ```formula
   all a. all start. all end. all v.
	 equalTo(a,start,end,v) ->
	 equalTo(set(a,end,v),start,add(end,1),v)
   ```
   We will use this on each step of the loop to update our knowledge of what work has been performed.

   To prove this, we need to use the axioms for `between` and the `array` axioms. The proof splits into two cases, depending on whether the `i` we are looking up is the one that has been updated, or one that we already knew is set to `v`.
   ```focused-nd {id=hoare-arrays-equalTo-step}
   (config
    (assumptions
	(get-set "all a. all i. all x. get(set(a,i,x),i) = x")
	(get-get "all a. all i. all j. all x. ¬i = j -> get(set(a,i,x),j) = get(a,j)")
	 (between-empty "all i. all j. ¬between(i,j,j)")
	 (between-step "all x. all s. all i. between(x, s, add(i,1)) -> ((between(x,s,i) /\ ¬(x = i)) \/ x = i)"))
    (goal "all a. all start. all end. all v.
	       (all i. between(i,start,end) -> get(a, i) = v) ->
		   (all i. between(i,start,add(end,1)) -> get(set(a,end,v),i) = v)")
    (solution (Rule(Introduce a)((Rule(Introduce start)((Rule(Introduce end)((Rule(Introduce v)((Rule(Introduce H)((Rule(Introduce i)((Rule(Introduce H2)((Rule(Use between-step)((Rule(Instantiate(Var i))((Rule(Instantiate(Var start))((Rule(Instantiate(Var end))((Rule Implies_elim((Rule Auto())(Rule(Cases H3 H3)((Rule(Use get-get)((Rule(Instantiate(Var a))((Rule(Instantiate(Var end))((Rule(Instantiate(Var i))((Rule(Instantiate(Var v))((Rule(Store fact1)((Rule(Use H)((Rule(Instantiate(Var i))((Rule(Store fact2)((Rule Auto())))))))))))))))))))(Rule(Use get-set)((Rule(Instantiate(Var a))((Rule(Instantiate(Var i))((Rule(Instantiate(Var v))((Rule(Store fact)((Rule Auto())))))))))))))))))))))))))))))))))))))))
   ```

Using these two properties of `equalTo` it is possible to prove that the program above fills the array with `VALUE` between `0` and `LEN`:

```hoare {id=hoare-arrays-fill}
(hoare
 (assumptions
  (equalTo-start "all a. all i. all v. equalTo(a,i,i,v)")
  (equalTo-step "all a. all start. all end. all v.
                 equalTo(a,start,end,v) ->
                 equalTo(set(a,end,v),start,add(end,1),v)"))

 (program_vars A I LEN VALUE)
 (precond "T")
 (postcond "equalTo(A,0,LEN,VALUE)")
 (solution (Rule(Program_rule(Assign I(Fun 0())))((Rule(Program_rule(Assert(Atom equalTo((Var A)(Fun 0())(Var I)(Var VALUE)))))((Rule(Proof_rule(Use equalTo-start))((Rule(Proof_rule(Instantiate(Var A)))((Rule(Proof_rule(Instantiate(Var I)))((Rule(Proof_rule(Instantiate(Var VALUE)))((Rule(Proof_rule(Store fact))((Rule(Proof_rule Auto)())))))))))))(Rule(Program_rule(While(Rel(Var I)Ne(Var LEN))))((Rule(Program_rule(Assign A(Fun set((Var A)(Var I)(Var VALUE)))))((Rule(Program_rule(Assert(Atom equalTo((Var A)(Fun 0())(Fun add((Var I)(Fun 1())))(Var VALUE)))))((Rule(Proof_rule(Use H))((Rule(Proof_rule(ExElim oldA H))((Rule(Proof_rule(Use equalTo-step))((Rule(Proof_rule(Instantiate(Var oldA)))((Rule(Proof_rule(Instantiate(Fun 0())))((Rule(Proof_rule(Instantiate(Var I)))((Rule(Proof_rule(Instantiate(Var VALUE)))((Rule(Proof_rule(Store fact))((Rule(Proof_rule Auto)())))))))))))))))))(Rule(Program_rule(Assign I(Fun add((Var I)(Fun 1())))))((Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))))(Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))))))
```

## Modifying Into Another Array {id=hoare-arrays:copy-modify}

The next program copies one array into another, adding `1` to each element. This is similar to filling an array with a fixed value, except that the value we use changes for each index. This program takes each element of `B` between `0` and `LEN`, adds `1` and places the result into the same index in `A`:
```
I := 0
while (I != LEN) {
  A := set(A,I,add(get(B,I),1))
  I := add(I,1)
}
```
Notice that the little programming language we are using here guarantees that `A` and `B` refer to different arrays, so overwriting an element of `A` will not affect `B`. In languages like C, Java, and Python, this is not guaranteed. In Java, the code:
```
for (i = 0; i < a.length; i++)
  a[i] = b[i] + 1;
```
will overwrite the original if `a` and `b` point to the same array.

To state the postcondition for this program, we make another definition to help us. The outcome of this program ought to be that every index of `A` between `0` and `LEN` is equal to adding `1` to the corresponding element of `B`. Generalising over the portion of the array that has been updated, we use a predicate `done(a, start, end, b)`, defined as:
```formula
all i. between(i,start,end) -> get(a,i) = add(get(b,i),1)
```
As before, we will need two properties of this predicate that describe how the predicate evolves as arrays are updated. These are similar to the two properties we proved for `equalTo` above:

1. The first says that all indexes between `i` and `i` (of which there are none) have been updated for any pair of arrays:
   ```formula
   all a. all i. all b. done(a,i,i,b)
   ```

   ```focused-nd {id=hoare-arrays-done-1}
   (config
    (assumptions
	 (between-empty "all i. all j. ¬between(i,j,j)")
	 (between-step "all x. all s. all i. between(x, s, add(i,1)) -> ((between(x,s,i) /\ ¬(x = i)) \/ x = i)"))
    (goal "all a. all i. all b. all j. between(j,i,i) -> get(a,j) = add(get(b,j),1)")
	(solution (Rule(Introduce a)((Rule(Introduce i)((Rule(Introduce b)((Rule(Introduce j)((Rule(Introduce j-between-i-i)((Rule(Use between-empty)((Rule(Instantiate(Var j))((Rule(Instantiate(Var i))((Rule(Store fact)((Rule Auto())))))))))))))))))))))
   ```

2. The second says that if a pair of arrays have been processed up to `end`, then updating the `end`th element makes them processed up to the `end + 1`th element:
   ```formula
   all a. all start. all end. all b.
     done(a,start,end,b) ->
	 done(set(a,end,add(get(b,end),1)),start,add(end,1),b)
   ```
   As for `equalTo`, we will use this on each step of the loop to update our knowledge of what work has been performed.

   To prove this, we need to use the axioms for `between` and the `array` axioms. The proof splits into two cases, depending on whether the `i` we are looking up is the one that has been updated, or one that we already knew is set to `v`.
   ```focused-nd {id=hoare-arrays-equalTo-step}
   (config
    (assumptions
	  (get-set "all a. all i. all x. get(set(a,i,x),i) = x")
	  (get-get "all a. all i. all j. all x. ¬i = j -> get(set(a,i,x),j) = get(a,j)")
	   (between-empty "all i. all j. ¬between(i,j,j)")
	   (between-step "all x. all s. all i. between(x, s, add(i,1)) -> ((between(x,s,i) /\ ¬(x = i)) \/ x = i)"))
    (goal "all a. all start. all end. all b.
	       (all i. between(i,start,end) -> get(a, i) = add(get(b,i),1)) ->
		   (all i. between(i,start,add(end,1)) ->
		   get(set(a,end,add(get(b,end),1)),i) = add(get(b,i),1))")
    (solution (Rule(Introduce a)((Rule(Introduce start)((Rule(Introduce end)((Rule(Introduce b)((Rule(Introduce previous-state)((Rule(Introduce i)((Rule(Introduce i-between-start-end1)((Rule(Use between-step)((Rule(Instantiate(Var i))((Rule(Instantiate(Var start))((Rule(Instantiate(Var end))((Rule Implies_elim((Rule Auto())(Rule(Cases i-is-before-end i-is-end)((Rule(Use get-get)((Rule(Instantiate(Var a))((Rule(Instantiate(Var end))((Rule(Instantiate(Var i))((Rule(Instantiate(Fun add((Fun get((Var b)(Var end)))(Fun 1()))))((Rule(Store fact)((Rule(Use previous-state)((Rule(Instantiate(Var i))((Rule(Store fact2)((Rule Auto())))))))))))))))))))(Rule(Use get-set)((Rule(Instantiate(Var a))((Rule(Instantiate(Var end))((Rule(Instantiate(Fun add((Fun get((Var b)(Var i)))(Fun 1()))))((Rule(Store fact)((Rule Auto())))))))))))))))))))))))))))))))))))))))
   ```

With these properties, it is possible to verify the program above against the postcondition
```formula
done(A,0,LEN,B) /\ B = originalB
```
where we have had to include the extra `B = originalB` to ensure that the program does not overwrite the old array.

We can complete the verification use the this annotated program, where the annotations follow the same overall pattern as the previous example:
```
I := 0
assert (done(A,0,I,B) /\ B = originalB)
while (I != LEN) {
  A := set(A,I,add(get(B,I),1))
  assert (done(A,0,add(I,1),B) /\ B = originalB)
  I := add(I,1)
}
```

Verifying the program is now a matter of entering this annotated program, doing a few `unpack`s to unpack old versions of the array and instantiating the properties of `done` proved above.

```hoare {id=hoare-arrays-copy-update}
(hoare
 (program_vars A B I LEN)
 (logic_vars originalB)
 (assumptions
  (done-start "all a. all i. all b. done(a,i,i,b)")
  (done-step "all a. all start. all end. all b.
     done(a,start,end,b) ->
	 done(set(a,end,add(get(b,end),1)),start,add(end,1),b)"))
 (precond "B = originalB")
 (postcond "done(A,0,LEN,B) /\ B = originalB")
 (solution (Rule(Program_rule(Assign I(Fun 0())))((Rule(Program_rule(Assert(And(Atom done((Var A)(Fun 0())(Var I)(Var B)))(Atom =((Var B)(Var originalB))))))((Rule(Proof_rule(Use done-start))((Rule(Proof_rule(Instantiate(Var A)))((Rule(Proof_rule(Instantiate(Var I)))((Rule(Proof_rule(Instantiate(Var B)))((Rule(Proof_rule(Store fact))((Rule(Proof_rule Auto)())))))))))))(Rule(Program_rule(While(Rel(Var I)Ne(Var LEN))))((Rule(Program_rule(Assign A(Fun set((Var A)(Var I)(Fun add((Fun get((Var B)(Var I)))(Fun 1())))))))((Rule(Program_rule(Assert(And(Atom done((Var A)(Fun 0())(Fun add((Var I)(Fun 1())))(Var B)))(Atom =((Var B)(Var originalB))))))((Rule(Proof_rule(Use H))((Rule(Proof_rule(ExElim oldA H))((Rule(Proof_rule(Use done-step))((Rule(Proof_rule(Instantiate(Var oldA)))((Rule(Proof_rule(Instantiate(Fun 0())))((Rule(Proof_rule(Instantiate(Var I)))((Rule(Proof_rule(Instantiate(Var B)))((Rule(Proof_rule Auto)())))))))))))))))(Rule(Program_rule(Assign I(Fun add((Var I)(Fun 1())))))((Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))))(Rule(Program_rule End)((Rule(Proof_rule Auto)())))))))))))
```

```````comment

## Modifying in Place {id=hoare-arrays:update-all}

**UNDER CONSTRUCTION***

```
pre : A = a
I := 0
while (I != LEN) {
  A := set(A,I,add(get(A,I),1))
  I := add(I,1)
}
post : all i. between(i,0,LEN) -> get(A,i) = f(get(a,i))
```

Definitions:
1. `done(i,oldA,newA) := all j. between(j,0,i) -> get(newA,j) = f(get(oldA,j))`
2. `todo(i,oldA,newA) := all j. between(j,i,LEN) -> get(newA,j) = get(oldA,j)`

Lemmas:
1. `done(0,oldA,newA)`
2. `todo(0,a,a)`
3. `all i. all a. all x. done(i,a,x) -> todo(i,a,x) -> done(add(i,1),a,set(x,i,f(get(x,i))))`
4. `all i. all a. all x. done(i,a,x) -> todo(i,a,x) -> todo(add(i,1),a,set(x,i,f(get(x,i))))`

The invariant states that
```formula
done(I,originalA,A) /\ todo(I,originalA,A)
```

The postcondition will be `done(LEN,originalA,A)` indicating that all of `originalA` up to `LEN` has been done and stored in `A`.

Using the lemmas proved above, it is now possible to prove that the program updating an array in place meets its specification. Complete this proof for the program written above. You will have to add `assert`s appropriately.

````details
HINT

The loop invariant for this specification is `done(I,originalA,A) /\ todo(I,originalA,A)`, so you will have to assert this before the loop. The proof of this assertion will require you to instantiate the `done-init` and `todo-init` assumptions appropriately and then use `auto`.

In the proof of the loop body, it is useful to have an `assert` in the middle.
```
A := set(A,I,f(get(A,I)))
assert (done(add(I, 1), originalA, A) ∧ todo(add(I, 1), originalA, A))
I := add(I,1)
```
When proving that the asserted formula holds, you will have to unpack the `H` that is given to you, and then instantiate the `done-step` and `todo-step` assumptions with `I`, `originalA`, and `oldA`. It is important that it is `oldA` not the newly done `A`. Once you have done this, `auto` will be able to complete the proof for you.
````

```hoare {id=hoare-arrays-1}
(hoare
 (program_vars A I LEN)
 (logic_vars originalA)
 (assumptions
  (done-init "all a1. all a2. done(0,a1,a2)")
  (todo-init "all a. todo(0,a,a)")
  (done-step "all i. all a. all x. done(i,a,x) -> todo(i,a,x) -> done(add(i,1), a, set(x, i, f(get(x, i))))")
  (todo-step "all i. all a. all x. done(i,a,x) -> todo(i,a,x) -> todo(add(i,1), a, set(x, i, f(get(x, i))))")
  )
 (precond "A = originalA")
 (postcond "done(LEN,originalA,A)"))
```

````````
