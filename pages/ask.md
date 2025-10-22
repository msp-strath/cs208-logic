# Test of Fake Ask

## Ask

```ask
ffof
```

Need a custom proof layout for ask derivations.

## Hoare Logic

### Test 1

```hoare {id=hoare-test}
(hoare
 (program_vars X)
 (precond "T")
 (postcond "X = 10"))
```

### Test 2

```hoare {id=hoare-test-2}
(hoare
 (program_vars X)
 (logic_vars x)
 (precond "X = x")
 (postcond "X = add(x, 1)"))
```
