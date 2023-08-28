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
    foreach (line; installed)
    {
        string[] pkg = split(line, "=");
        string[] pkgName = split(pkg[0], "/");
        string[] output;
        PackageLoc loc = findPackage(pkgName[0], pkgName[1]);
        getPackage(loc, pkg[0]);
        auto proc = pipeProcess([
            "sh", "-c",
            format(`source /tmp/%s.lpkg && echo "$TAG" 1>&2`, pkg[0])
        ], Redirect.all);
        foreach (tline; proc.stderr.byLine)
        {
            output ~= tline.idup;
        }
        if(cmp(output[0], pkg[1]) != 0){
            installPackage(pkg[0], true, true, loc);
        }
    }
}
