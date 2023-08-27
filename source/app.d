import std.stdio : writeln;
import std.getopt;

import core.sys.posix.unistd : geteuid;

import update;
import install;
import upgrade;

void main(string[] args)
{
  bool isSu()
  {
    return geteuid() == 0;
  }

  void handler(string cmd)
  {
    switch (cmd)
    {
    case "u|update":
      if (isSu())
      {
        updateRepos(args);
      }
      else
      {
        throw new Exception("luna: must be superuser");
      }
      break;
    case "i|install":
      if (isSu())
      {
        installPackage(args);
      }
      else
      {
        throw new Exception("luna: must be superuser");
      }
      break;
    case "U|upgrade":
      if (isSu())
      {
        upgradeSystem(args);
      }
      else
      {
        throw new Exception("luna: must be superuser");
      }
      break;
    default: // Compiler was complaining
      break;
    }
  }

  auto help = getopt(
    args,
    std.getopt.config.noBundling,
    std.getopt.config.caseSensitive,
    std.getopt.config.stopOnFirstNonOption,
    std.getopt.config.passThrough,
    "i|install", "installs a package", &handler,
    "u|update", "updates repositories", &handler,
    "U|upgrade", "upgrades all packages on the system", &handler,
    "s|search", "searches for a package", &handler,
    "p|packages", "lists installed packages", &handler
  );
  if (help.helpWanted)
    defaultGetoptPrinter("luna - package manager", help.options);
}
