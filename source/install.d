module install;

import std.format : format;
import std.path : baseName;
import core.thread.osthread : Thread;
import std.net.curl : download;
import archive.targz : TarGzArchive;
import std.file : read, write, exists, mkdirRecurse, dirEntries, SpanMode, isFile, write, copy, PreserveAttributes, setAttributes;
import std.path : dirName, extension;
import std.array : split, replace, join, array;
import std.algorithm.searching : canFind;
import std.algorithm : map, filter;
import std.process : environment, executeShell, Config;
import std.conv : to, octal;
import std.typecons : Yes;

import main;
import liblpkg;
import liblrepo;
import logger;
import loader;
import utils;

void installPackage(string[] args, bool shouldPackage) {
    if (exists(args[1]) && extension(args[1]) == ".lbin" && !shouldPackage) {
        new Loader(format("installing binary package %s", args[1]), (ref Loader loader) {
            auto archive = new TarGzArchive(read(args[1]));
            string[] entries;
            foreach (file; archive.files) {
                write(file.path, file.data);
                entries ~= file.path;
            }
            foreach (entry; entries) {
                setAttributes(entry, octal!755);
            }
            write(format("/var/lib/luna/installed.d/%s", args[1].split("-")[0]), entries.join("\n"));
        }).showLoader();
        return;
    }
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
    new Loader(format("downloading %s", baseName(url)), (ref Loader loader) {
        download(url, format("/usr/src/luna/%s", baseName(url)));
    }).showLoader();
    new Loader(format("extracting %s", baseName(url)), (ref Loader loader) {
        auto archive = new TarGzArchive(read(format("/usr/src/luna/%s", baseName(url))));
        foreach (file; archive.files) {
            loader.setMessage(format("extracting %s (%s)", pkg.name, baseName(file.path)));
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
    new Loader(format("compiling %s", pkg.name), (ref Loader loader) {
        foreach (command; pkg.make) {
            string formattedCmd = command;
            formattedCmd = formattedCmd.replace("$MKFLAGS", main.cfg.mkflags);
            formattedCmd = formattedCmd.replace("$CC", format("\"%s\"", main.cfg.cc));
            formattedCmd = formattedCmd.replace("$CXX", format("\"%s\"", main.cfg.cxx));
            formattedCmd = formattedCmd.replace("$CFLAGS", format("\"%s\"", main.cfg.cflags));
            formattedCmd = formattedCmd.replace("$LDFLAGS", format("\"%s\"", main.cfg.ldflags));
            loader.setMessage(format("compiling %s (%s)", pkg.name, formattedCmd));
            auto res = executeShell(formattedCmd, null, Config.none, size_t.max, format("/usr/src/luna/%s", srcDir));
            if (res[0] != 0) {
                logger.fatal(format("\ncompile task '%s' failed with error code %s because of:\n%s", command, res[0], res[1]));
            }
        }
    }).showLoader();
    new Loader(format("%s %s", shouldPackage ? "packaging" : "installing", pkg.name), (
            ref Loader loader) {
        string cacheDir;
        if(array(pkg.install.filter!(s => (canFind(s, "$DEST")))).length == 0)
            logger.error("$DEST not found, stopping to prevent un-uninstallable packages");
        foreach (command; pkg.install) {
            string formattedCmd = command;
            if (canFind(command, "$DEST")) {
                cacheDir = format("/tmp/luna/installcache/%s", pkg.name);
                mkdirRecurse(cacheDir);
                formattedCmd = command.replace("$DEST", cacheDir);
            }
            loader.setMessage(format("installing %s (%s)", pkg.name, formattedCmd));
            auto res = executeShell(formattedCmd, null, Config.none, size_t.max, format(
                "/usr/src/luna/%s", srcDir));
            if (res[0] != 0) {
                logger.fatal(format("\ninstall task '%s' failed with error code %s because of:\n%s", command, res[0], res[1]));
            }
        }
        if (cacheDir && exists(cacheDir)) {
            if (shouldPackage) {
                loader.setMessage(format("packaging %s", pkg.name));
                auto arch = new TarGzArchive();
                foreach (entry; dirEntries(cacheDir, SpanMode.depth)) {
                    if (isFile(entry)) {
                        auto file = new TarGzArchive.File(entry.replace(cacheDir, ""));
                        file.data = cast(immutable ubyte[]) read(entry);
                        arch.addFile(file);
                    }
                }
                write(format("%s-%s_%s.lbin", pkg.name, pkg.tag, main.cfg.libc), cast(ubyte[]) arch.serialize());
            } else {
                loader.setMessage(format("installing %s (copying files)", pkg.name));
                string[] entries = [];
                foreach (entry; dirEntries(cacheDir, SpanMode.depth)) {
                    if (isFile(entry)) {
                        entry.copy(entry.replace(cacheDir, ""), Yes.preserveAttributes);
                        entries ~= entry.replace(cacheDir, "");
                    }
                }
                write(format("/var/lib/luna/installed.d/%s", pkg.name), entries.join("\n"));
            }
        } else {
            logger.fatalDebug("this really shouldn't be happening. where is the cachedir?");
        }
    }).showLoader();
}
