module liblrepo;

import liblpkg;
import toml : parseTOML, TOMLDocument;
import std.file : readText;
import std.net.curl : get, download;
import std.algorithm : map;
import std.conv : to;
import std.array : array;

private alias Constellations = string[][string];

public struct Repo{
    string prefix;
    Constellations constellations;
}
Repo parseRepo(string toml){
    TOMLDocument parsed;

    parsed = parseTOML(toml);
    Constellations constellations;
    for(string key; parsed["constellations"].table.keys;){
        constellations[key] = parsed["constellations"].array.map!(element => element.str).array;
    }
    Repo repo = Repo(
        parsed["prefix"].str,
        constellations
    );
    return repo;
}
Repo parseRepoFromFile(string file){
    return parseRepo(readText(file));
}
Repo parseRepoFromURL(string url){
    return parseRepo(to!string(get(url)));
}
Repo parseRepoFromURLAndSave(string url, string path){
    download(url, path);
    return parseRepoFromFile(path);
}