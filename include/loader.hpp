#pragma once

#include <atomic>
#include <string>
class Loader
{
  public:
    Loader(std::string taskName, void (*task)(Loader &));
    void setProgress(std::string progress);

  private:
    std::string taskName;
    std::string progress = "";
    void (*task)(Loader &);
    std::atomic<bool> stopping = false;
    void doLoader();
};