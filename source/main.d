import std.getopt;

import std.stdio : writefln, stderr;
import std.format : format;
import std.datetime : Clock;
import std.file : append;
import core.sys.posix.unistd : geteuid;
import std.path : expandTilde;
import std.file : mkdirRecurse;
import std.getopt : getopt, config, defaultGetoptPrinter;
import std.file : FileException;
import liblpkg;
import liblrepo;

import update;
import doctor;
import install;
import remove;
import logger;
import utils;

immutable string _version = "v0.01";

void main(string[] args) {
    if (!isSu) {
        logger.fatal("must be run as root");
    }
    void handler(string cmd) {
        switch (cmd) {
            case "u|update":
                updateRepos(args);
                break;
            case "d|doctor":
                runDoctor();
                break;
            case "i|install":
                installPackage(args);
                break;
            case "r|remove":
                removePackage(args);
                break;
            default:
                logger.fatal("how did we get here?");
        }
    }

    logger.setFilename("/var/log/luna/" ~ format("%s.log", Clock.currTime()
            .toUnixTime()));
    logger.info("luna - " ~ _version);

    auto opt = getopt(
        args,
        "u|update", "updates the package repositories", &handler,
        "i|install", "installs a package", &handler,
        "d|doctor", "fixes any potential issues", &handler,
        "r|remove", "removes a package", &handler,
        config.noBundling,
        config.stopOnFirstNonOption,
        config.passThrough
    );
    if (opt.helpWanted) {
        defaultGetoptPrinter("lunapm - luna linux package manager - " ~ _version, opt.options);
        return;
    }
}
