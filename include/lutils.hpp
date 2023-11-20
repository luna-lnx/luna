#pragma once

#include <deque>
#include <sstream>
#include <string>

std::deque<std::string> splitstr(std::string in, std::string del);

template <typename T> std::string sstr(const T &val)
{
    std::ostringstream sstr;
    // fold expression
    (sstr << std::dec << val);
    return sstr.str();
}
