# Problem Statement

## Purpose of the Study

Explaining Quantum Error Correction codes to others is difficult,
both to people not knowlegable of quantum computing and collegues in the lab.

## Value Proposition

We will help solve the communication barrier by creating a visual and interactive aid.
It should be intuitive enough for the general public while also allowing enough expressivity
for researchers.

## Sustainability goals

Simulating general quantum computers on classical hardware is very energy intensive, 
this is of course not sustainable.
Therefore we will focus on the pauli subset of states which is much more efficient to simulate.
To make our system scalable the client's device will be running the simulation, this also
puts a soft limit on how much computation we can reasonably do.

## Requirements

- Have a visual grid with interactive qubits
    - Be able to add/remove qubits from the lattice including defects
    - Be able to change the state of qubits
    - Be able to add X and Z stabilizers
    - Dynamically create logical qubits
- Be able to display and interact with this grid on a website
- Be able to calculate the hamming distance of the logical qubits
- Simulate errors occuring and let the user see the result to understand the error
    - Show syndome measurement in an intuitive manner
- Add a tutorial mechanism (all visual/interactive first)
    - Explain controls
    - Explain what a qubit can be
    - Explain what a stabilizer does
    - Show a surface code with stabilizers
    - Explain syndome decoding
- The simulation needs to run on the client
- Have a toggle to see "what is going on underneath"

## Design Questions

- How can we display an entangled quantum state?
- How to simulate a surface code in a way that's fast yet accurate enough?
    - Look into STIM to see how they do it

## Deliverables

- A website that can display and simulate surface codes with or without defects
    - The website needs to be interactive to encourage exploration and learning by doing
- A report describing how we created the website, and why we did or didn't make certain decisions

