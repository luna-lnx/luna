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
    std::variant<Func, bool *> value;
    Arg(std::string names, std::string desc, void (*func)(std::vector<std::string>));
    Arg(std::string names, std::string desc, bool *val);
};
class ParseArgs
{
  public:
    void addArgument(std::string names, std::string desc, Arg::Func);
    void addArgument(std::string names, std::string desc, bool *val);

    void parseArgs(std::vector<std::string> argsin);

  private:
    std::vector<Arg> arguments;
};