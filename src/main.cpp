#include <deque>
#include <iostream>
#include <unistd.h>
#include "parseargs.hpp"
#include "update.hpp"
#include "logger.hpp"
#define VERS "v0.1"

int main(int argc, char *argv[])
{
    if(getuid() != 0){
        throw std::runtime_error("missing superuser permissions");
    }
    log(LogLevel::INFO, "{}", "hi");
    std::deque<std::string> arguments(argv + 1, argv + argc);
    ParseArgs pa;
    pa.addArgument("-u|--update|update", &update::updateRepos);
    pa.parseArgs(arguments);
    return 0;
}
