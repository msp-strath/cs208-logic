# The Wizard's Pets

Let's start with a very simple problem, which we will gradually make more complex to demonstrate different ways of encoding constraints in a logical form.

*Imagine*: we have been trapped by a wizard who need someone to look after their pets while they go on holiday. They have three pets, a *snake*, a *mouse* and a *parrot*, and demands that we take at least one of them home to look after.

Making this decision is hard, so we defer the problem to a computer. Following the technique of Logical Modelling outlined above, we encode the problem as follows:

1. A solution to this problem consists of three yes/no decisions:
   1. whether or not to take the snake,
   2. whether or not to take the mouse, and
   3. whether or not to take the parrot.
2. We encode each of these decisions as a boolean variable (an "atom") called `snake`, `mouse` and `parrot`.
3. We encode the wizard's demand that we take at least one of their pets as the logical formula `snake | mouse | parrot`. Literally, `snake` OR `mouse` OR `parrot` is true.
4. Solutions to the problem are then boolean values for the atoms `snake`, `mouse`, and `parrot` that make the formula true.

## Encoding the problem

The following code shows how to encode this problem in the Logical Modelling Tool. The first part defines the relevant atoms `snake`, `mouse` and `parrot`:

```
atom snake   // true if we take the snake, false if not
atom mouse   // same for the mouse
atom parrot  // same for the parrot
```

The second part defines `wizards_demand` to be the logical formula representing the Wizard's demand.

```
define wizards_demand {
  snake | mouse | parrot
}
```

## Computing a solution

The final part instructs the computer to check whether the Wizard's is satisfiable (`ifsat`), and if so to return the values of the three atoms in a record. Click on the **Run** button to run this complete example and see a sample solution:

```lmt {id=wizard1}
atom snake
atom mouse
atom parrot

define wizards_demand {
  snake | mouse | parrot
}

ifsat (wizards_demand)
  { "snake" : snake, "mouse" : mouse, "parrot" : parrot }
```

## Computing all solutions

We can also ask the computer for all possible solutions to the Wizard's demand by using `allsat` instead of `ifsat`. There are quite a few of them (click **Run** to compute them all):

```lmt {id=wizard2}
atom snake
atom mouse
atom parrot

define wizards_demand {
  snake | mouse | parrot
}

allsat (wizards_demand)
  { "snake" : snake, "mouse" : mouse, "parrot" : parrot }
```

## Adding another constraint

Looking at these potential solutions, and thinking a bit about the nature of the animals involved, we see that the Wizard has laid a trap. If you take the snake and the mouse then the snake will eat the mouse. The Wizard will be angry, and may very well find a way to turn you into a replacement pet.

To make sure that there is no regrettable end-of-mouse event, we define another constraint `carefulness` that says that either we don't have the snake (`~snake`) or we don't have the mouse (`~mouse`). Here `~` means NOT (also written as `!` or `¬`). We combine the two constraints `wizards_demand` and `carefulness` with an AND, written as `&`:

```lmt {id=wizard5}
atom snake
atom mouse
atom parrot

define wizards_demand {
  snake | mouse | parrot
}

define carefulness {
  // NOT the snake OR NOT the mouse (so never both)
  ~snake | ~mouse
}

allsat (wizards_demand &
        carefulness)
  { "snake" : snake, "mouse" : mouse, "parrot" : parrot }
```

Computing all the solutions shows that we never have both the snake and the mouse at the same time.

## Friendliness

After spending some time with the animals, we learn that the mouse will only be happy if the parrot comes too. So, to maintain happiness, we add the constraint that having the mouse implies that we have the parrot. Logically, we can express this as `mouse -> parrot`, which is equivalent to `~mouse | parrot`. We add this as another constraint, `&`d with the others:

```lmt {id=wizard7}
atom snake
atom mouse
atom parrot

define wizards_demand {
  snake | mouse | parrot
}

define carefulness {
  // NOT the snake OR NOT the mouse (so never both)
  ~snake | ~mouse
}

define mouse_wants_parrot {
  //   NOT the mouse OR the parrot
  // equivalent to:
  //   mouse IMPLIES parrot
  ~mouse | parrot
}

allsat (wizards_demand &
        carefulness &
        mouse_wants_parrot)
  { "snake" : snake, "mouse" : mouse, "parrot" : parrot }
```

## Exercise

Add a constraint that the parrot wants the mouse by filling in `what_goes_here`.

```lmt {id=wizard8}
atom snake
atom mouse
atom parrot

define wizards_demand {
  snake | mouse | parrot
}

define carefulness {
  // NOT the snake OR NOT the mouse (so never both)
  ~snake | ~mouse
}

define mouse_wants_parrot {
  // NOT the mouse OR the parrot
  ~mouse | parrot
}

define parrot_wants_mouse {
  what_goes_here
}

allsat (wizards_demand &
        carefulness &
        mouse_wants_parrot &
        parrot_wants_mouse)
  { "snake" : snake, "mouse" : mouse, "parrot" : parrot }
```

When `parrot_wants_mouse` is properly defined, you should get two possible solutions to all the constraints combined.
