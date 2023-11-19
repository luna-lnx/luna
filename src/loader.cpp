#include "loader.hpp"
#include <atomic>
#include <chrono>
#include <iostream>
#include <stdio.h>
#include <string>
#include <thread>

using namespace std;


void Loader::doLoader()
{
    thread loader(
        [this](atomic<bool> &stopping) {
            const char *icons[4] = {"\\", "|", "/", "-"};
            while (!stopping)
            {
                for (int i = 0; i < 4; ++i)
                {
                    printf("\r%s %s", icons[i], taskName);
                    cout << flush;
                    this_thread::sleep_for(chrono::milliseconds(150));
                }
            }
            printf("\r%s... done!\n", taskName);
            cout << flush;
        },
        ref(stopping));

    task(*this);
    stopping.store(true);
    loader.join();
}

Loader::Loader(char *taskName, void (*task)(Loader &))
{
    this->taskName = taskName;
    this->task = task;
    doLoader();
}