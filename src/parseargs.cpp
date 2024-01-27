#include "parseargs.hpp"
#include "logger.hpp"
#include "lutils.hpp"
#include <deque>
#include <optional>
#include <string>

Arg::Arg(std::string names, std::string desc, Func func)
{
	this->names = names;
	this->desc = desc;
	this->value = func;
}
Arg::Arg(std::string names, std::string desc, bool *val)
{
	this->names = names;
	this->desc = desc;
	this->value = val;
}
Arg::Arg(std::string names, std::string desc, std::string *val)
{
	this->names = names;
	this->desc = desc;
	this->value = val;
}
void ParseArgs::addArgument(std::string names, std::string desc, Arg::Func func)
{
	arguments.push_back(Arg(names, desc, func));
}
void ParseArgs::addArgument(std::string names, std::string desc, bool *val)
{
	arguments.push_back(Arg(names, desc, val));
}
void ParseArgs::addArgument(std::string names, std::string desc, std::string *val)
{
	arguments.push_back(Arg(names, desc, val));
}
bool ParseArgs::hasArgument(std::string arg)
{
	for (int i = 0; i < arguments.size(); ++i)
	{
		std::vector<std::string> indivargs = splitstr(arguments.at(i).names, "|");
		if (std::find(indivargs.begin(), indivargs.end(), arg) != indivargs.end())
		{
			return true;
		}
	}
	return false;
}
void ParseArgs::checkUnrecognized(std::vector<std::string> argsin)
{
	for (int i = 0; i < argsin.size(); ++i)
	{
		if (!hasArgument(argsin.at(i)))
		{
			log(LogLevel::FATAL, "unrecognized argument {}", argsin.at(i));
		}
	}
}
bool ParseArgs::parseArgs(std::vector<std::string> argsin)
{
	bool matched = false;
	for (int i = 0; i < arguments.size(); ++i)
	{
		Arg arg = arguments.at(i);
		if (argsin[0] == "-h")
		{
			std::vector<std::string> namessplit = splitstr(arg.names, "|");
			namessplit.back() = "or " + namessplit.back();
			log(LogLevel::INFO, "{}     {}", joinstr(namessplit, ", "), arguments.at(i).desc);
		}
		std::vector<std::string> indivargs = splitstr(arguments.at(i).names, "|");
		for (int j = 0; j < indivargs.size(); ++j)
		{
			if (argsin[0] == indivargs[j])
			{
				argsin.erase(argsin.begin());
				if (std::holds_alternative<Arg::Func>(arg.value))
				{
					std::get<Arg::Func>(arg.value)(argsin);
				}
				else if (std::holds_alternative<bool *>(arg.value))
				{
					bool *boolPtr = std::get<bool *>(arg.value);
					*boolPtr = !(*boolPtr);
				}
				else if (std::holds_alternative<std::string *>(arg.value))
				{
					std::string *stringPtr = std::get<std::string *>(arg.value);
					stringPtr->assign(argsin[0]);
					argsin.erase(argsin.begin());
					// stringPtr->assign("mrrow");
				}
				matched = true;
				break;
			}
		}
	}
	if (matched)
		return true;
	return false;
};
