#include <algorithm>
#include <iostream>
#include <string_view>
#include <vector>

#include "modules/example_lambda_capture.h"
#include "modules/example_optional.h"
#include "modules/example_structured_bindings.h"
#include "modules/module.h"

namespace {

std::vector<const demo::Module*> all_modules() {
    return {
        &demo::example_lambda_capture_module(),
        &demo::example_optional_module(),
        &demo::example_structured_bindings_module(),
    };
}

void print_usage(std::string_view program_name,
                 const std::vector<const demo::Module*>& modules) {
    std::cout << "Usage: " << program_name << " <module_name>\n";
    std::cout << "Available modules:\n";

    for (const demo::Module* module : modules) {
        std::cout << "  " << module->name << " - " << module->description << '\n';
    }
}

}  // namespace

int main(int argc, char* argv[]) {
    const std::vector<const demo::Module*> modules = all_modules();

    if (argc < 2) {
        print_usage(argv[0], modules);
        return 0;
    }

    const std::string_view requested_module = argv[1];
    const auto match = std::find_if(
        modules.begin(), modules.end(), [requested_module](const demo::Module* module) {
            return module->name == requested_module;
        });

    if (match == modules.end()) {
        std::cerr << "Unknown module: " << requested_module << "\n\n";
        print_usage(argv[0], modules);
        return 1;
    }

    return (*match)->run();
}
