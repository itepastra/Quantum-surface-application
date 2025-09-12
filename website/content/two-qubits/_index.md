+++
weight = 3
title = "Two Qubits"
sort_by = "weight"
+++

We've seen how a single qubit works now, it might seem interesting at first glance, but it pales
in comparison to what you can do with multiple qubits. Before we can go to large amounts of qubits,
we should start with two.

## Two Qubit Gates

As the name suggests these gates can be used to make two qubits do something together.
Often they are a controlled single qubit gate, where the single qubit gate can be whatever we
choose it to be.
This isn't always the case though, there's also gates like the SWAP gate that swap the state of two
qubits.

## Universality

You may feel like if one and two qubit gates exist, are there also gates with more qubits?
Yes, there are, but all of these 3+ qubit gates can be rewritten as a chain of single and two
qubit gates. Actually, if you have access to any single qubit rotation and one of the controlled
gates you can use them to write any possible quantum computing program. This is called a universal
gate set and can be used for universal quantum computing.

We'll now have a look at some interesting two qubit gates.
