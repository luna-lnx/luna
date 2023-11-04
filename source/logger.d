module logger;

import std.logger : Logger, LogLevel;
import std.format : format;
import std.stdio : writefln, stderr;
import std.file : mkdirRecurse;
import std.datetime : Clock, SysTime;
import std.file : append, exists;
import std.path : expandTilde, dirName;
import core.stdc.stdlib : exit;
import utils;

// A little bit of help from https://wiki.dlang.org/Logging_mechanisms

public string filename;

extern (C) template log(LogLevel level) {
    extern (C) void log(Args...)(
        Args args,
        string fn = __PRETTY_FUNCTION__,
        string file = __FILE__,
        int line = __LINE__
    ) {
        SysTime timestamp = Clock.currTime();
        if (level <= LogLevel.info) {
            if (filename != "") {
                append(filename, format("%s-%s-%s %s:%s:%s [%s]: %s\n",
                        timestamp.year,
                        timestamp.month,
                        timestamp.day,

                        timestamp.hour,
                        timestamp.minute,
                        timestamp.second,

                        level,

                        args
                ));
            }
            writefln(args);
        } else {
            if (filename != "") {
                append(filename, format("%s-%s-%s %s:%s:%s @ %s:%s():%s [%s]: %s\n",
                        timestamp.year,
                        timestamp.month,
                        timestamp.day,

                        timestamp.hour,
                        timestamp.minute,
                        timestamp.second,

                        file,
                        fn,
                        line,

                        level,

                        args
                ));
            }
            if (level >= LogLevel.critical) {
                stderr.writeln(format("[fatal] %s", args));
                stderr.writeln(
                    "!! a fatal exception occurred - please run 'luna --doctor' before making an issue");
                level > LogLevel.critical ? throw new Exception(format("[fatal] %s", args)) : exit(
                    1);
                exit(1);
            } else {
                stderr.writeln(format("[%s] %s", level, args));
            }
        }
    }
}

extern (C) public alias info = log!(LogLevel.info);
extern (C) public alias warn = log!(LogLevel.warning);
extern (C) public alias error = log!(LogLevel.error);
extern (C) public alias fatal = log!(LogLevel.critical);
extern (C) public alias fatalDebug = log!(LogLevel.fatal);

extern (C) void setFilename(string fn) {
    if (exists(dirName(fn))) {
        filename = fn;
        return;
    }
    logger.error("failed to log to file, run 'luna --doctor' (if you arent already)");
}
