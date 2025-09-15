#include "qec.h"

#include <stim>

String QEC::get_demo_circuit() {
  stim::Circuit c("H 0\nCNOT 0 1\nM 0 1\n");
  std::string text = c.str();
  return String(text.c_str());
}

void QEC::_bind_methods() {
  ClassDB::bind_method(D_METHOD("get_demo_circuit"), &QEC::get_demo_circuit);
}
