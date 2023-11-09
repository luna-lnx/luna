module install;

import std.format : format;
import std.path : baseName;
import core.thread.osthread : Thread;
import std.net.curl : download;
import archive.targz : TarGzArchive;
import std.file : read, write, exists, mkdirRecurse, dirEntries, SpanMode, isFile, write, copy, PreserveAttributes, setAttributes, remove, rmdirRecurse;
import std.path : dirName, extension, expandTilde;
import std.array : split, replace, join, array;
import std.algorithm.searching : canFind;
import std.algorithm : map, filter;
import std.process : environment, executeShell, Config;
import std.conv : to, octal;
import std.typecons : Yes;
import std.getopt : getopt, config;
import std.string : startsWith;
import std.stdio : stdout, readln;

import main;
import liblpkg;
import liblrepo;
import logger;
import loader;
import utils;
import libdep;

void installPackageFromCommandLine(string[] args, bool shouldPackage) {
    bool pretend = false;
    string destdir = "";
    getopt(
        args,
        "pretend", "pretend to install a package", &pretend,
        "destdir", "destination for installation (e.g. for bootstrapping)", &destdir,
        config.noBundling,
        config.stopOnFirstNonOption,
        config.passThrough
    );
    if (exists(args[1]) && extension(args[1]) == ".lbin" && !shouldPackage) {
        new Loader(format("installing binary package %s", args[1]), (Loader loader) {
            auto archive = new TarGzArchive(read(args[1]));
            string[] entries;
            foreach (file; archive.files) {
                if (pretend) {
                    logger.info(file.path);
                } else {
                    write(destdir ~ file.path, file.data);
                    entries ~= file.path;
                    setAttributes(file.path, octal!755);
                }
            }
            write(format(destdir ~ "/var/lib/luna/installed.d/%s", args[1].split("-")[0]), entries.join("\n"));
        }).showLoader();
        return;
    }
    Lpkg[] packages = parseLpkgFromRepos(parseReposFromDir("/var/lib/luna/repos.conf.d/"), args[1]);
    if (packages.length != 1)
        logger.fatal(format("%s packages with name %s", packages.length == 0 ? "found no" : "found too many", args[1]));
    Lpkg pkg = packages[0];
    //TODO make this actually work
    Lpkg[] ordered;
    new Loader("calculating deps", (Loader loader) {
        ordered = resolveDependencies(pkg);
    }).showLoader();
    logger.info(format("to be installed: \n%s", ordered.map!(lpkg => format("%s::%s", lpkg.name, lpkg
            .tag)).array.join("\n")));
    stdout.write("ok? [y/n] ");
    string input = readln;
    if (input != "y\n" && input != "\n")
        logger.fatal("aborting...");
    foreach (Lpkg key; ordered) {
        // i think my programming license should be revoked
        if (dirEntries(destdir ~ "/var/lib/luna/installed.d/", SpanMode.shallow)
            .map!(entry => baseName(entry.name)).array.canFind(format("%s::%s", key.name, key.tag))) {
            logger.info(format("%s::%s already installed, moving forwards", key.name, key.tag));
            continue;
        } else if (dirEntries(destdir ~ "/var/lib/luna/installed.d/", SpanMode.shallow)
            .map!(entry => baseName(entry.name)).array.canFind(format("%s::", key.name))) {
            logger.info(format("%s already installed, but is out of date. upgrading.", key.name));
            remove(dirEntries(destdir ~ "/var/lib/luna/installed.d/", SpanMode.shallow)
                    .filter!(entry => baseName(entry.name)
                        .startsWith(format("%s::", pkg.name))).array[0]);
        }
        logger.info(format("installing %s", key.name));
        installPackage(key, shouldPackage, pretend, destdir);
    }
    logger.info("done!");
}

void installPackage(Lpkg pkg, bool shouldPackage, bool pretend, string destDir) {
    destDir = expandTilde(destDir);
    logger.info(format("%s %s/%s::%s", pretend ? "pretending to install" : "installing", pkg.loc.get.constellation, pkg
            .name, pkg
            .tag));
    string url = format(pkg.tarball, pkg.tag);
    string srcDir;
    new Loader(format("downloading %s", baseName(url)), (Loader loader) {
        download(url, format("/usr/src/luna/%s", baseName(url)));
    }).showLoader();
    new Loader(format("extracting %s", baseName(url)), (Loader loader) {
        auto archive = new TarGzArchive(read(format("/usr/src/luna/%s", baseName(url))));
        foreach (file; archive.files) {
            loader.setMessage(format("extracting %s (%s)", baseName(url), baseName(file.path)));
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
            setAttributes(fullName, octal!755);
        }
    }).showLoader();
    new Loader(format("compiling %s", pkg.name), (Loader loader) {
        foreach (command; pkg.make) {
            string formattedCmd = command;
            formattedCmd = formattedCmd.replace("$MKFLAGS", main.cfg.mkflags);
            formattedCmd = formattedCmd.replace("$CC", format("\"%s\"", main.cfg.cc));
            formattedCmd = formattedCmd.replace("$CXX", format("\"%s\"", main.cfg.cxx));
            formattedCmd = formattedCmd.replace("$CFLAGS", format("\"%s\"", format("%s %s", main.cfg.cflags, destDir != "" ? format(
                "--sysroot=%s", destDir) : "")));
            formattedCmd = formattedCmd.replace("$LDFLAGS", format("\"%s\"", main.cfg.ldflags));
            formattedCmd = command.replace("$DEST", destDir);
            loader.setMessage(format("compiling %s (%s)", pkg.name, formattedCmd));
            auto res = executeShell(formattedCmd, null, Config.none, size_t.max, format("/usr/src/luna/%s", srcDir));
            if (res[0] != 0) {
                logger.fatal(format("\ncompile task '%s' failed with error code %s because of:\n%s", command, res[0], res[1]));
            }
        }
    }).showLoader();
    new Loader(format("%s %s", shouldPackage ? "packaging" : "installing", pkg.name), (
            Loader loader) {
        string cacheDir;
        if (array(pkg.install.filter!(s => (canFind(s, "$DEST")))).length == 0)
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
                    if (exists(entry) && entry.isFile) {
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
                    if (exists(entry) && entry.isFile) {
                        if (pretend) {
                            logger.info(entry);
                        } else {
                            mkdirRecurse(destDir ~ dirName(entry.replace(cacheDir, "")));
                            entry.copy(destDir ~ entry.replace(cacheDir, ""), Yes
                                .preserveAttributes);
                            entries ~= entry.replace(cacheDir, "");
                        }
                    }
                }
                if (!pretend)
                    write(format(destDir ~ "/var/lib/luna/installed.d/%s::%s", pkg.name, pkg.tag), entries.join(
                        "\n"));
            }
        } else {
            logger.fatalDebug("this really shouldn't be happening. where is the cachedir?");
        }
    }).showLoader();
    new Loader("cleaning up", (Loader loader) {
        remove("/usr/src/luna/" ~ baseName(format(pkg.tarball, pkg.tag)));
        rmdirRecurse("/tmp/luna/installcache/" ~ pkg.name);
    }).showLoader();
}
