# Hoare Logic with Arrays

## Characterising Array Lookup and Update


```formula
all i. lookup(update(A,i,x),i) = x
```

```formula
all i. all j. ¬i = j -> lookup(update(A,i,x),j) = lookup(A,j)
```

## Copying an Array

Definitions:
1. `eqArray(i,a,b) := all j. between(j,0,i) -> lookup(a,j) = lookup(b,j)`

Lemmas:
1. `all i. all a. all b. eqArray(i,a,b) -> eqArray(add(i,1),update(a,i,lookup(b,i)),b)`

```hoare {id=hoare-arrays-copy}
(hoare
 (program_vars A B I LEN)
 (logic_vars originalB)
 (assumptions
  (eqArray-zero "all a. all b. eqArray(0,a,b)")
  (eqArray-step "all i. all a. all b. eqArray(i,a,b) -> eqArray(add(i,1),update(a,i,lookup(b,i)),b)"))
 (precond "B = originalB")
 (postcond "eqArray(LEN,A,B) /\ B = originalB"))
```

## Updating an Array

```
pre : A = a
I := 0
while (I != LEN) {
  A := update(A,I,f(lookup(I)))
  I := add(I,1)
}
post : all i. between(i,0,LEN) -> lookup(A,i) = f(lookup(a,i))
```

Invariant:
```formula
(all i. between(i,0,I) -> lookup(A,i) = f(lookup(a,i))) /\ (all i. between(i,I,LEN) -> lookup(A,i) = lookup(a,i))
```

Definitions:
1. `done(i,oldA,newA) := all j. between(j,0,i) -> lookup(newA,j) = f(lookup(oldA,j))`
2. `todo(i,oldA,newA) := all j. between(j,i,LEN) -> lookup(newA,j) = lookup(oldA,j)`

Lemmas:
1. `done(0,oldA,newA)`
2. `todo(0,a,a)`
3. `all i. all a. all x. done(i,a,x) -> todo(i,a,x) -> done(add(i,1),a,update(x,i,f(lookup(x,i))))`
4. `all i. all a. all x. done(i,a,x) -> todo(i,a,x) -> todo(add(i,1),a,update(x,i,f(lookup(x,i))))`

```hoare {id=hoare-arrays-1}
(hoare
 (program_vars A I LEN)
 (logic_vars a)
 (assumptions
  (done-init "all a1. all a2. done(0,a1,a2)")
  (todo-init "all a. todo(0,a,a)")
  (done-step "all i. all a. all x. done(i,a,x) -> todo(i,a,x) -> done(add(i,1), a, update(x, i, f(lookup(x, i))))")
  (todo-step "all i. all a. all x. done(i,a,x) -> todo(i,a,x) -> todo(add(i,1), a, update(x, i, f(lookup(x, i))))")
  )
 (precond "A = a")
 (postcond "done(LEN,a,A)"))
```
