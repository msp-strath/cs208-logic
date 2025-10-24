# Hoare Logic

This page current contains several test examples for the Hoare Logic tool. The content of these pages is unstable and will change in incompatible ways in the future.

## Examples

### Example 1

```hoare {id=hoare-test}
(hoare
 (program_vars X)
 (precond "T")
 (postcond "X = 10"))
```

### Example 2

```hoare {id=hoare-test-2}
(hoare
 (program_vars X)
 (logic_vars x)
 (precond "X = x")
 (postcond "X = add(x, 1)"))
```

### Example 3

```hoare {id=hoare-test-3}
(hoare
 (program_vars X Y)
 (logic_vars x)
 (precond "X = x")
 (postcond "X = add(x, 1) /\ Y = x"))
```

### Example 4

```hoare {id=hoare-test-4}
(hoare
 (program_vars RESULT INPUT)
 (precond "T")
 (postcond "f(INPUT) = 5 -> RESULT = 1"))
```

### Example 5

```hoare {id=hoare-test-5}
(hoare
 (program_vars RESULT INPUT)
 (precond "T")
 (postcond "(f(INPUT) = 5 -> RESULT = 1) /\ (¬f(INPUT) = 5 -> RESULT = 2)"))
```

### Example 6

```
{ T }
TOTAL := 0
I := 0
while (I != X) {
  TOTAL := I + TOTAL
  I := I + 1
}
{ TOTAL = sumUpTo(X) }
```

```hoare {id=hoare-test-6}
(hoare
 (program_vars TOTAL I X)
 (assumptions
  (sum-0 "sumTo(0) = 0")
  (sum-plus-1 "all x. sumTo(add(x,1)) = add(sumTo(x), x)"))
 (precond "T")
 (postcond "TOTAL = sumTo(X)"))
```
