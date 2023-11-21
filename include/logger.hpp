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
    std::string fmt_target = "{}";
	std::deque<std::string> argDeque{args...};
    size_t found = fmt.find("{}");
    int index = 0;
	while(found != std::string::npos){
        fmt = fmt.replace(found, fmt_target.length(), argDeque.at(index));
        found = fmt.find("{}");
        ++index;
    }
    std::string pretty = "";
    switch(lv){
        case WARN:
            pretty += colorBg(235, 80, 80) + "warn" + colorTerminate();
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
    if(pretty != ""){
        pretty = "[" + pretty + "] ";
    }
    pretty = pretty + fmt;
	std::printf(pretty.c_str());
    std::cout << std::endl;
    if(lv == LogLevel::FATAL){
        throw std::runtime_error("a fatal exception has occurred. if you believe that this is not user error, run luna --doctor before making an issue.");
    }
}
