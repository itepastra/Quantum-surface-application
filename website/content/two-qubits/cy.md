+++
title = "Controlled Y"
weight = 3
+++

A less common variant then the CX and CZ gates,
and you probably already know how it will work from the name.
You can perform it by first doing 3 S gates (what would be 1 $S^\dagger$),
then a CX and finally another S gate.
It doesn't get its own button because it's much less common then both the CX and the CZ gates.

{{ qubitquilt(w=2,h=1,gates='["X","Y","Z","H","S","CX","CZ","MZ"]') }}
