# Problem Statement



## Purpose of the Study

The goal of the project is to make communicating about Quantum Error Correction Codes
easier between researchers and their peers. It should also strive to teach the public
about these codes in an intuitive sense.

## Value Proposition

We will help solve the communication barrier by creating a visual and interactive aid.
It should be intuitive enough for the public using the tutorials to learn
while also allowing enough expressivity for researchers to explore the topic.

## Sustainability goals

Simulating general quantum computers on classical hardware is very energy intensive, 
this is of course not sustainable.
Therefore we will focus on the pauli subset of states which is much more efficient to simulate.
To make our system scalable the client's device will be running the simulation, this also puts a soft limit on how much computation we can reasonably do.

## Requirements

- Have a visual grid with interactive qubits
    - Be able to add/remove qubits from the lattice as defects
    - Be able to change the state of qubits
    - Be able to add X and Z stabilizers
    - Dynamically create logical qubits
    - Being able to do lattice surgery by merging and splitting logical qubits
- Be able to display and interact with this grid on a website
- Simulate errors occuring and let the user see the result to understand the error
    - Show syndome measurement in an intuitive manner
- Add a tutorial mechanism (all visual/interactive first)
    - Explain controls
    - Explain what a qubit can be
    - Explain what a stabilizer does
    - Show a surface code with stabilizers
    - Explain syndome decoding
- The simulation needs to run on the client
    - The server should only have to serve static files
- Have a toggle to show the state of all the qubits or only the ancillas
- Allow moving logical qubits to experiment with novel memory allocation techniques

### Additions

- Be able to calculate the hamming distance of the logical qubits
- Add Y stabilizers as well (and a mechanism to switch between the stabilizers)
- Different connectivies
    - Hexagonal (3 neighbors)
    - Triangular (6 neighbors)
- Disabling a connection between 2 working qubits

### Out of Scope

- 3D codes
- States outside of the pauli set

## Design Questions

- How can we display an entangled quantum state?
    - Rotate the whole group together between the valid states,
      at the same unique frequency?
    - Squiggly lines between the qubits?
- How to simulate a surface code in a way that's fast yet accurate enough?
    - Look into STIM to see how they do it
    - Explore complexity vs performance tradeoff, what is sufficient (good enough)

## Deliverables

- A website that can display and simulate surface codes with or without defects
    - The website needs to be interactive to encourage exploration and learning by doing
- A report describing how we created the website, and why we did or didn't make certain decisions

