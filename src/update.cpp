#include "cpr/cpr.h"
#include "loader.hpp"
#include "logger.hpp"
#include "lutils.hpp"
#include "parseargs.hpp"
#include <chrono>
#include <deque>
#include <fstream>
#include <iostream>
#include <string>
#include <thread>

namespace update
{
void updateRepos(std::vector<std::string> args)
{
	ParseArgs pa;
	pa.checkUnrecognized(args);
	privEsc();
	Loader ld("updating repos", [](Loader &l) {
		std::ifstream reposListFile("/etc/luna/repos.conf");
		if (reposListFile.is_open())
		{
			std::stringstream buffer;
			buffer << reposListFile.rdbuf();
			std::string tmp = trim(buffer.str());
			std::vector<std::string> reposList = splitstr(tmp, "\n");
			for (int i = 0; i < reposList.size(); ++i)
			{
				l.setProgress(format("{}/{}", i + 1, reposList.size()));
				cpr::Response r = cpr::Get(cpr::Url{reposList.at(i)});
				log(
					r.error.code != cpr::ErrorCode::OK, [&l]() { l.fail(); }, LogLevel::FATAL,
					"failed to get {} because: {}", r.url.str().substr(r.url.str().find_last_of("/") + 1),
					r.error.message);
				log(
					r.status_code != 200, [&l]() { l.fail(); }, LogLevel::FATAL,
					"failed to get {} because request failed with response code: {}",
					r.url.str().substr(r.url.str().find_last_of("/") + 1), r.status_code);
				std::ofstream repoOut(
					format("/var/lib/luna/repos.d/{}", r.url.str().substr(r.url.str().find_last_of("/") + 1)));
				if (repoOut.is_open())
				{
					repoOut << r.text;
					repoOut.close();
				}
				else
				{
					log([&l]() { l.fail(); }, LogLevel::FATAL, "repoOut not open");
				}
			}
		}
		else
		{
			log([&l]() { l.fail(); }, LogLevel::FATAL, "reposListFile not open");
		}
		reposListFile.close();
	});
}
} // namespace update
