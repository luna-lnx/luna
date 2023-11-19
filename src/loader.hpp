#pragma once

#include <atomic>

class Loader
{
  private:
    char *taskName;
    void (*task)(Loader &);
    std::atomic<bool> stopping = false;
    void doLoader();

  public:
    Loader(char *taskName, void (*task)(Loader &));
};