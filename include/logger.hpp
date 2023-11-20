#pragma once
#include <string>
#include <deque>
#include <iostream>
#include "logger.hpp"
#include "lutils.hpp"

enum LogLevel
{
    DEBUG,
    INFO,
    WARN,
    ERR,
    FATAL
};

template <typename... Args>
void log(LogLevel lv, std::string fmt, Args... args){
    std::deque<std::string> argDeque{args...};
    std::deque<std::string> sp = split(fmt, "{}");
    std::string formatted = "";
    for(int i = 0; i < sp.size()-1; ++i){
        formatted += sp.at(i) + sstr(argDeque.at(i));
    }
    std::cout << formatted;
}
