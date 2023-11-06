module install;

import std.format : format;
import std.path : baseName;
import core.thread.osthread : Thread;
import std.net.curl : download;
import archive.targz : TarGzArchive;
import std.file : read, write, exists, mkdirRecurse, dirEntries, SpanMode, isFile, write, copy, PreserveAttributes;
import std.path : dirName;
import std.array : split, replace, join;
import std.algorithm.searching : canFind;
import std.algorithm : map;
import std.process : environment, executeShell, Config;
import std.conv : to;
import std.typecons : Yes;

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
            string[] splitPath = file.path.split("/");
            if (canFind(splitPath[0], pkg.name) && !srcDir && splitPath.length > 1)
                srcDir = file.path.split("/")[0];
            string fullName = "/usr/src/luna/" ~ file.path;
            string parentDir = dirName(fullName);
            if (!exists(parentDir)) {
                mkdirRecurse(parentDir);
            }
            write(fullName, file.data);
        }
    }).showLoader();
    new Loader(format("compiling %s", pkg.name), {
        foreach (command; pkg.make) {
            auto res = executeShell(command, null, Config.none, size_t.max, format("/usr/src/luna/%s", srcDir));
            if (res[0] != 0) {
                logger.fatal(format("compile task '%s' failed with error code %s because of:\n%s", command, res[0], res[1]));
            }
        }
    }).showLoader();
    new Loader(format("installing %s", pkg.name), {
        string cacheDir;
        foreach (command; pkg.install) {
            string formattedName;
            if (canFind(command, "$DEST")) {
                cacheDir = format("/tmp/luna/installcache/%s", pkg.name);
                mkdirRecurse(cacheDir);
                formattedName = command.replace("$DEST", cacheDir);
            }
            auto res = executeShell(formattedName ? formattedName : command, null, Config.none, size_t.max, format(
                "/usr/src/luna/%s", srcDir));
            if (res[0] != 0) {
                logger.fatal(format("install task '%s' failed with error code %s because of:\n%s", command, res[0], res[1]));
            }
        }
        if (cacheDir && exists(cacheDir)) {
            string[] entries = [];
            foreach (entry; dirEntries(cacheDir, SpanMode.depth)) {
                if (isFile(entry)) {
                    entry.copy(entry.replace(cacheDir, ""), Yes.preserveAttributes);
                    entries ~= entry.replace(cacheDir, "");
                }
            }
            write(format("/var/lib/luna/installed.d/%s", pkg.name), entries.join("\n"));
        }
    }).showLoader();
}
