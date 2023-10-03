module liblpkg;

struct lpkg {
    // Name
    string name;
    // Description
    string desc;
    // Version
    string vers;
    // Source URL
    string srcurl;

    // Dependencies
    string[] deps;
    // Functions to build
    string[] build;
    // Functions to install
    string[] install;
    // Functions to uninstall
    string[] uninstall;
}

import std.file : readText;
import std.json : parseJSON, JSONValue, JSONType;

lpkg parseData(string data){
    JSONValue parsed = parseJSON(data);
    string[] jsonArrayToArray(JSONValue[] values){
        string[] arr;
        foreach(value; values){
            if(value.type == JSONType.string){
                arr ~= value.str;
            }
        }
        return arr;
    }
    lpkg pkg = lpkg(

        parsed["name"].str,
        parsed["desc"].str,
        parsed["vers"].str,
        parsed["srcurl"].str,

        jsonArrayToArray(parsed["deps"].array),
        jsonArrayToArray(parsed["build"].array),
        jsonArrayToArray(parsed["install"].array)
        jsonArrayToArray(parsed["uninstall"].array)

    );
    return pkg;
}

lpkg parseFile(string path){
    return parseData(readText(path));
}