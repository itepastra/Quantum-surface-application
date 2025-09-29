# Meeting Notes

## Week 1
### Questions
- Scope of lattice surgery exploration?
- What is meant by novel memory allocation techniques and do we need it?

### Decisions
- Using Godot with gdscript

### Meeting with Sean
- Lattice surgery
    - single, 2-qubit operations, merge and seperation of 2 logical qubits on the grid
    - Using stim will simplify things

- Novem Memory Allocation
    - for a full plane, where do you store all the logical qubits?  
        - how to allocate these qubits so that we can do the least amount of operations, to do the least amount of work for moving around
        - distance 3 and 5 logical qubits, moving them
    - exploration but doesnt need to be a full-fledged thing

- Updates to the problem statement
    - find and cite comparable studies
    - add communcation to the purpose statement
    - Value -- add these:
        - process of simulating surface codes
        - visualizing surface codes
    - Between phase 2-3:
        - how to represent a quantum information, stabilizers, and show what happened
    - For the tutorial phase, figure out how to do the tutorials
    - Add phase for multiple logical qubits after the simulation phase - as well as lattice surgery on multiple qubits and the memory allocation



## Week 2

### Friday meeting notes
#### Entanglement and 2 qubit gates
- Have buttons to add gates and enable/disable them (instead of having them default)
    - Click on qubits to add gates
    - A way to show what you did up to now, order of gates - NEED TO ASK AND CLARIFY
     - time based?
     - QASM?
     - Numbers on top?

#### Getting Stim to work
- Ran into errors when binding with modules
- Next step to try the module on Linux
- If that doesn't work try GDExtension
- If that doesn't work, STIM WASM

#### Divison of tasks
- Created issues on GitHub

## Week 3
### Meeting with Sean
- History:
	- history, timeline slider - step to step - highlighted step 
	- onion layering - previous now next, alpha
	- schedule on the side? with toggle
    - qiskit way?
	
- Bell state, entanglement:
	- top and bottom color for states, half half, for larger states divide it up more
	- with measured state, collapse both colors
	
- ADD Reset qubits

- ADD Measuring qubits:
	- basis measuring 
	- different measures
### Additional Resources:
- An interactive introduction to the surface code: https://arthurpesah.me/blog/2023-05-13-surface-code/

### Questions for Sean for next week:
- NN connectivity? (enforce or not)
- which sim to use

## Week 4

### Friday meeting notes

#### Change to https://arxiv.org/pdf/quant-ph/0406196 instead of STIM

Since we haven't gotten STIM working yet we decided to instead pivot to writing a
Tableau simulator ourselves based on [this paper](https://arxiv.org/pdf/quant-ph/0406196) and
[this code](https://www.scottaaronson.com/chp/chp.c)

#### Time Controls

Works nicely, though play-pause needs to be added still. We decided that it should start
at the current instruction step, and stop once the end is reached.
If the simulation is already at the end however, clicking Play should start from the beginning.

### Questions for Sean for next week:
- Exact dates of holidays


## Week 5

### Meeting Monday

#### Sean

- Holiday: from okt 4 till okt 28 (Japan, so 7 hours ahead)
- Will be watching online on midterm presentations
- Will be present on final presentations

#### Alex

#### Task devision

Adelina:
- start making the midterm presentation

Noa:
- returning a random "valid" qubit state from the superposition
- splitting the state into entangled "groups"

Daglar:
- Modify measure to eliminate the gaussian-elimination step
- help Noa with the returning
