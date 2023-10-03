module upgrade;

import std.file : readText;
import std.array : split;
import std.process : pipeProcess, Redirect, wait;
import std.format : format;
import std.stdio : writeln;
import std.string : strip, cmp;

import install;

void upgradeSystem(string[] args)
{
    string[] installed = split(strip(readText("/etc/luna/packages.conf")), "\n");
    int count = 0;
    foreach (line; installed)
    {
        ++count;
        writeln("luna: performing full system upgrade");
        string[] pkg = split(line, "=");
        string[] pkgName = split(pkg[0], "/");
        string[] output;
        PackageLoc loc = findPackage(pkgName[0], pkgName[1]);
        if(cmp(loc.vers, pkg[1]) != 0){
            writeln("luna: upgrading" ~ pkgName[1]);
            installPackage(pkgName[1], true, true, loc);
        }
    }
}
