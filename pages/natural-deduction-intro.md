[Contents](contents.html)

# Natural Deduction

After we look at the general idea of deductive systems, we focus on the particular system we will be using in this course: (focused) Natural Deduction. The Natural Deduction system was invented by the logician Gerhard Gentzen in 1934 as a way to formalise proofs in logic. We will be using a variant of Gentzen's system that is designed to be easy to use.

The key feature of Natural Deduction is its *modularity*. There are two basic rules of the system `Done` and `Use` that allow us to manage assumptions. Then there are separate rules for each connective "and", "implies", "or" and "not". For each connective, we have Introduction rules that tell us how to prove a statement using that connective, and Elimination rules that tell us how to use a statement built from that connective. The natural symmetry between introduction and elimination rules gives the whole system a balanced feel.

## Video: Introducing Natural Deduction

```youtube
6Q2ujIUj67Y
```

## Online Proof Editor

### Video

```youtube
ditMR5-ilC4
```

### Commands for the Editor



### Exercises

Writing out formal proofs on paper is extremely tedious, so I have written an online proof editor tool that you will be using to build your own proofs.

1. A entails A:
   ```focused-nd
   (config
    (assumptions (H "A"))
	(goal "A"))
   ```

2. A and B entails `A /\ B`
   ```focused-nd
    (config
	 (assumptions (H1 A) (H2 B))
     (goal "A /\ B"))
    ```

3. `A /\ B` entails `A /\ B`
   ```focused-nd
   (config
    (assumptions (H "A /\ B"))
    (go "A /\ B"))
   ```

4. `A /\ B` entails `B /\ A`
   ```focused-nd
   (config
    (assumptions (H "A /\ B"))
    (goal "B /\ A"))
   ```

5. Anything entails `T`
   ```focused-nd
   (config
    (assumptions (H "A"))
    (goal "T"))
   ```

6. True on the right:
   ```focused-nd
   (config
    (assumptions (H "A"))
    (goal "A /\ T"))
   ```

7. True on the left:
   ```focused-nd
   (config
    (assumptions (H "A"))
    (goal "T /\ A"))
   ```

---

[Contents](contents.html)
