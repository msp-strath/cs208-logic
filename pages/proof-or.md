[Contents](contents.html)

# Proof Rules for Or and Not

## Videos

```youtube
VmDShN9HZd4
```

```youtube
BEAE1Xg0SYE
```

## The Interactive Editor

### Video

```youtube
sqJxNGv3IZ0
```

### Commands

FIXME

### Exercises

#### Exercise 1

If we have `A` or `B`, and both imply `C`, then we have `C`.

```focused-nd {id=or-ex1}
(config (goal "(A \/ B) -> (A -> C) -> (B -> C) -> C"))
```

#### Exercise 2

If we have `A` or `B`, and `A` implies `C` and `B` implies `D`, then we have `C` or `D`.

```focused-nd {id=or-ex2}
(config (goal "(A \/ B) -> (A -> C) -> (B -> D) -> (C \/ D)"))
```

#### Exercise 3

If `A` or `B` implies `C`, then we know that both `A` implies `C` and `B` implies `C`.

```focused-nd {id=or-ex3}
(config (goal "((A \/ B) -> C) -> ((A -> C) /\ (B -> C))"))
```

#### Exercise 4

`A` or (`B` and `C`) implies (`A` or `B`) and (`A` or `C`). This is one direction of the distributivity law we used in [Converting to CNF](converting-to-cnf.html).

```focused-nd {id=or-ex4}
(config (assumptions (H "A \/ (B /\ C)"))
        (goal "(A \/ B) /\ (A \/ C)"))
```

#### Exercise 5

(`A` or `B`) and (`A` or `C`) imply `A` or (`B` and `C`). This is other direction of distributivity.

```focused-nd {id=or-ex5}
(config (assumptions (H "(A \/ B) /\ (A \/ C)"))
        (goal "A \/ (B /\ C)"))
```

#### Exercise 6

`A` implies `¬¬A`:

```focused-nd {id=or-ex6}
(config (goal "A -> ¬ ¬ A"))
```

#### Exercise 7

If we assume `A` or `¬A`, then `¬¬A` implies `A`. (We can't prove `¬¬A → A` without this assumption, see [Soundness, Completeness, and Some Philosophy](sound-complete-meaning.html).

```focused-nd {id=or-ex7}
(config (assumptions ("excluded-middle" "A \/ ¬A"))
        (goal "¬¬A -> A"))
```

---

[Contents](contents.html)
