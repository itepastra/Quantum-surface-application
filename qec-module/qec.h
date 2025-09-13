#ifndef GODOT_QEC_H
#define GODOT_QEC_H

#include "core/object/ref_counted.h"

class QEC : public RefCounted {
	GDCLASS(QEC, RefCounted);

protected:
	static void _bind_methods();

public:
    
    String get_demo_circuit();
};

#endif // GODOT_QEC_H