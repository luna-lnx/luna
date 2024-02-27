#pragma once

#include <string>
#include <vector>

class Lpkg
{
  private:
	std::string name;
	std::string desc;
	std::string vers;
	std::string source;

	std::vector<std::string> dependencies;
	std::vector<std::string> build;
	std::vector<std::string> install;

  public:
	std::string getName()
	{
		return this->name;
	}

	void setName(std::string name)
	{
		this->name = name;
	}

	std::string getDesc()
	{
		return this->desc;
	}

	void setDesc(std::string desc)
	{
		this->desc = desc;
	}

	std::string getVers()
	{
		return this->vers;
	}

	void setVers(std::string vers)
	{
		this->vers = vers;
	}

	std::string getSource()
	{
		return this->source;
	}

	void setSource(std::string source)
	{
		this->source = source;
	}

	std::vector<std::string> getDependencies()
	{
		return this->dependencies;
	}

	void setDependencies(std::vector<std::string> dependencies)
	{
		this->dependencies = dependencies;
	}

	std::vector<std::string> getBuild()
	{
		return this->build;
	}

	void setBuild(std::vector<std::string> build)
	{
		this->build = build;
	}

	std::vector<std::string> getInstall()
	{
		return this->install;
	}

	void setInstall(std::vector<std::string> install)
	{
		this->install = install;
	}
};
namespace liblpkg
{
Lpkg parse_lpkg(std::string script);
Lpkg parse_lpkg_from_file(std::string path);
} // namespace liblpkg