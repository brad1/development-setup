#include "example_optional.h"

#include <iostream>
#include <optional>
#include <string>

namespace demo {
namespace {

std::optional<int> parse_port(const std::string& text) {
    if (text.empty()) {
        return std::nullopt;
    }

    return std::stoi(text);
}

int run_optional() {
    const std::optional<int> configured_port = parse_port("8080");
    const std::optional<int> missing_port = parse_port("");

    if (configured_port) {
        std::cout << "Configured port: " << *configured_port << '\n';
    }

    std::cout << "Fallback port: " << missing_port.value_or(3000) << '\n';
    std::cout << "std::optional makes absence explicit.\n";
    return 0;
}

}  // namespace

const Module& example_optional_module() {
    static const Module module{
        "optional",
        "Demonstrate std::optional for values that may be absent.",
        &run_optional,
    };
    return module;
}

}  // namespace demo
