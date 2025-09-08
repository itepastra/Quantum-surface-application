# Problem Statement

## Reason for the Problem Choice
Quantum Error Correction (QEC) is essential for building reliable quantum computers, as it protects fragile quantum information from noise and decoherence. However, QEC concepts, such as stabilizer codes, surface codes, and logical qubits, are abstract and mathematically complex. Most existing resources are either highly technical or lack interactivity, making it difficult for students, researchers and professionals to intuitively grasp how QEC works. An interactive quantum surface application focusing on QEC would make these concepts accessible and engaging.

## Purpose of the Study

The goal is to develop an interactive application that visualizes quantum surfaces. This app will help those not knowledgeable of quantum computing to understand and learn QEC, while also providing lab colleagues with a simulated environment to explore and analyze QEC processes.

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

## Project Plan - in progress
Over the 9-week duration of the MDP course, our plan foresees the following phases:

**Phase 1: Research & Requirements (weeks 1-2)**
- Milestones: 
Understand user needs and define functional requirements
Review QEC literature, including papers suggested by the challenge provider and other relevant sources

**Phase 2: Visual grid (weeks ...-...)**
- Milestone: 
Implement the core interactive grid and basic qubit manipulations
           
**Phase 3: Logical qubits**
- Milestone: 
Enable creation of logical qubits and calculation of their properties

**Phase 4: Error simulation**
- Milestone: 
Show QEC in action and make error processes intuitive
                
**Phase 5: Tutorial & Educational Layer**
- Milestone: 
Having interactive tutorials integrated with the grid that provide user-friendly explanations of QEC

**Phase 6: Web Integration & Client-Side Simulation**
- Milestone: 
Deploy the fully-functional web application for real-time interactive use

To stay in touch, we plan to meet in person twice a week and hold online discussions when needed to review and consult on the code each of us has worked on in the meantime.

