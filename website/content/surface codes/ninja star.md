+++
title = "ninja star"
weight = 1
+++

The “ninja star” is a catchy name for a distance-3 surface code made up of 17 qubits, also called Surface-17. It includes 9 data qubits ($3^2$) and 8 ancilla qubits ($3^2-1$) that are used to check for errors through stabilizer measurements.

It’s called the “ninja star” because the stabilizers form a star-shaped pattern on the lattice. This pattern isn’t just for show, it’s a visual guide that makes it easy to see which qubits each stabilizer interacts with, helping us understand and correct errors in the quantum system more intuitively.

![ninja star](https://fbi.cults3d.com/uploaders/27143183/illustration-file/cc84013f-e30d-421c-a106-9a2500b58820/7b55673fc8beb715cf82313a739cf8680ab74f9f_hq.gif)


{{ qubitquilt(w=6,h=11,gates='["X","Y","Z","H","S","CX","CZ","MZ","ADD","REMOVE","LABELA","LABELD"]') }}
