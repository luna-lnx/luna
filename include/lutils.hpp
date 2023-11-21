#pragma once

#include <deque>
#include <sstream>
#include <string>

std::deque<std::string> splitstr(std::string in, std::string del);
std::string color(u_int8_t r, u_int8_t g, u_int8_t b);
std::string colorBg(u_int8_t r, u_int8_t g, u_int8_t b);
std::string gradient(std::string input, u_int8_t fro[3], u_int8_t to[3], bool bg);
std::string bold();
std::string colorTerminate();
// what does this do again lmao
template <typename T> std::string sstr(const T &val)
{
	std::ostringstream sstr;
	// fold expression
	(sstr << std::dec << val);
	return sstr.str();
}
