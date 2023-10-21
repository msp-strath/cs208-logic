[Contents](contents.html)

# Beyond the binary: Three-valued Logic

Propositional Logic, as we have studied it so far in this course, is *two valued*. It is also possible to consider logics with more than two truth values.  These “multi-valued” logics have practical uses in representing things like degrees of truth, or fuzzily defined concepts, or the absence of evidence.

The three-valued logic we will look at here is similar to the kind of logic used in SQL, where booleans can be `TRUE`, `FALSE`, or `NULL`. It is sometimes called “Kleene's 3-valued logic”, after the American logician Stephen Kleene, or “Ƚukasiewicz logic”, after the Polish logician Jan Ƚukasiewicz (the two logics differ in how they handle implication, which I won't cover here). I'll write these three truth values as:

| Value | Meaning                      |
|-------|------------------------------|
| T     | “true”                       |
| I     | “indeterminate” or “unknown” |
| F     | “false”                      |

### Connectives

The following tables describe how $\land$, $\lor$, and $\lnot$ work with the new truth values. For $\land$ and $\lor$, I have written these out with the possible input values along the top and left side, rather than the traditional style, because there are now more combinations of the two inputs to consider.

\begin{mathpar}
  \begin{array}{c|ccc}
    \land  & \false & \indet & \true \\
    \hline
    \false & \false & \false & \false \\
    \indet & \false & \indet & \indet \\
    \true  & \false & \indet & \true
  \end{array}

  \begin{array}{c|ccc}
    \lor   & \false & \indet & \true \\
    \hline
    \false & \false & \indet & \true  \\
    \indet & \indet & \indet & \true \\
    \true  & \true  & \true  & \true
  \end{array}

  \begin{array}{c|c}
    P   & \lnot P \\
    \hline
    \false & \true \\
    \indet & \indet \\
    \true  & \false
  \end{array}
\end{mathpar}
So $\false \land \indet = \false$, $\false \lor \indet = \indet$, etc.

We can think of $\indet$ as the absence of evidence for either true or false. The connectives $\land$ and $\lor$ only give definite answers when it is safe to do so, otherwise they return $\indet$. For $\land$, we can only definitely say the answer is $\true$ if both inputs are $\true$, but we can definitely say the output is $\false$ if any of the inputs is $\false$. Conversely, for $\lor$, we can only say the output is definitely $\false$ when both inputs are $\false$, and so on. So three-valued logic is a way of dealing with *missing data*. This is the reason it is used in SQL, where we may have `NULL`s representing missing or unknown data.

Another way to understand these tables is to think of the truth values as being ordered as $\false < \indet < \true$ (or you could think of $0 < \frac{1}{2} < 1$). Then $P \land Q$ takes the \emph{minimum} of the values (minimum: so the “worst” result wins), and $P \lor Q$ takes the \emph{maximum} of the values (maximum: so the “best” result wins). Negation swaps the order, leaving $\indet$ in the middle. The interpretation of $\land$ and $\lor$ as maximum and minimum respectively works for ordinary two-valued logic too, with the ordering $\false < \true$. Ordering truth values and using minimum and maximum for $\land$ and $\lor$ is a general technique for extending logic to more than two truth values.

### Valuations

*Valuation*s $v$ can now assign any of the truth values $\false, \indet, \true$ to the atomic propositions. \emph{Truth value assignment} proceeds connective-by-connective as before, but uses the tables from above.

\begin{displaymath}
  \begin{array}{lcl}
    \sem{A}v&=&v(A) \\
    \sem{P \land Q}v&=&\sem{P}v \land \sem{Q}v \\
    \sem{P \lor Q}v&=&\sem{P}v \lor \sem{Q}v \\
    \sem{\lnot P}v&=&\lnot \sem{P}v
  \end{array}
\end{displaymath}

**Note**: The $\land$s, $\lor$s and $\lnot$s \emph{inside} the square $\sem{\textrm{brackets}}$ refers to the syntax of the logic. The $\land$s, $\lor$s and $\lnot$s outside refer to the semantics (the tables above). This syntax/semantics distinction is the same as for our usual [two-valued semantics](prop-logic-semantics.html).

### Entailment

One of the definitions of [entailment](entailment.html) we saw for two-valued logic stays the same:

\begin{itemize}
\item $P_1, \dots \models Q$ if for all valuations $v$, if all the
  assumptions are true (all $\sem{P_i}v = \true$), then the conclusion
  is true ($\sem{Q}v = \true$).
