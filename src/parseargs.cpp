#include "parseargs.hpp";
#include "lutils.hpp";
#include <deque>
#include <string>

Arg::Arg(std::string names, void (*func)(std::deque<std::string>))
{
    this->names = names;
    this->func = func;
};

void ParseArgs::addArgument(std::string names, void (*func)(std::deque<std::string>))
{
    arguments.push_back(Arg(names, func));
}

void ParseArgs::parseArgs(std::deque<std::string> argsin)
{
    for (int i = 0; i < arguments.size(); ++i)
    {
        std::deque<std::string> indivargs = split(arguments.at(i).names, "|");
        for (int j = 0; j < indivargs.size(); ++j)
        {
            if (argsin[0] == indivargs[j])
            {
                argsin.pop_front();
                arguments.at(i).func(argsin);
                return;
            }
        }
    }
};
