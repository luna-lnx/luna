#include "loader.hpp"
#include "lutils.hpp"
#include "logger.hpp"
#include <chrono>
#include <deque>
#include <string>
#include <thread>
#include <iostream>
#include <fstream>

namespace update
{
void updateRepos(std::deque<std::string> args)
{
    Loader ld("updating repos", [](Loader &l) {
        std::ifstream reposListFile("/etc/luna/repos.conf");
        if(reposListFile.is_open()){
            std::string tmp;
            reposListFile >> tmp;
            std::deque<std::string> reposList = splitstr(tmp, "\n");
            for(int i = 0; i < reposList.size(); ++i){
                
            }
        }else{
            log(LogLevel::FATAL, "reposListFile not open");
        }
    });
}
} // namespace update
