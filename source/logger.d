module logger;

import std.logger : Logger, LogLevel;
import std.format : format;
import std.stdio : writefln, stderr;
import std.file : mkdirRecurse;
import std.datetime : Clock, SysTime;
import std.file : append;
import std.path : expandTilde;

import utils;

/*
Here for reference.
TODO: remove
class Logger_ : Logger {
    string filename;
    this(LogLevel lv, string dirname, string filename) @safe {
        mkdirRecurse(dirname);
        this.filename = dirname ~ filename;
        super(lv);
    }

    // HACK
    void logToStderrln(string fmt) @trusted {
        stderr.writefln(fmt);
    }

    override void writeLogMsg(ref LogEntry payload) {
        auto timestamp = payload.timestamp;
        // ref: https://github.com/dlang/phobos/blob/a3f22129dd2a134338ca02b79ff0de242d7f016e/std/logger/core.d#L491
        if (payload.logLevel <= 64) {
            writefln(payload.msg);
            append(this.filename, format("%s-%s-%s %s:%s:%s [%s]: %s\n",
                    timestamp.year,
                    timestamp.month,
                    timestamp.day,

                    timestamp.hour,
                    timestamp.minute,
                    timestamp.second,

                    payload.logLevel,

                    payload.msg
            ));
        } else {
            logToStderrln(format("[%s] %s", payload.logLevel, payload.msg));
            append(this.filename, format("%s-%s-%s %s:%s:%s @ %s:%s():%s [%s]: %s\n",
                    timestamp.year,
                    timestamp.month,
                    timestamp.day,

                    timestamp.hour,
                    timestamp.minute,
                    timestamp.second,

                    payload.file,
                    payload.funcName,
                    payload.line,

                    payload.logLevel,

                    payload.msg
            ));
        }
    }
}
*/
// A little bit of help from https://wiki.dlang.org/Logging_mechanisms

public string filename;

template log(LogLevel level) {
    void log(Args...)(
        Args args,
        string fn = __PRETTY_FUNCTION__,
        string file = __FILE__,
        int line = __LINE__
    ) {
        SysTime timestamp = Clock.currTime();
        if (level <= 64) {
            writefln(args);
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
        } else {
            stderr.writeln(format("[%s] %s", level, args));
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
        }
    }
}

public alias info = log!(LogLevel.info);
public alias warn = log!(LogLevel.warning);
public alias error = log!(LogLevel.error);
public alias fatal = log!(LogLevel.fatal);

void setFilename(string fn){
    filename = fn;
}

/*extern(C) public Logger_ logger;

extern(C) Logger_ getLogger() {
    if (!is(typeof(logger))) {
        if (isSu) {
            logger = new Logger_(LogLevel.all, "/var/log/luna/", format("%s.log", Clock.currTime()
                    .toUnixTime()));
        } else {
            logger = new Logger_(LogLevel.all, expandTilde("~/.local/state/luna/"), format(
                    "%s.log", Clock.currTime()
                    .toUnixTime()));
            logger.warning(
                "missing superuser permissions, writing logs in ~/.local/state/luna/ instead.");
        }
    }
    return logger;
}*/
