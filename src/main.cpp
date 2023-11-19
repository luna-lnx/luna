#include <iostream>
#define VERS "v0.1"

#include "spdlog/spdlog.h"

int main() {
    spdlog::info("luna {}", VERS);
    return 0;
}
