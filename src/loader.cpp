#include "loader.hpp"
#include "lutils.hpp"
#include <atomic>
#include <chrono>
#include <iostream>
#include <stdio.h>
#include <string>
#include <thread>

void Loader::doLoader()
{
    std::thread loader(
        [this](std::atomic<bool> &stopping) {
            const char *icons[4] = {"\\", "|", "/", "-"};
            while (!stopping)
            {
                for (int i = 0; i < 4; ++i)
                {
                    std::cout << "\r" << icons[i] << " " << taskName
                              << format(" {}", this->progress != "" ? format("({})", this->progress) : "")
                              << std::flush;
                    std::this_thread::sleep_for(std::chrono::milliseconds(150));
                }
            }
            std::cout << "\r" << taskName << "... done!" << std::flush << std::endl;
        },
        std::ref(stopping));

    task(*this);
    stopping.store(true);
    loader.join();
}

void Loader::setProgress(std::string progress)
{
    this->progress = progress;
}

Loader::Loader(std::string taskName, void (*task)(Loader &))
{
    this->taskName = taskName;
    this->task = task;
    doLoader();
}