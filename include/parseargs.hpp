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
    std::variant<Func, bool *> value;
    Arg(std::string names, void (*func)(std::deque<std::string>));
    Arg(std::string names, bool *val);
};
class ParseArgs
{
  public:
    void addArgument(std::string names, Arg::Func);
    void addArgument(std::string names, bool *val);

    void parseArgs(std::deque<std::string> argsin);

  private:
    std::deque<Arg> arguments;
};