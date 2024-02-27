#include "logger.hpp"
#include <parseargs.hpp>
#include <string>
#include <vector>

namespace install
{
void installPackage(std::vector<std::string> args)
{
	ParseArgs pa;
	std::string packagename;
	pa.addArgument("-i|--install|install|-S", "installs a package", &packagename);
	pa.setFlags(ParseArgs::CHECK_UNRECOGNIZED);
	pa.parseArgs(args);
	privEsc();
}
void install(std::string name)
{
}
} // namespace install
