#include "parseargs.hpp"
#include "lutils.hpp"
#include <deque>
#include <string>
#include <optional>

Arg::Arg(std::string names, Func func)
{
	this->names = names;
	this->value = func;
}
Arg::Arg(std::string names, bool* val)
{
	this->names = names;
	this->value = val;
}
void ParseArgs::addArgument(std::string names, Arg::Func func)
{
	arguments.push_back(Arg(names, func));
}
void ParseArgs::addArgument(std::string names, bool* val)
{
	arguments.push_back(Arg(names, val));
}
void ParseArgs::parseArgs(std::deque<std::string> argsin)
{
	for (int i = 0; i < arguments.size(); ++i)
	{
		std::deque<std::string> indivargs = splitstr(arguments.at(i).names, "|");
		for (int j = 0; j < indivargs.size(); ++j)
		{
			if (argsin[0] == indivargs[j])
			{
				argsin.pop_front();
				Arg arg = arguments.at(i);
				if(std::holds_alternative<Arg::Func>(arg.value)){
					std::get<Arg::Func>(arg.value)(argsin);
				}else if(std::holds_alternative<bool*>(arg.value)){
					bool* boolPtr = std::get<bool*>(arg.value);
					*boolPtr = !(*boolPtr);
				}
				return;
			}
		}
	}
};
