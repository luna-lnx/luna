#pragma once

#include <atomic>
#include <string>
class Loader
{
  public:
	Loader(std::string taskName, void (*task)(Loader &));
	void setProgress(std::string progress);
	void fail();

  private:
	std::string taskName;
	std::string progress = "";
	void (*task)(Loader &);
	std::atomic<bool> stopping = false;
	std::atomic<bool> failing = false;
	void doLoader();
};