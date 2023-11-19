#include "loader.hpp"
#include <chrono>
#include <deque>
#include <string>
#include <thread>

using namespace std;

namespace update
{
void updateRepos(deque<string> args)
{
    Loader ld("updating repos", [](Loader &l) { this_thread::sleep_for(chrono::milliseconds(1024)); });
}
} // namespace update
