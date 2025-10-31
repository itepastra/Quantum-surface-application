+++
title = "Surface codes"
weight = 7
sort_by = "weight"
+++


A surface code is a 2D grid of physical qubits surrounded by stabilizers whose aim is to detect potential errors on them. The most commonly used configuration of a surface code consists of:

- data qubits, which are the ones we use to store information and are prone to errors

- ancilla qubits, which are of two types: Z, for phase-flip errors, and X, for bit-flip errors.

Each data qubit is surrounded by two Z ancillas vertically and two X ancillas horizontally. Each of these ancillas interacts only with its neighbouring data qubits.

A parameter that's important in describing a surface code is its size or code distance d, which also represents the smallest number of physical qubit errors that can cause a logical qubit error that cannot be corrected or, in other words, the minimum weight error that can go undetected by the code. A surface code of distance d can always correct up to $[\frac{d-1}{2}]$ errors.


{{ qubitquilt(w=6,h=11,gates='["X","Y","Z","H","S","CX","CZ","MZ","ADD","REMOVE","LABELA","LABELD"]') }}
