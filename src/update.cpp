#include "cpr/cpr.h"
#include "loader.hpp"
#include "logger.hpp"
#include "lutils.hpp"
#include <chrono>
#include <deque>
#include <fstream>
#include <iostream>
#include <string>
#include <thread>

namespace update
{
void updateRepos(std::deque<std::string> args)
{
    Loader ld("updating repos", [](Loader &l) {
        std::ifstream reposListFile("/etc/luna/repos.conf");
        if (reposListFile.is_open())
        {
            std::string tmp;
            reposListFile >> tmp;
            std::deque<std::string> reposList = splitstr(tmp, "\n");
            for (int i = 0; i < reposList.size(); ++i)
            {
                l.setProgress(format("{}/{}", i + 1, reposList.size()));
                cpr::Response r = cpr::Get(cpr::Url{reposList.at(i)});
                std::ofstream repoOut(
                    format("/var/lib/luna/repos.d/{}", r.url.str().substr(r.url.str().find_last_of("/") + 1)));
                if (repoOut.is_open())
                {
                    repoOut << r.text;
                    repoOut.close();
                }
                else
                {
                    log(LogLevel::FATAL, "repoOut not open");
                }
            }
        }
        else
        {
            log(LogLevel::FATAL, "reposListFile not open");
        }
        reposListFile.close();
    });
}
} // namespace update
