# Hoare Logic with Arrays

## Characterising Array Get and Set


```formula
all a. all i. all x. get(set(a,i,x),i) = x
```

```formula
all a. all i. all j. all x. ¬i = j -> get(set(a,i,x),j) = get(a,j)
```

## Copying an Array

The program:
```
I := 0
while (I != LEN) {
  A := set(A,I,get(B,I))
  I := add(A,1)
}
```

Definitions:
1. `eqArray(i,a,b) := all j. between(j,0,i) -> get(a,j) = get(b,j)`

Lemmas:
1. `all i. all a. all b. eqArray(i,a,b) -> eqArray(add(i,1),set(a,i,get(b,i)),b)`

```focused-nd {id=hoare-arrays-eqarray-property}
(config
 (assumptions
  (get-set "all a. all i. all x. get(set(a,i,x),i) = x")
  (get-get "all a. all i. all j. all x. ¬i = j -> get(set(a,i,x),j) = get(a,j)")
  (between-empty "all i. ¬between(i, 0, 0)")
  (between-elim "all x. all i. between(x, 0, add(i,1)) -> ((between(x,0,i) /\ !x = i) \/ x = i)"))
 (goal "all i. all a. all b. (all j. between(j,0,i) -> get(a,j) = get(b,j)) ->
                             (all j. between(j,0,add(i,1)) ->
							         get(set(a,i,get(b,i)),j) = get(b,j))"))
```

```hoare {id=hoare-arrays-copy}
(hoare
 (program_vars A B I LEN)
 (logic_vars originalB)
 (assumptions
  (eqArray-zero "all a. all b. eqArray(0,a,b)")
  (eqArray-step "all i. all a. all b. eqArray(i,a,b) -> eqArray(add(i,1),set(a,i,get(b,i)),b)"))
 (precond "B = originalB")
 (postcond "eqArray(LEN,A,B) /\ B = originalB"))
```

## Updating an Array

```
pre : A = a
I := 0
while (I != LEN) {
  A := set(A,I,f(get(I)))
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

The invariant states that, for
```formula
done(I,originalA,A) \/ todo(I,originalA,A)
```

The postcondition will be `done(LEN,originalA,A)` indicating that all of `originalA` up to `LEN` has been updated and stored in `A`.

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
When proving that the asserted formula holds, you will have to unpack the `H` that is given to you, and then instantiate the `done-step` and `todo-step` assumptions with `I`, `originalA`, and `oldA`. It is important that it is `oldA` not the newly updated `A`. Once you have done this, `auto` will be able to complete the proof for you.
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
