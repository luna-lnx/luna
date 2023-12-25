#include "loader.hpp"
#include "cpr/cpr.h"
#include <filesystem>
namespace doctor
{
    void runDoctor(){
        if(!std::filesystem::exists("/etc/luna/repos.conf")){
            Loader("getting repos.conf", [](Loader &l){
                cpr::Response r = cpr::Get(cpr::Url{"https://raw.githubusercontent.com/luna-lnx/repo/main/repos.conf.defaults"});
            });
        }
    }
} // namespace doctor
// https://raw.githubusercontent.com/luna-lnx/repo/main/repos.conf.defaults