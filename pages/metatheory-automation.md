# Metatheory, Automation, and Incompleteness

In this final part of the course, we take a quick look at the Metatheory of Predicate Logic. This material is not examinable, and is provided for information purposes only.

```youtube
YPjGFDUTK_8
```

[Slides for this video (PDF)](week10-slides.pdf)

*Metatheory* is the study of properties of a system of logic as a whole, rather than doing individual proofs within the logic. The Predicate Logic proof system we have built up over the last few weeks has the following properties:

- It is *sound*, meaning that if we can prove some judgement `Γ ⊢ P`, then the entailment `Γ ⊧ P` is valid. This gives us confidence to actually use the proof rules for reasoning.
- It is *complete*, as long as we add a rule for excluded middle (`P ∨ ¬P` for all `P`). This means that if an entailment `Γ ⊧ P` is valid, then there is a proof of `Γ ⊢ P`. Completeness for Predicate Logic is not a simple thing to prove, and is usually called “Gödel's Completeness Theorem” after Kurt Gödel, the first person to prove it.

You may have noticed that applying the proof rules in the system is often somewhat mechanical. So could we get a computer to do them for us? More ambitiously, could we get a computer to prove (or disprove) formulas for us automatically? This is one of the oldest dreams of Artifical Intelligence research, and still an active area of research today.

One way of getting a computer to reason for us is to set down some axioms (such as the Peano axioms we saw in the section on [induction](induction.md)). Then to find out whether or not a formula `P` is provable or not from those axioms, we could get a computer to simultaneously try to generate either a proof of `P` or a proof of `¬P`. If we find either one, then we can stop and claim success.

This search strategy relies on two *metatheoretic* assumptions:

1. We need to know that our axioms are *consistent*, meaning that it is not possible to prove both *P* and *¬P*. We are pretty sure that this is true for the Peano axioms, but it is always a worry.
2. We need to know that our axioms are *syntactically complete*, meaning that for any *P*, at least one of *P* or *¬P* is provable. If neither is provable, then our search will never finish.

Unfortunately, the second one of these is not true for many interesting theories: Gödel's First Incompleteness Theorem states that any effectively generated collection of axioms that can prove some arithmetic is either inconsistent or incomplete in this sense. This means that there are formulas *P* that are not provable or disprovable from the axioms. In the case of Peano arithmetic, this means that there are true facts about the “actual” numbers that cannot be proved from the axioms. And there is no way out of this, the theorem also states that if we add these new facts as axioms, there will always be more facts that are still not provable.

Gödel's First Incompleteness theorem is a fundamental limitation of symbolic logic. Once a system gets powerful enough to encode its own reasoning in itself, which is what having arithmetic allows us to do, there will always be statements that cannot be proved or disproved in the logic. Gödel's Second Incompleteness theorem goes a bit further and states that it is impossible to prove a system's own consistency within itself. This means that we can only ever prove the consistency of a system by using a system that is ”more powerful” than the one we want to prove.

Several people have argued that Gödel's Incompleteness Theorems mean that it is impossible for computers to match the reasoning abilities of humans. The video above, I try to explain why Gödel's theorems cannot be used to prove that this is the case.

But the question still remains. Even if we cannot fully automate logic, can we automate useful fragments of it? This is still a major research field, with applications in Mathematics, Software Engineering (to prove useful properties of programs, or to prove that programs do have bugs), Hardware Engineering (to prove that chip designs meet their specifications), Computer Security (to discover security flaws in systems), and many other fields.

One approach is to restrict to axiomatisations that are weaker than Peano arithmetic (i.e. they can say less), so that Gödel's theorem does not apply. For example, one such restriction is to remove multiplication, getting a system called Linear Arithmetic, or Presburger Arithmetic. Specialised solvers for useful theories have been combined with SAT solvers to make Satisfiability Modulo Theory (SMT) solvers. SMT solvers have proven to be extremely useful tools for doing practical logical reasoning. Amazon Web Services (AWS) uses an SMT solver to check for [security flaws in cloud configurations](https://aws.amazon.com/blogs/security/protect-sensitive-data-in-the-cloud-with-automated-reasoning-zelkova/). A popular tool is Microsoft Research's [Z3 Solver](http://theory.stanford.edu/~nikolaj/programmingz3.html).

Another approach is to restrict the kinds of formulas we can write down. One useful subset of formulas are called “Horn Clauses” which all have the form `∀ x₁ ... ∀ xₙ . P₁(..) → ... → Q(..)`. Horn clauses have an efficient proof search technique that forms the basis of *logic programming languages* like [Prolog](https://www.metalevel.at/prolog) and the database query language Datalog.

A good introduction to automated theorem proving is the [Handbook of Practical Logic and Automated Reasoning](https://www.cl.cam.ac.uk/~jrh13/atp/index.html) which develops implementations of several automated proof systems. Since not all proofs can be
automated, interactive theorem proving, like you have been doing in this course, is now a major area. The interactive proof system we have used in this course is only suitable for relatively small examples, but systems have been developed that can deal with much larger proofs, such as [Rocq](https://rocq-prover.org/), [Isabelle](https://isabelle.in.tum.de/), [Lean](https://leanprover.github.io/) and [Agda](https://wiki.portal.chalmers.se/agda/pmwiki.php). If you do the [CS410 Advanced Functional Programming](https://github.com/gallais/CS410-2024) course in fourth year, you will be using Agda to construct formal proofs that are much larger and more interesting than the ones in this course.
