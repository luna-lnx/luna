#pragma once
#include <deque>
#include <functional>
#include <string>
#include <variant>
class Arg
{
  public:
    using Func = void (*)(std::vector<std::string>);
    std::string names;
    std::string desc;
    std::variant<Func, bool *, std::string *> value;
    Arg(std::string names, std::string desc, void (*func)(std::vector<std::string>));
    Arg(std::string names, std::string desc, bool *val);
    Arg(std::string names, std::string desc, std::string *val);
};
class ParseArgs
{
  public:
    void addArgument(std::string names, std::string desc, Arg::Func);
    void addArgument(std::string names, std::string desc, bool *val);
    void addArgument(std::string names, std::string desc, std::string *val);
    int hasArgument(std::string arg);
    void checkUnrecognized(std::vector<std::string> argsin);
    bool parseArgs(std::vector<std::string> argsin);

  private:
    std::vector<Arg> arguments;
};