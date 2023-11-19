#include "parseargs.hpp";
#include "lutils.hpp";
#include <deque>
#include <string>

using namespace std;

Arg::Arg(string names, void (*func)(deque<string>))
{
    this->names = names;
    this->func = func;
};

void ParseArgs::addArgument(string names, void (*func)(deque<string>))
{
    arguments.push_back(Arg(names, func));
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
                arguments.at(i).func(argsin);
                return;
            }
        }
    }
};
