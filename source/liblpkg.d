module liblpkg;

import toml : parseTOML, TOMLDocument;

import std.file : readText;
import std.net.curl : get;
import std.algorithm : map;
import std.conv : to;
import std.array : array;
import liblrepo;

public struct Lpkg
{
    string name;
    string description;
    string tag;

    string tarball;

    string[] dependencies;
    string[] make;
    string[] install;
    string[] uninstall;
}

Lpkg parseLpkg(string toml){
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
Lpkg parseLpkgFromFile(string file){
    return parseLpkg(readText(file));
}
Lpkg parseLpkgFromURL(string url){
    return parseLpkg(to!string(get(url)));
}
Lpkg parseLpkgFromURLAndSave(string url, string path){
    download(url, path);
    return parseLpkgFromFile(path);
}