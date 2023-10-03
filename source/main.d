import std.getopt;

import std.stdio : writefln;
import std.format : format;
import std.logger;
import std.datetime : Clock;
import std.file : append;

import liblpkg;
import librepo;

// I would advise keeping this closed.
// If you have naming suggestions, please make an issue.
// TODO: Move to a seperate file.
class WhatDoINameThisLogger : Logger
{
    string filename;
    this(LogLevel lv, string filename) @safe
    {
        this.filename = filename;
        super(lv);
    }

    override void writeLogMsg(ref LogEntry payload)
    {
        writefln(payload.msg);
        auto timestamp = payload.timestamp;
        if (payload.logLevel < 4)
        {
            append(this.filename, format("\n%s-%s-%s %s:%s:%s [%s]: %s",
                    timestamp.year,
                    timestamp.month,
                    timestamp.day,

                    timestamp.hour,
                    timestamp.minute,
                    timestamp.second,

                    payload.logLevel,
                    payload.msg
            ));
        }
        else
        {
            append(this.filename, format("\n%s-%s-%s %s:%s:%s @ %s:%s():%s [%s]: %s",
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

WhatDoINameThisLogger logger;

void main(string[] args)
{
    logger = new WhatDoINameThisLogger(LogLevel.all, "test.log");
    locatePackage();
}
