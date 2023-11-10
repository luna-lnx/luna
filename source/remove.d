module remove;

import std.file : readText, dirEntries, SpanMode, remove, exists;
import std.path : baseName;
import std.array : split;
import std.format : format;
import std.string : startsWith;
import logger;
import loader;

void removePackage(string[] args) {
    foreach (entry; dirEntries("/var/lib/luna/installed.d/", SpanMode.depth)) {
        if (baseName(entry).startsWith(args[1] ~ "::")) {
            new Loader(format("removing package %s", args[1]), (Loader loader) {
                foreach (line; readText(entry).split("\n")) {
                    if(exists(line))
                        remove(line);
                }
            }).showLoader();
            remove(entry);
            return;
        }
    }
    logger.fatal(format("package %s not found", args[1]));
}
