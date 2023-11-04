module liblrepo;

import liblpkg;
import toml : parseTOML, TOMLDocument, TOMLValue;
import std.file : readText, dirEntries, SpanMode;
import std.net.curl : get, download;
import std.algorithm : map;
import std.conv : to;
import std.array : array;

extern (C) private alias Constellations = string[][string];

extern (C) public struct Repo {
    string prefix;
    Constellations constellations;
}

extern (C) Repo parseRepo(string toml) {
    TOMLDocument parsed;

    parsed = parseTOML(toml);
    Constellations constellations;
    foreach (TOMLValue constellation; parsed["constellations"].table.keys) {
        constellations[constellation.str] = parsed["constellations"].table[constellation.str].array.map!(x => x.str)
            .array;
    }
    Repo repo = Repo(
        parsed["prefix"].str,
        constellations
    );
    return repo;
}

extern (C) Repo parseRepoFromFile(string file) {
    return parseRepo(readText(file));
}

extern (C) Repo parseRepoFromURL(string url) {
    return parseRepo(to!string(get(url)));
}

extern (C) Repo parseRepoFromURLAndSave(string url, string path) {
    download(url, path);
    return parseRepoFromFile(path);
}

extern (C) Repo[] parseReposFromDir(string path) {
    Repo[] res = [];
    foreach (string name; dirEntries(path, SpanMode.breadth)) {
        res ~= parseRepoFromFile(name);
    }
    return res;
}
