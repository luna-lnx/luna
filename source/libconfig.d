module libconfig;

import toml : parseTOML, TOMLDocument;
import std.file : readText;

extern (C) public struct Config {
    string libc;
    string cc;
    string cxx;
    string cflags;
    string ldflags;
    string mkflags;
}

extern (C) Config parseConfig(string toml) {
    TOMLDocument parsed;

    parsed = parseTOML(toml);

    Config config = Config(
        "libc" in parsed ? parsed["libc"].str : "unknown",
        "cc" in parsed ? parsed["cc"].str : "clang",
        "cxx" in parsed ? parsed["cxx"].str : "clang++",
        "cflags" in parsed ? parsed["cflags"].str : "",
        "ldflags" in parsed ? parsed["ldflags"].str : "",
        "mkflags" in parsed ? parsed["mkflags"].str : ""
    );

    return config;
}

extern (C) Config parseConfigFromFile(string file) {
    return parseConfig(readText(file));
}