#pragma once
#include <deque>
#include <string>
class Arg
{
  public:
    std::string names;
    void (*func)(std::deque<std::string>);
    Arg(std::string names, void (*func)(std::deque<std::string>));
};
class ParseArgs
{
  private:
    std::deque<Arg> arguments;

  public:
    ParseArgs &addArgument(std::string names, void (*func)(std::deque<std::string>));

    void parseArgs(std::deque<std::string> argsin);
};