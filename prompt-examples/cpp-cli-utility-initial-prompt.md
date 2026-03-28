# Initial Prompt

Goal:
Add a new `cpp/` directory containing a small C++ CLI utility that dispatches to modular examples, where each module demonstrates a specific C++ language feature.

Context:
- Existing repo root; no assumptions about build system (detect or create minimal if absent)
- New structure:
  cpp/
    main.cpp
    modules/
      example_<feature>.cpp
      example_<feature>.h (if needed)
- CLI behavior: `./cpp_demo <module_name>` lists modules if none provided, executes selected module otherwise
- Each module exposes a consistent interface (e.g., `int run()` or similar) and prints a concise demonstration of the feature

Constraints:
- Minimal diff outside `cpp/`
- Add a minimal standalone build (e.g., simple Makefile or CMakeLists scoped to cpp/)
- Keep modules small, isolated, and easily extensible
- Use modern C++ (C++17 or newer) but avoid unnecessary dependencies
- Prefer clear, idiomatic patterns over cleverness
- Ask only if blocked by missing repo-specific facts

Verification:
- Build the CLI (using detected or added build system)
- Run with no args → lists available modules
- Run with a valid module → executes and prints demonstration
- Run with invalid module → prints error and usage
- Summarize files created/modified and provide exact commands to build/run
