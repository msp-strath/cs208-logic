[Contents](contents.html)

# Circuits

```lmt
domain node { X, Y, Z }

atom activated(n : node)

define and(x : node, y : node, z : node) {
  (~activated(x) | activated(y)) &
  (~activated(x) | activated(z)) &
  (activated(x) | ~activated(y) | ~activated(z))
}

define or(x : node, y : node, z : node) {
    (~activated(x) | activated(y) | activated(z))
  & (activated(x) | ~activated(y))
  & (activated(x) | ~activated(z))
}

define not(x : node, y : node) {
    (~activated(x) | activated(y))
  & (~activated(y) | activated(x))
}

print("Checking or...")

allsat(or(X, Y, Z))
  { for(n : node) n : activated(n) }

print("Checking and...")

allsat(and(X, Y, Z))
  { for(n : node) n : activated(n) }
```

---

[Contents](contents.html)
