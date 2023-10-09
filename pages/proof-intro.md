[Contents](contents.html)

# Deductive Proof

```rules-proof
(rule
 (name "Rule1")
 (premises (furry X) (makes-milk X))
 (conclusion (mammal X)))

(rule
 (name "Axiom1")
 (conclusion (furry bear)))

(rule
 (name "Axiom2")
 (conclusion (makes-milk bear)))

(rule
 (name "Rule2")
 (premise (has-fibrous-outer-layer X))
 (conclusion (furry X)))

(rule
 (name "Axiom3")
 (conclusion (has-fibrous-outer-layer coconut)))

(rule
 (name "Axiom4")
 (conclusion (makes-milk coconut)))

(goal (mammal bear))
```

```rules-proof
(rule
 (name "OR-elim")
 (parameters P Q)
 (premises (or P Q) (|- P R) (|- Q R))
 (conclusion R))
```

```nd-proof
(goal "A -> A")
(assumptions
  (a-is-true "A"))
```

---

[Contents](contents.html)
