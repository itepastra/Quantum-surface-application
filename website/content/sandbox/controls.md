+++
title = "Controls"
weight = 1
+++

The application contains a grid of qubits, which are the orbs you see. 
They're simulated by a graph state simulation.  
This grid can be moved around in a few ways:
- Dragging around with the mouse/touch
- Zooming in and out by scrolling
- Panning using the arrow keys or the WASD keys

On the bottom of the window there are buttons which you can use to select a
gate kind of like a "tool". After selecting one of these gates you can then click
on any of the qubits to apply the gate to it, this will happen instantly and the qubit
will start rotating towards the state after the gate, this is a purely visual effect and
the qubit will be simulated as being in the new state instantly. the number keys can be used
to select these operations as well, hovering a button shows a tooltip of what it does and
which button is the shortcut.

The left of the window contains a macro button, with a couple of default macros.
Clicking the macro button will start recording a new macro, any operations that you
do after starting the recording will be added to the macro. Clicking the macro button
again after this will stop the recording and save the macro. The macro can then be re-applied
by selecting it and clicking any qubit in the grid. The execution will be relative to the first qubit
a gate was applied on during the recording. Particles will show what qubits will be affected
by the macro if you hover over a qubit with the macro selected.

On the top of the screen is the time-control bar, for this bar it's important to know about the
history queue. All operations you apply to the grid, including all simulated errors and entangled states
are recorded such that you can move through the program to see how it acts under different errors.
An important thing to note is that applying any operation using a macro or the bottom buttons will
delete all the "future" operations in the queue.
the five buttons are:
- Go back to the beginning: undo all operations to get back to the start state
- Go back one step: undo the most recent operation, can be triggered with Ctrl-Z as well
- Play/Pause: start/stop automatically applying the gates in the queue at a rate of 1 operation per second. This will automatically stop after the end is reached.
- Go forward one step: redo the next operation in the queue
- Go forward to the end: redo all the operations in the queue

At the top right there are two tabs that can be opened and closed.
Clicking the tab saying QASM will open the history queue where you can see what has happened
and will happen in very simple QASM code. It is editable, but the simulation does not keep track of it.

The other tab, called ErrorPanel contains controls for changing rates of various errors that
could happen on the qubits. Each error type can be enabled/have their probability controlled
independently. The errors will have the probability to happen on every qubit operation executed.
