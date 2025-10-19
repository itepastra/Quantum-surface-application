+++
title = "Controlled Z"
weight = 2
+++

The controlled Z/PHASE gate applies a 180 degree rotation around the blue axis on the target
when the control is yellow, it also does nothing when the control is blue.

{{ qubitquilt(w=2,h=1,gates='["X","Y","Z","H","S","CZ","MZ"]') }}

It isn't clear which side is the control and which side is the target, this is due to
it not mattering at all, the effect on the combined system is the same both ways.
