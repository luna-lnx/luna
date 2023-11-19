#include <string>
#include <vector>
#include <chrono>
#include <thread>
#include "loader.hpp"
namespace update
{
    void updateRepos(std::vector<std::string> args){
        Loader ld("updating repos", [](Loader& l){
            std::this_thread::sleep_for(std::chrono::milliseconds(1024));
        });
    }
}
