# Soundness, Completeness, and some Philosophy

```youtube
Ip5e-fWEkbA
```

[Slides for the video](week05-slides.pdf) (at the end).

```textbox {id=sound-complete-notes}
Enter any notes to yourself here.
```

## Proofs as Programs, Propositions as Types

As mentioned in the video, there is a possible interpretation of logical proofs as processes transforming evidence from premises to conclusions.

One way of taking this idea further is to build an entire combined programming and proving system based on the slogans “*Proofs as Programs*” and “*Propositions as Types*”. This close connection is sometimes called the *[Curry-Howard correspondence](https://en.m.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence)* (or, less correctly, *isomorphism*), after the logicians Haskell Curry and William Alvin Howard.

The video [Propositions as Types](https://www.youtube.com/watch?v=IOiZatlZtGU) by Prof. Phil Wadler (see also [the paper](https://homepages.inf.ed.ac.uk/wadler/papers/propositions-as-types/propositions-as-types.pdf)) describes the idea in an accessible way.

If you do the [CS410 *Advanced Functional Programming* course](https://github.com/gallais/CS410-2024) in 4th year, you will explore the [Agda](https://wiki.portal.chalmers.se/agda/pmwiki.php) system which implements this idea to make writing proofs and programs the same activity.
