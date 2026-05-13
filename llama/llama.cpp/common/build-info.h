#pragma once

inline int llama_build_number(void) { return 0; }
inline const char * llama_commit(void) { return "unknown"; }
inline const char * llama_compiler(void) { return "unknown"; }
inline const char * llama_build_target(void) { return "unknown"; }
inline const char * llama_build_info(void) { return "unknown"; }
inline void llama_print_build_info(void) {}
