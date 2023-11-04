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
import logger;

extern (C) public struct LpkgLocation {
    Repo repository;
    string constellation;
}

extern (C) public struct Lpkg {
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

extern (C) Lpkg parseLpkg(string toml) {
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

extern (C) Lpkg parseLpkgFromFile(string file) {
    return parseLpkg(readText(file));
}

extern (C) Lpkg parseLpkgFromURL(string url) {
    return parseLpkg(to!string(get(url)));
}

extern (C) Lpkg parseLpkgFromURLAndSave(string url, string path) {
    download(url, path);
    return parseLpkgFromFile(path);
}

extern (C) Lpkg[] parseLpkgFromRepos(Repo[] repos, string name) {
    Lpkg[] foundPackages = [];
    foreach (repo; repos) {
        foundPackages ~= parseLpkgFromRepo(repo, name);
    }
    return foundPackages;
}

extern (C) Lpkg[] parseLpkgFromRepo(Repo repo, string name) {
    Lpkg[] foundPackages = [];
    foreach (c; repo.constellations.byKey()) {
        foundPackages ~= parseLpkgFromRepoAndConstellation(repo, c, name);
    }
    return foundPackages;
}

extern (C) Lpkg[] parseLpkgFromRepoAndConstellation(Repo repo, string constellation, string name) {
    Lpkg[] foundPackages = [];
    string cname = constellation;
    string[] cval = repo.constellations[constellation];
    string[] matchingNames = find(cval, name);
    if (matchingNames != []) {
        Lpkg tmp = parseLpkgFromURL(format("%s/%s/%s/%s.lpkg", stripRight(repo.prefix, "/"), cname, name, name));
        tmp.loc = LpkgLocation(repo, cname);
        foundPackages ~= tmp;
    }
    return foundPackages;
}
