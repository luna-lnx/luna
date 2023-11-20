#include "loader.hpp"
#include <chrono>
#include <deque>
#include <string>
#include <thread>

namespace update
{
void updateRepos(std::deque<std::string> args)
{
    Loader ld("updating repos", [](Loader &l) { std::this_thread::sleep_for(std::chrono::milliseconds(1024)); });
}
} // namespace update
