#include "spdlog/sinks/rotating_file_sink.h"
#include "spdlog/sinks/stdout_color_sinks.h"
#include "spdlog/spdlog.h"
#include <deque>
#include <iostream>

#include "parseargs.hpp"
#include "update.hpp"
#define VERS "v0.1"

using namespace std;

void initLogger()
{
    // totally not stolen from https://github.com/gabime/spdlog/issues/290
    vector<spdlog::sink_ptr> sinks;
    sinks.push_back(make_shared<spdlog::sinks::rotating_file_sink_mt>("/var/log/luna/log.txt", INT32_MAX, 3));
    sinks.push_back(make_shared<spdlog::sinks::stdout_color_sink_mt>());
    spdlog::register_logger(make_shared<spdlog::logger>("default", begin(sinks), end(sinks)));
    spdlog::register_logger(make_shared<spdlog::logger>("error", begin(sinks), end(sinks)));
    spdlog::get("default")->set_pattern("%v");
}

int main(int argc, char *argv[])
{
    initLogger();
    spdlog::get("default")->info("luna {}", VERS);
    deque<string> arguments(argv + 1, argv + argc);
    ParseArgs pa;
    pa.addArgument("-u|--update|update", &update::updateRepos);
    pa.parseArgs(arguments);
    return 0;
}
