module doctor;

import std.file : exists, mkdirRecurse;
import std.path : expandTilde;
import std.net.curl : download;
import std.format : format;
import logger;

void runDoctor() {
    int problems = 0;
    immutable string[] dirs = [
        "/var/log/luna/", "/var/lib/luna/repos.conf.d/", "/etc/luna"
    ];
    foreach (dir; dirs) {
        if (!exists(dir)) {
            ++problems;
            logger.info(format("creating %s", expandTilde(dir)));
            mkdirRecurse(expandTilde(dir));
        }

    }
    if (!exists("/etc/luna/repos.conf")) {
        ++problems;
        logger.info("downloading default repos.conf");
        download("https://raw.githubusercontent.com/luna-lnx/repo/main/repos.conf.defaults", "/etc/luna/repos.conf");
    }
    info(format("doctor: fixed %s issues", problems));
}
