#include "example_structured_bindings.h"

#include <iostream>
#include <map>
#include <string>

namespace demo {
namespace {

int run_structured_bindings() {
    const std::map<std::string, int> scores{
        {"compiler", 98},
        {"tests", 95},
    };

    for (const auto& [name, score] : scores) {
        std::cout << name << " => " << score << '\n';
    }

    std::cout << "Structured bindings unpack each map entry into named variables.\n";
    return 0;
}

}  // namespace

const Module& example_structured_bindings_module() {
    static const Module module{
        "structured_bindings",
        "Demonstrate unpacking map entries with structured bindings.",
        &run_structured_bindings,
    };
    return module;
}

}  // namespace demo
