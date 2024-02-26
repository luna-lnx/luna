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
	int flags;
	std::variant<Func, bool *, std::string *> value;
	Arg(std::string names, std::string desc, void (*func)(std::vector<std::string>), int flags);
	Arg(std::string names, std::string desc, bool *val, int flags);
	Arg(std::string names, std::string desc, std::string *val, int flags);
	enum flags
	{
		KEEP_ON_MATCH = 1
	};
};
class ParseArgs
{
  public:
	void addArgument(std::string names, std::string desc, Arg::Func, int flags = 0);
	void addArgument(std::string names, std::string desc, bool *val, int flags = 0);
	void addArgument(std::string names, std::string desc, std::string *val, int flags = 0);
	int hasArgument(std::string arg);
	void checkUnrecognized(std::vector<std::string> argsin);
	bool parseArgs(std::vector<std::string> argsin);
	void setFlags(int flags);
	enum flags
	{
		CHECK_UNRECOGNIZED = 1,
		STOP_ON_MATCH = 2
	};

  private:
	std::vector<Arg> arguments;
	int flags = 0;
};