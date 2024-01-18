#include "logger.hpp"
#include "lutils.hpp"
#include "parseargs.hpp"
#include "update.hpp"
#include "doctor.hpp"
#include <deque>
#include <iostream>
#include <unistd.h>
#define VERS "v0.1"

int main(int argc, char *argv[])
{
	std::vector<std::string> arguments(argv, argv + argc);
	if (getuid() != 0)
	{
		log(LogLevel::WARN, "missing permissions. attempting to rerun as root...");
		system(format("su -c \"{} {}\"", arguments[0], joinstr(arguments, " ")).c_str());
		exit(0);
	}
	arguments.erase(arguments.begin());
	log(LogLevel::INFO, "luna - {}", VERS);
	ParseArgs pa;
	pa.addArgument("-u|--update|update", "updates the repos", &update::updateRepos);
	pa.addArgument("-d|--doctor|doctor", "performs a lunapm health check", &doctor::runDoctor);
	pa.parseArgs(arguments);
	return 0;
}
