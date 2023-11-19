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
	std::thread loader(
		[this](std::atomic<bool> &stopping) {
			const char *icons[4] = {"\\", "|", "/", "-"};
			while (!stopping)
			{
				for (int i = 0; i < 4; ++i)
				{
					std::cout << "\r" << icons[i] << " " << taskName << std::flush;
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

Loader::Loader(char *taskName, void (*task)(Loader &))
{
	this->taskName = taskName;
	this->task = task;
	doLoader();
}