#pragma once
#include <deque>
#include <functional>
#include <string>
#include <variant>
class Arg
{
  public:
    using Func = void (*)(std::deque<std::string>);
    std::string names;
    std::string desc;
    std::variant<Func, bool *> value;
    Arg(std::string names, std::string desc, void (*func)(std::deque<std::string>));
    Arg(std::string names, std::string desc, bool *val);
};
class ParseArgs
{
  public:
    void addArgument(std::string names, std::string desc, Arg::Func);
    void addArgument(std::string names, std::string desc, bool *val);

    void parseArgs(std::deque<std::string> argsin);

  private:
    std::deque<Arg> arguments;
};