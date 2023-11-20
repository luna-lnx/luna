#pragma once
#include <string>

enum LogLevel
{
    DEBUG,
    INFO,
    WARN,
    ERR,
    FATAL
};
template <typename... Args> void log(LogLevel lv, std::string fmt, Args... args);
