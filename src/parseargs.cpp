#include "parseargs.hpp"
#include "lutils.hpp"
#include <deque>
#include <string>
#include <optional>
using namespace std;



Arg::Arg(string names, Func func)
{
	this->names = names;
	this->value = func;
}
Arg::Arg(string names, bool* val)
{
	this->names = names;
	this->value = val;
}
void ParseArgs::addArgument(string names, Arg::Func func)
{
	arguments.push_back(Arg(names, func));
}
void ParseArgs::addArgument(string names, bool* val)
{
	arguments.push_back(Arg(names, val));
}
void ParseArgs::parseArgs(deque<string> argsin)
{
	for (int i = 0; i < arguments.size(); ++i)
	{
		deque<string> indivargs = split(arguments.at(i).names, "|");
		for (int j = 0; j < indivargs.size(); ++j)
		{
			if (argsin[0] == indivargs[j])
			{
				argsin.pop_front();
				Arg arg = arguments.at(i);
				if(holds_alternative<Arg::Func>(arg.value)){
					get<Arg::Func>(arg.value)(argsin);
				}else if(holds_alternative<bool*>(arg.value)){
					bool* boolPtr = get<bool*>(arg.value);
					*boolPtr = !(*boolPtr);
				}
				return;
			}
		}
	}
};
