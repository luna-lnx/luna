import std.getopt;

import std.stdio : writefln, stderr;
import std.format : format;
import std.logger : Logger, LogLevel, sharedLog;
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

    bool isSu() {
        return geteuid() == 0;
    }

    getLogger.warning(
            "missing superuser permissions, writing logs in ~/.local/state/luna/ instead.");

    getLogger.info("luna - " ~ _version);

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
