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
	std::deque<std::string> argDeque{args...};
	std::deque<std::string> sp = splitstr(fmt, "{}");
	std::string formatted = "";
	for (int i = 0; i < sp.size() - 1; ++i)
	{
		formatted += sp.at(i) + sstr(argDeque.at(i));
	}
    std::string pretty = "";
    switch(lv){
        case WARN:
            pretty += "warn";
            break;
        case ERR:
            pretty += "error";
            break;
        case FATAL:
            pretty += color(255, 255, 255) + colorBg(235, 80, 80) + "fatal" + colorTerminate();
            break;
        default:
            break;
    }
    if(pretty != ""){
        pretty = "[" + pretty + "] ";
    }
    pretty = pretty + formatted;
	std::printf(pretty.c_str());
    std::cout << std::endl;
    if(lv == LogLevel::FATAL){
        throw std::runtime_error("a fatal exception has occurred. if you believe that this is not user error, run luna --doctor before making an issue.");
    }
}
