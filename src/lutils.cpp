#include "lutils.hpp"
#include <math.h>
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
std::string gradient(std::string input, u_int8_t fro[3], u_int8_t to[3]){
	std::string builder = "";
	for(int i = 0; i < input.length(); ++i){
		// i am not mathing, ty chatgpt
		int r = fro[0] + static_cast<int>(std::round((to[0] - fro[0]) * (i / static_cast<double>(input.length() - 1))));
		int g = fro[1] + static_cast<int>(std::round((to[1] - fro[1]) * (i / static_cast<double>(input.length() - 1))));
		int b = fro[2] + static_cast<int>(std::round((to[2] - fro[2]) * (i / static_cast<double>(input.length() - 1))));
		builder += color(r, g, b) + input[i];
	}
	return builder;
}
std::string colorTerminate(){
	return "\x1b[0m";
}