module install;

import std.format : format;

import liblpkg;
import liblrepo;
import logger;

void installPackage(string[] args) {
    Lpkg[] packages = parseLpkgFromRepos(parseReposFromDir("/var/lib/luna/repos.conf.d/"), args[1]);
    if (packages.length != 1)
        logger.fatal(format("%s packages with name %s", packages.length == 0 ? "found no" : "found too many", args[1]));
    Lpkg pkg = packages[0];
    //TODO make this actually work
    logger.info("calculating deps...");
    logger.info(format("installing %s/%s::%s", pkg.loc.get.constellation, pkg.name, pkg
            .tag));
}
