#include "cpr/cpr.h"
#include "loader.hpp"
#include "logger.hpp"
#include <filesystem>
#include <iostream>
namespace doctor
{
void runDoctor(std::deque<std::string> args)
{
	if (!std::filesystem::exists("/etc/luna/repos.conf"))
	{
		Loader("getting repos.conf", [](Loader &l) {
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
		});
	}
}
} // namespace doctor
  // https://raw.githubusercontent.com/luna-lnx/repo/main/repos.conf.defaults