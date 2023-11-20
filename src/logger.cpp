#include <string>
#include <deque>
#include <iostream>
#include "logger.hpp"
#include "lutils.hpp"


template <typename... Args>
void log(LogLevel lv, std::string fmt, Args... args){
    std::deque<std::string> argDeque{std::to_string(args)...};
    std::deque<std::string> sp = split(fmt, "{}");
    std::string formatted = "";
    for(int i = 0; i < sp.size(); ++i){
        formatted += sp.at(i) + argDeque.at(i) + sp.at(i + 1);
    }
    std::cout << formatted;
}
