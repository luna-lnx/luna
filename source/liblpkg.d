module liblpkg;

import toml : parseTOML, TOMLDocument;

import std.file : readText;
import std.net.curl : get, download;
import std.algorithm : map;
import std.conv : to;
import std.array : array;
import std.algorithm.searching : find;
import std.logger : sharedLog;
import std.format : format;
import std.string : stripRight;
import std.typecons : Nullable;

import liblrepo;
import main;

public struct LpkgLocation {
    Repo repository;
    string constellation;
}

public struct Lpkg {
    string name;
    string description;
    string tag;

    string tarball;

    string[] dependencies;
    string[] make;
    string[] install;
    string[] uninstall;

    Nullable!LpkgLocation loc;
}

Lpkg parseLpkg(string toml) {
    TOMLDocument parsed;

    parsed = parseTOML(toml);
    Lpkg lpkg = Lpkg(
        parsed["name"].str,
        parsed["description"].str,
        parsed["tag"].str,

        parsed["tarball"].str,

        parsed["dependencies"].array.map!(element => element.str).array,
        parsed["build"].array.map!(element => element.str).array,
        parsed["install"].array.map!(element => element.str).array,
        parsed["uninstall"].array.map!(element => element.str).array
    );
    return lpkg;
}

Lpkg parseLpkgFromFile(string file) {
    return parseLpkg(readText(file));
}

Lpkg parseLpkgFromURL(string url) {
    return parseLpkg(to!string(get(url)));
}

Lpkg parseLpkgFromURLAndSave(string url, string path) {
    download(url, path);
    return parseLpkgFromFile(path);
}

Lpkg[] parseLpkgFromRepo(Repo repo, string name) {
    Lpkg[] foundPackages = [];
    foreach (c; repo.constellations.byKeyValue()) {
        string cname = c.key;
        string[] cval = c.value;
        string[] matchingNames = find(cval, name);
        if (matchingNames != []) {
            Lpkg tmp = parseLpkgFromURL(format("%s/%s/%s.lpkg", stripRight(repo.prefix, "/"), cname, name));
            tmp.loc = LpkgLocation(repo, cname);
            foundPackages ~= tmp;
        }
    }
    return foundPackages;
}
