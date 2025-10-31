+++
title = "Stabilizers"
weight = 5
sort_by = "weight"
+++


In the previous subsections you saw a grid of qubits and types of operations that can be applied to them. But these qubits are not perfect. They don't always stay intact. Sometimes, in practice, stuff happen that add errors to them, which alters their state. There are two important types of errors: bit-flip (also called X errors), that changes blue to yellow and yellow to blue, and phase-flip (also called Z errors), that adds a minus in front of the yellow state. These errors can occur at the same time and in this case we refer to them as Y errors. 

To detect what errors occurred and on which qubits from the grid, we use stabilizers. Now, you wonder, what are stabilizers? Well, they are a product of Pauli operators (say, $Z_1Z_2Z_3$ or $X_1X_2X_3$) that are applied to the ensemble of qubits we're looking at. Think of them like sensors that check if the qubits are in the right state. If they all read "+1", everything is fine. If some of them read "-1", it means there are errors on some qubits. Based on which stabilizers indicated "-1", we can identify exactly what qubits have errors. This sequence of '+1's and '-1's indicated by the stabilizers is called a syndrome measurement. Every combination can be mapped to a particular state of the system. 

{{ qubitquilt(w=4,h=8,gates='["X","Y","Z","H","S","CX","CZ","MZ","ADD","REMOVE","LABELA","LABELD"]') }}
