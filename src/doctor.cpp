#include "cpr/cpr.h"
#include "loader.hpp"
#include "logger.hpp"
#include "parseargs.hpp"
#include "lutils.hpp"
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
namespace doctor
{
void runDoctor(std::vector<std::string> args)
{
	ParseArgs pa;
	pa.checkUnrecognized(args);
	privEsc();
	Loader("running doctor", [](Loader &l) {
		int issues = 0;
		if (!std::filesystem::exists("/etc/luna/repos.conf"))
		{
			++issues;
			l.setProgress("getting repos.conf");
			cpr::Response r =
				cpr::Get(cpr::Url{"https://raw.githubusercontent.com/luna-lnx/repo/main/repos.conf.defaults"});
			log(
				r.error.code != cpr::ErrorCode::OK, [&l]() { l.fail(); }, LogLevel::FATAL,
				"failed to get {} because: {}", r.url.str().substr(r.url.str().find_last_of("/") + 1), r.error.message);
			log(
				r.status_code != 200, [&l]() { l.fail(); }, LogLevel::FATAL,
				"failed to get {} because request failed with response code: {}",
				r.url.str().substr(r.url.str().find_last_of("/") + 1), r.status_code);
			std::ofstream reposConfOut("/etc/luna/repos.conf");
			reposConfOut << r.text;
			reposConfOut.close();
		}
		log(issues > 0, LogLevel::INFO, "found {}{}{} issue(s)", color(255, 145, 145) + bold(), issues, colorTerminate());
		log(issues == 0, LogLevel::INFO, "found {}no{} issues (yay)", color(125, 255, 125) + bold(), colorTerminate());
	});
}
} // namespace doctor
  // https://raw.githubusercontent.com/luna-lnx/repo/main/repos.conf.defaults