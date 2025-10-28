# Hoare Logic with Arrays

## Characterising Arrays


```formula
all i. lookup(update(A,i,x),i) = x
```

```formula
all i. all j. ¬i = j -> lookup(update(A,i,x),j) = lookup(A,j)
```
