import std.getopt;

import std.stdio : writefln, stderr;
import std.format : format;
import std.datetime : Clock;
import std.file : append;
import core.sys.posix.unistd : geteuid;
import std.path : expandTilde;
import std.file : mkdirRecurse;
import std.getopt : getopt, config, defaultGetoptPrinter;

import liblpkg;
import liblrepo;

import update;
import logger;
import utils;

immutable string _version = "v0.01";

void main(string[] args) {
    void handler(string cmd) {
        switch (cmd) {
            case "u|update":
                updateRepos(args);
                break;
            default:
                break;
        }
    }

    if (isSu) {
        logger.setFilename("/var/log/luna/" ~ format("%s.log", Clock.currTime()
                .toUnixTime()));
    } else {
        logger.setFilename(expandTilde("~/.local/state/luna/") ~ format(
                "%s.log", Clock.currTime()
                .toUnixTime()));
        logger.warn(
            "missing superuser permissions, writing logs in ~/.local/state/luna/ instead.");
    }
    logger.info("luna - " ~ _version);

    auto opt = getopt(
        args,
        "u|update", "updates the package repositories", &handler,
        "s|search", "searches for a package", &handler
    );
    if (opt.helpWanted) {
        defaultGetoptPrinter("lunapm - luna linux package manager - " ~ _version, opt.options);
        return;
    }
}
