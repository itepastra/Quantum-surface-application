+++
weight = 3
title = "Measurement"
+++

From the previous part you may be wondering how a qubit which is a two-level system can have 6
different important states.
This all has to do with measuring the qubit. You may or may not have heard about how measuring 
"collapses the state". So let's look into that a bit more.

## Measuring a qubit

Measuring a qubit creates a single bit of classical data from the internal state of the qubit. 
In a measurement you start by choosing a "direction" to measure on, so that could be something like
"is the qubit blue ($\ket{0}$), or is it yellow ($\ket{1}$)". 
Important to note here is that you can only do this for two opposite colors.
Therefore, it is impossible to do is "is the qubit red $\ket{+}$ or green $\ket{+i}$".

You may now want to know what happens if the qubit is red, but you ask it if it's blue or yellow??
Well, in that case the qubit may say either with 50/50 odds, the interesting thing is that after
saying it is a color. It fully becomes that color, so if you measure it twice in a row in the same
way you will always (if no errors occur) get the same result.

## Limits of measurement

Maybe you didn't know the exact orientation of the qubit before you measured it.
In that case you still don't fully know after measuring, but you can approximate it
by redoing all the operations you did on the qubit and measuring many independent runs.
The more you do this the better your estimate for the internal state becomes, but you would
be spending more and more time as well.

## Measuring in the simulation

Since we are not using an actual quantum computer we can fully know the state of the qubit however,
which you can see by the color facing towards you. If however a "measurement" is done, the qubit will
rotate to what the result was to imitate reality.

{{ qubitquilt(w=1,h=1,gates='["X","Y","Z","MZ"]') }}
