#include <string>
#include <thread>
#include <atomic>
#include <stdio.h>
#include <iostream>
#include <chrono>
#include "loader.hpp"

void Loader::doLoader()
{
    std::thread loader([this](std::atomic<bool>& stopping)
                       {
            const char* icons[4] = {"\\", "|", "/", "-"};
            while(!stopping){
                for(int i = 0; i < 4; ++i){
                    printf("\r%s %s", icons[i], taskName);
                    std::cout << std::flush;
                    std::this_thread::sleep_for(std::chrono::milliseconds(150));
                }
            }
            printf("\r%s... done!\n", taskName);
            std::cout << std::flush; },
                       std::ref(stopping));

    task(*this);
    stopping.store(true);
    loader.join();
}

Loader::Loader(char* taskName, void (*task)(Loader &))
{
    this->taskName = taskName;
    this->task = task;
    doLoader();
}