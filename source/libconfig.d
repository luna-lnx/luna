module libconfig;

import toml : parseTOML, TOMLDocument;
import std.file : readText;

extern (C) public struct Config {
    string libc;
}

extern (C) Config parseConfig(string toml) {
    TOMLDocument parsed;

    parsed = parseTOML(toml);

    Config config = Config(
        "libc" in parsed ? parsed["libc"].str : "unknown"
    );

    return config;
}

extern (C) Config parseConfigFromFile(string file) {
    return parseConfig(readText(file));
}