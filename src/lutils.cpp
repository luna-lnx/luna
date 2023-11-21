#include "lutils.hpp"

std::deque<std::string> splitstr(std::string in, std::string del)
{
	std::deque<std::string> out;
	size_t pos = 0;
	while ((pos = in.find(del)) != std::string::npos)
	{
		out.push_front(in.substr(0, pos));
		in.erase(0, pos + del.length());
	}
	out.push_front(in);
	return out;
}
std::string color(u_int8_t r, u_int8_t g, u_int8_t b){
	return "\x1b[38;2;" + std::to_string(r) + ";" + std::to_string(g) + ";" + std::to_string(b) + "m";
}
std::string colorBg(u_int8_t r, u_int8_t g, u_int8_t b){
	return "\x1b[48;2;" + std::to_string(r) + ";" + std::to_string(g) + ";" + std::to_string(b) + "m";
}
std::string bold(){
	return "\x1b[1m";
}
std::string colorTerminate(){
	return "\x1b[0m";
}