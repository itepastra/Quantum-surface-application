+++
title = "Single Qubit Operations"
weight = 2
+++

We should go into the rotating the qubit a bit more, it's actually all that you can do with the qubit.
If you can rotate the qubit in at least 2 different directions with any angle, you can do any
single qubit operation. These operations are also sometimes called "single qubit gates".
In our simulation we can't go to all the possible states, due to how difficult it is to simulate.
In an actual quantum computer you can put the qubit in any direction. For example between red and yellow.

It may make sense to give the gates some names. We can use the color of the gate to be a direction,
so blue is Z, red is X and green is Y. It's conventional to have a 180 degree flip being just the letter,
so we should add that the 90 degrees these rotate are half of that. 
If we call them $ \sqrt(Z) $, $ \sqrt(X) $ and $ \sqrt(Y) $ doing it twice (multiplying) gives the 180 degree
flip that's conventional.

{{ qubitquilt(w=1,h=1) }}

