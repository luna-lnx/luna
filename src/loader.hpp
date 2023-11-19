#pragma once

#include <atomic>

class Loader
{
  public:
    Loader(char *taskName, void (*task)(Loader &));

  private:
    char *taskName;
    void (*task)(Loader &);
    std::atomic<bool> stopping = false;
    void doLoader();
};