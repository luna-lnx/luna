#include <iostream>
#include "spdlog/spdlog.h"
#include "spdlog/sinks/rotating_file_sink.h"
#include "spdlog/sinks/stdout_color_sinks.h"

#include "update.hpp"

#define VERS "v0.1"

void initLogger()
{
    // totally not stolen from https://github.com/gabime/spdlog/issues/290
    std::vector<spdlog::sink_ptr> sinks;
    sinks.push_back(std::make_shared<spdlog::sinks::rotating_file_sink_mt>("/var/log/luna/log.txt", INT32_MAX, 3));
    sinks.push_back(std::make_shared<spdlog::sinks::stdout_color_sink_mt>());
    spdlog::register_logger(std::make_shared<spdlog::logger>("default", begin(sinks), end(sinks)));
}

int main(int argc, char* argv[])
{
    initLogger();
    spdlog::get("default")->info("luna {}", VERS);
    std::vector<std::string> arguments(argv + 1, argv + argc);
    update::updateRepos(arguments);
    return 0;
}
