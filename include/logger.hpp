#pragma once
#include "lutils.hpp"
#include <deque>
#include <iostream>
#include <string>

enum LogLevel
{
    DEBUG,
    INFO,
    WARN,
    ERR,
    FATAL
};

template <typename... Args> void log(LogLevel lv, std::string fmt, Args... args)
{
    std::string formatted = format(fmt, args...);
    std::string pretty = "";
    switch (lv)
    {
    case WARN:
        pretty += color(235, 80, 80) + "warn" + colorTerminate();
        break;
    case ERR:
        pretty += color(255, 0, 0) + "error" + colorTerminate();
        break;
    case FATAL:
        pretty += color(255, 255, 255) + colorBg(235, 80, 80) + bold() + "fatal" + colorTerminate();
        break;
    default:
        break;
    }
    if (pretty != "")
    {
        pretty = "[" + pretty + "] ";
    }
    pretty = pretty + formatted;
    std::cout << pretty.c_str() << std::endl;

    if (lv == LogLevel::FATAL)
    {
        throw std::runtime_error("a fatal exception has occurred. if you believe that this is not user error, run luna "
                                 "--doctor before making an issue.");
    }
}