\end{itemize}

The other formulation is slightly different, because “not true” can now mean either false `F` or indeterminate `I`:

\begin{itemize}
\item $P_1, \dots \models Q$ if for all valuations $v$, either:
  \emph{a)} one of the assumptions is false or indeterminate (there is
  an $i$ such that $\sem{P_i}v = \false$ or $\sem{P_i}v = \indet$), or
  \emph{b)} the conclusion is true ($\sem{Q}v = \true$).
\end{itemize}

## Exercises

1. Which of the following entailments are valid in this three valued logic?

	1. $\models A \lor \lnot A$

	   ```details
       Answer...

	   Let's build a table of all the possible valuations, and work out
	   the truth value assigned to the conclusion:

	   \begin{displaymath}
		 \begin{array}{c|c|c}
		   \textit{valuation}& &\textit{conclusion}\\
		   A&\lnot A&A\lor\lnot A \\
		   \hline
		   \false&\true &\true \\
		   \indet&\indet&\indet \\
		   \true &\false&\true
		 \end{array}
	   \end{displaymath}

	   The first column is the valuation, the second column is some
	   intermediate working, and the final column is the
	   conclusion. For an entailment to hold, we must have that for
	   every row, if the assumptions are all true then the conclusion
	   is true. In this case there are no assumptions, so for this
	   entailment to be valid, the conclusion must always be
	   true. However, in the middle line it is $\indet$
	   (indeterminate). So the entailment $\models A \lor \lnot A$ does
	   not hold.
	   ```

	2. $\lnot (A \land B) \models \lnot A \land \lnot B$

	   ```details
       Answer...

	   The truth table for this entailment looks as follows, where I
	   have marked the columns making up the valuation, the assumptions
	   (one in this case), and the conclusion.

	   \begin{displaymath}
		 \begin{array}{cc|ccc|c|c}
		   \multicolumn{2}{c|}{\textit{valuation}} & \multicolumn{3}{c|}{\textit{(intermediate)}} & \textit{assumptions} & \textit{conclusion} \\
		   A      & B      & \lnot A & \lnot B & A \land B & \lnot (A \land B) & \lnot A \land \lnot B \\
		   \hline
		   \false & \false & \true   & \true   & \false    & \true             & \true \\
		   \false & \indet & \true   & \indet  & \false    & \true             & \indet \\
		   \false & \true  & \true   & \false  & \false    & \true             & \false \\
		   \indet & \false & \indet  & \true   & \false    & \true             & \indet \\
		   \indet & \indet & \indet  & \indet  & \indet    & \indet            & \indet \\
		   \indet & \true  & \indet  & \false  & \indet    & \indet            & \false \\
		   \true  & \false & \false  & \true   & \false    & \true             & \false \\
		   \true  & \indet & \false  & \indet  & \indet    & \indet            & \false \\
		   \true  & \true  & \false  & \false  & \true     & \false            & \false \\
		 \end{array}
	   \end{displaymath}

	   Again, to check that an entailment holds, we need to check that
	   for every line (i.e., every valuation), if all the assumptions
	   are true, then so is the conclusion. We can see this is not the
	   case here: in the second line, the assumption is $\true$, but
	   the conclusion is $\indet$. So the entailment
	   $\lnot (A \land B) \models \lnot A \land \lnot B$ is not valid
	   in this logic. Note that it is not valid in normal (two-valued)
	   logic either: the third line is the same as it would be in the
	   two-valued case, and is enough to make the entailment invalid.
	   ```

	3. $\lnot (A \lor B) \models \lnot A \lor \lnot B$

	   ```details
       Answer...

	   % A confession. This question was meant to be: does the following
	   % entailment hold:
	   % \begin{displaymath}
	   %   \lnot (A \land B) \models \lnot A \lor \lnot B
	   % \end{displaymath}
	   % Note the switch $\land$ and $\lor$ in the left hand side.

	   % Apologies for this. I'll do the one as it appears first, then
	   % I'll do the one I meant to do.

	   We have the truth table:
	   \begin{displaymath}
		 \begin{array}{cc|ccc|c|c}
		   \multicolumn{2}{c|}{\textit{valuation}} & \multicolumn{3}{c|}{\textit{(intermediate)}} & \textit{assumptions} & \textit{conclusion} \\
		   A      & B      & \lnot A & \lnot B & A \lor B & \lnot (A \lor B) & \lnot A \lor \lnot B \\
		   \hline
		   \false & \false & \true   & \true   & \false   & \true            & \true \\
		   \false & \indet & \true   & \indet  & \indet   & \indet           & \true \\
		   \false & \true  & \true   & \false  & \true    & \false           & \true \\
		   \indet & \false & \indet  & \true   & \indet   & \indet           & \true \\
		   \indet & \indet & \indet  & \indet  & \indet   & \indet           & \indet \\
		   \indet & \true  & \indet  & \false  & \true    & \false           & \indet \\
		   \true  & \false & \false  & \true   & \true    & \false           & \true \\
		   \true  & \indet & \false  & \indet  & \true    & \false           & \indet \\
		   \true  & \true  & \false  & \false  & \true    & \false           & \false \\
		 \end{array}
	   \end{displaymath}
	   For this example, the entailment does hold: the assumption is
	   only $\true$ on line 1, and in this case the conclusion is
	   $\true$ as well. Note again that this entailment holds in
	   two-valued logic too.
	   ```

    4. $A \models A \lor B$

	   ```details
       Answer...

       The truth table for this entailment looks as follows, where I
	   have marked the columns making up the valuation, the assumptions
	   (one in this case), and the conclusion.

	   \begin{displaymath}
		 \begin{array}{cc|c|c}
		   \multicolumn{2}{c|}{\textit{valuation}} & \textit{assumptions} & \textit{conclusion} \\
		   A & B & A & A \lor B \\
		   \hline
		   \false & \false & \false & \false \\
		   \false & \indet & \false & \indet \\
		   \false & \true  & \false & \true  \\
		   \indet & \false & \indet & \indet \\
		   \indet & \indet & \indet & \indet \\
		   \indet & \true  & \indet & \true \\
		   \true  & \false & \true  & \true \\
		   \true  & \indet & \true  & \true \\
		   \true  & \true & \true  & \true \\
		 \end{array}
	   \end{displaymath}

	   Again, to check that an entailment holds, we need to check that
	   for every line (i.e., every valuation), if all the assumptions
	   are true, then so is the conclusion. For the first six lines,
	   the (one) assumption is not true, so these lines are OK. For the
	   last three lines, the assumption is true, and so is the
	   conclusion. So all the lines are OK, and the entailment
	   $A \models A \lor B$ holds.
	   ```

	5. $\lnot \lnot A \models A$

	   ```details
       Answer...

       The table of all possible valuations:
	   \begin{displaymath}
		 \begin{array}{c|c|c}
		   \textit{valuation}&\textit{assumptions}&\textit{conclusion} \\
		   A & \lnot \lnot A & A \\
		   \hline
		   \false & \false & \false \\
		   \indet & \indet & \indet \\
		   \true  & \true  & \true
		 \end{array}
	   \end{displaymath}
	   For the entailment to hold, it must be that whenever the
	   assumptions are all $\true$, the conclusion is $\true$. In lines
	   1 and 2, the assumption is $\false$ and $\indet$ respectively,
	   so these lines are OK. In the final line, the assumption is
	   $\true$, but the conclusion is $\true$ so this is also
	   OK. Therefore, the entailment $\lnot\lnot A \models A$ is valid.
	   ```

2. Are there any valid formulas in this logic? In other words, are there any formulas $P$ such that for all valuations $v$, $\sem{P}v = \true$?

   ````details
   Answer...

   The answer is **no**, there are no valid formulas in this logic.

   To see why, let $P$ be any formula in the logic. If we take the valuation $v$ that assigns $\indet$ to all atomic propositions, then it must be the case that $\sem{P}v = \indet$. Why? Look at the truth tables for $\land$, $\lor$, and $\lnot$ above. Every time their inputs are all $\indet$, their output is $\indet$. So if all the atomic propositions are assigned $\indet$, then $\indet$s will “bubble up” the tree and the whole formula will be assigned $\indet$.

   Now, for the formula $P$ to be valid, it must be the case that $\sem{P}v = \true$ for all valuations. But we have found a valuation such that $\sem{P}v = \indet$ (the one that assigns $\indet$ to every atom), so $P$ cannot be valid.

   This argument works for any $P$, so no formula can be valid.
   ````

## Further Reading

FIXME

1. Adding implication
2. Solving circular statements
2. More truth values, paraconsistent logics
3. Truth values between `0` and `1`.
4. Logical plurality
