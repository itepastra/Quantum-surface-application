+++
title = "The Qubit"
weight = 1
+++

Let's start at the beginning, understanding the qubit.

## What is a qubit

In very short, a qubit is a quantum two-level system. This may still not make sense to you, so
let's explain a bit more.
You may already know about the classical bit, it's the 1s and 0s that your phone or computer uses
to do all the things they do. Since it can have two states (0 or 1) it is a two-level system,
this is already very similar to the qubit. The biggest difference is that the qubit can contain
any mixture of the "0" and "1" state.

We don't need every mixture on this website though, so let's limit us to the six most important ones.
Starting with the purely "0" state, we will name it $\ket{0}$, where we use the $\ket{x}$ as a way
to indicate that it is a quantum state, if you want to learn more, you can look at [Dirac Notation](wikipedia.com/dirac_notation).
Similarly we name the pure "1" state $\ket{1}$. How will we get the four other states though?
Maybe we can start with an even mixture of $\ket{0}$ and $\ket{1}$. If we add them together,
using a $+$, it makes sense to call it $\ket{+} = \ket{0} + \ket{1}$.
If we can use $+$, why wouldn't we be able to use $-$ as well, so $\ket{-} = \ket{0} - \ket{1}$.
Hmm, two left... If we look at the $+$ and $-$ as having a different [Phase](wikipedia.com/phase), 
maybe there can be something in between? That could only make sense if we used some [complex number](wikipedia/complex_number) called $i$, it has a phase right in the middle of $+1$ and $-1$,
so let's call the last two states $\ket{+i} = \ket{0} + i \ket{1}$ and $\ket{-i} = \ket{0} - i \ket{1}$

Now that we know a bit about what we call the states of the qubit normally. Let's have a look
at one in the simulation

{{ qubitquilt(w=1,h=1) }}

Using the buttons at the bottom, you can select what direction to rotate the qubit, try rotating
it to all the colors to the front to get a feel for it. In these texts we'll always
assume the qubit to be in the state towards the front.

If you've done that you may see that there are six different colors. So let's combine the states
and the colors now. We can start with blue and yellow, if we call blue $\ket{0}$ and yellow $\ket{1}$
then the other four colors are in between. Now I say red to be $\ket{+}$, 
therefore the color on the opposite side, cyan must be $\ket{-}$.
Finally, we choose green to mean $\ket{+i}$ and purple to mean $\ket{-i}$. (Let's not go into the reason
why we choose them this way, but it has to do with the math behind this all)

Now that we know about what a qubit is, let's figure out what those buttons in the bottom actually mean.
