#include "example_lambda_capture.h"

#include <iostream>
#include <vector>

namespace demo {
namespace {

int run_lambda_capture() {
    int running_total = 0;
    const std::vector<int> values{3, 5, 8};

    const auto add_to_total = [&running_total](int value) {
        running_total += value;
        std::cout << "Added " << value << ", total is now " << running_total << '\n';
    };

    for (int value : values) {
        add_to_total(value);
    }

    std::cout << "Lambda captured running_total by reference.\n";
    return 0;
}

}  // namespace

const Module& example_lambda_capture_module() {
    static const Module module{
        "lambda_capture",
        "Demonstrate a lambda updating external state by reference.",
        &run_lambda_capture,
    };
    return module;
}

}  // namespace demo
