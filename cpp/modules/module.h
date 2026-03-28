#ifndef CPP_MODULES_MODULE_H
#define CPP_MODULES_MODULE_H

#include <string_view>

namespace demo {

struct Module {
    std::string_view name;
    std::string_view description;
    int (*run)();
};

}  // namespace demo

#endif
