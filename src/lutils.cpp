#include <deque>
#include <string>

std::deque<std::string> split(std::string in, std::string del)
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