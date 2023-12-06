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
void ParseArgs::addArgument(std::string names, std::string desc, Arg::Func func)
{
    arguments.push_back(Arg(names, desc, func));
}
void ParseArgs::addArgument(std::string names, std::string desc, bool *val)
{
    arguments.push_back(Arg(names, desc, val));
}
void ParseArgs::parseArgs(std::deque<std::string> argsin)
{
    for (int i = 0; i < arguments.size(); ++i)
    {
        Arg arg = arguments.at(i);
        if (argsin[0] == "-h")
        {
            std::deque<std::string> namessplit = splitstr(arg.names, "|");
            namessplit.back() = "or " + namessplit.back();
            log(LogLevel::INFO, "{}     {}", joinstr(namessplit, ", "), arguments.at(i).desc);
        }
        std::deque<std::string> indivargs = splitstr(arguments.at(i).names, "|");
        for (int j = 0; j < indivargs.size(); ++j)
        {
            if (argsin[0] == indivargs[j])
            {
                argsin.pop_front();
                if (std::holds_alternative<Arg::Func>(arg.value))
                {
                    std::get<Arg::Func>(arg.value)(argsin);
                }
                else if (std::holds_alternative<bool *>(arg.value))
                {
                    bool *boolPtr = std::get<bool *>(arg.value);
                    *boolPtr = !(*boolPtr);
                }
                return;
            }
        }
    }
};
