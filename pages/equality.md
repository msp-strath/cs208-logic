[Contents](contents.html)

# Equality

In week 7, we added proof rules for the quantifiers “for all” and “exists” to our Natural Deduction proof system. We now extend the proof system in two directions: equality and proofs by induction. The addition of these proof rules greatly expands the range of things with can prove.

We do equality here, and [induction on the next page](induction.html).

In the syntax, equality is a binary predicate symbol that is usually written infix: `t1 = t2`. Equality must be treated specially in our system due to the following crucial property it has: if `t1 = t2` then everything that is true about `t1` is true about `t2`. Or, in more symbols, if `t1 = t2` and `P[x ↦ t1]` then `P[x ↦ t2]`. This property is known as “substitutivity” or, more philosophically, as “indiscernability of equivalents”. It says that if two things are equal, there is no way to write a formula that is true about one and false about the other. We can't express this property as an axiom in our system, so we add it as a new rule.

This is introduced in Video 9.1, with examples in the interactive proof tool in Video 9.3

## Videos

## Exercises
