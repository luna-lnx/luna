module update;

import std.stdio : writefln;
import std.file : readText, exists;
import std.string : strip, split;
import std.net.curl : download;

void updateRepos(string[] args)
{
    if (!exists("/etc/luna/repos.conf"))
    {
        throw new Exception(
            "luna: cannot access '/etc/luna/repos.conf': no such file or directory");
    }
    string[] galaxies = split(strip(readText("/etc/luna/repos.conf")), "\n");
    for (int i = 0; i < galaxies.length; ++i)
    {
        string[] urlBits = split(galaxies[i], "/");
        string filename = urlBits[urlBits.length - 1];
        writefln("getting %s/%s (%s)", i + 1, galaxies.length, filename);
        download(galaxies[i], "/etc/luna/repos/" ~ filename);
    }
    return;
}