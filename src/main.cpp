#include "doctor.hpp"
#include "logger.hpp"
#include "lutils.hpp"
#include "parseargs.hpp"
#include "update.hpp"
#include <deque>
#include <iostream>
#include <unistd.h>
#define VERS "v0.1"

int main(int argc, char *argv[])
{
	std::vector<std::string> arguments(argv + 1, argv + argc);
	if (getuid() != 0)
	{
		log(LogLevel::WARN, "missing permissions. attempting to rerun as root...");
		system(format("su -c \"{} {}\"", argv[0], joinstr(arguments, " ")).c_str());
		exit(0);
	}
	log(LogLevel::INFO, "luna - {}", VERS);
	ParseArgs pa;
	pa.addArgument("-u|--update|update", "updates the repos", &update::updateRepos);
	pa.addArgument("-d|--doctor|doctor", "performs a lunapm health check", &doctor::runDoctor);
	pa.parseArgs(arguments);
	return 0;
}
