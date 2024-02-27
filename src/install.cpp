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

/*i am blanking rn
idek how i should do this
ima organize my thoughts here for the time being:
first and foremost, what format should the package be in?
bash would be optimal but it'd also be weird to parse to variables for dependency resolution (unless there's a library
for that, i'll look)
*/