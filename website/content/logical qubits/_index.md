+++
title = "Logical qubits"
weight = 6
sort_by = "weight"
+++


It would be unwise to store information in a single physical qubit, because they are fragile and there's not much you can do with them separately. To overcome this, we take groups of physical qubits, which we call 'logical qubits'. By spreading information across more qubits, errors on a few of them won't destroy the logical qubit altogether, kind of like when you can read a message even though a few of the letters got smudged.



{{ qubitquilt(w=6,h=11,gates='["X","Y","Z","H","S","CX","CZ","MZ","ADD","REMOVE","LABELA","LABELD"]') }}
