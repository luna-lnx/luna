module install;

import std.format : format;
import std.path : baseName;
import core.thread.osthread : Thread;
import std.net.curl : download;
import archive.targz : TarGzArchive;
import std.file : read, write, exists, mkdirRecurse;
import std.path : dirName;
import std.array : split;
import std.algorithm.searching : canFind;

import liblpkg;
import liblrepo;
import logger;
import loader;

void installPackage(string[] args) {
    Lpkg[] packages = parseLpkgFromRepos(parseReposFromDir("/var/lib/luna/repos.conf.d/"), args[1]);
    if (packages.length != 1)
        logger.fatal(format("%s packages with name %s", packages.length == 0 ? "found no" : "found too many", args[1]));
    Lpkg pkg = packages[0];
    //TODO make this actually work
    logger.info("calculating deps...");

    logger.info(format("installing %s/%s::%s", pkg.loc.get.constellation, pkg.name, pkg
            .tag));
    string url = format(pkg.tarball, pkg.tag);
    string srcDir;
    new Loader(format("downloading %s", baseName(url)), {
        download(url, format("/usr/src/luna/%s", baseName(url)));
    }).showLoader();
    new Loader(format("extracting %s", baseName(url)), {
        auto archive = new TarGzArchive(read(format("/usr/src/luna/%s", baseName(url))));
        foreach (file; archive.files) {
            // TODO: make this more reliable. just a best effort to get things working
            if (canFind(file.path.split("/")[0], pkg.name) && !srcDir)
                srcDir = file.path.split("/")[0];
            string fullName = "/usr/src/luna/" ~ file.path;
            string parentDir = dirName(fullName);
            if (!exists(parentDir)) {
                mkdirRecurse(parentDir);
            }
            write(fullName, file.data);
        }
    }).showLoader();
    new Loader(format("installing %s", pkg.name), {});
}
