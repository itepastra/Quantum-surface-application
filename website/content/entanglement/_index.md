+++
title = "Entanglement"
weight = 4
sort_by = "weight"
+++

As you may have seen in the previous chapter, the controlled gates acting on the qubits make them
spin all around. The reason this happens is because measuring either of the qubits in any possible
direction will give a 50/50. The big difference is that what you measure in one of the qubits
you know what the state of the other qubit will be even before measuring it.
In the words of colors, asking "is the qubit blue or is it yellow" makes no sense, but
"is the left qubit the same color as the right qubit" gives some actual information.

Another important quirk to understand is that in real life, if you had one of the two qubits
in the pair and someone else has the other qubit,
you wouldn't be able to know if you were the first or the second person to measure it.
This makes it impossible to actually transmit information using the pair, since both
people just measure their own qubit as blue half the time and as yellow the other half.
This doesn't mean entanglement is useless, it just can't be used for transmitting data directly.

{{ qubitquilt(w=3,h=5,gates='["X","Y","Z","H","S","CX","CZ","MZ","ADD","REMOVE","LABELA","LABELD"]') }}
