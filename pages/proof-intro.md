[Contents](contents.html)

# Deductive Proof

We now look at the general idea of deductive systems, collections of inference rules that allow us to derive new facts from existing ones. This is a radically different approach to the “enumerate all possible truth values” approaches we have taken so far by writing out truth tables or by using a SAT solver. Instead, we construct chains (or, more generally, trees) of rules connected together that lead us step by step from some assumptions to a conclusion.

## Video

```youtube
KxJ1uu73JSs
```

[Slides for the video](week04-slides.pdf)

## Example

### Rules

```rules-display
(config
 (rule
  (name "R1")
  (premises (furry X) (makes-milk X))
  (conclusion (mammal X)))

 (rule
  (name "A1")
  (premises)
  (conclusion (furry bear)))

 (rule
  (name "A2")
  (premises)
  (conclusion (makes-milk bear)))

 (rule
  (name "R2")
  (premises (is-covered-in-fibres X))
  (conclusion (furry X)))

 (rule
  (name "A3")
  (premises)
  (conclusion (is-covered-in-fibres coconut)))

 (rule
  (name "A4")
  (premises)
  (conclusion (makes-milk coconut))))
```

### Example 1

```rules {id=rules-example1}
(config
 (rule
  (name "R1")
  (premises (furry X) (makes-milk X))
  (conclusion (mammal X)))

 (rule
  (name "A1")
  (premises)
  (conclusion (furry bear)))

 (rule
  (name "A2")
  (premises)
  (conclusion (makes-milk bear)))

 (rule
  (name "R2")
  (premises (is-covered-in-fibres X))
  (conclusion (furry X)))

 (rule
  (name "A3")
  (premises)
  (conclusion (is-covered-in-fibres coconut)))

 (rule
  (name "A4")
  (premises)
  (conclusion (makes-milk coconut)))

 (goal (mammal bear)))
```

### Example 2

```rules {id=rules-example2}
(config
 (rule
  (name "R1")
  (premises (furry X) (makes-milk X))
  (conclusion (mammal X)))

 (rule
  (name "A1")
  (premises)
  (conclusion (furry bear)))

 (rule
  (name "A2")
  (premises)
  (conclusion (makes-milk bear)))

 (rule
  (name "R2")
  (premises (is-covered-in-fibres X))
  (conclusion (furry X)))

 (rule
  (name "A3")
  (premises)
  (conclusion (is-covered-in-fibres coconut)))

 (rule
  (name "A4")
  (premises)
  (conclusion (makes-milk coconut)))

 (goal (mammal coconut)))
```

---

[Contents](contents.html)
