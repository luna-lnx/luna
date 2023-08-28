module install;

import std.stdio : writefln, writeln;
import std.getopt;
import std.process : Redirect, pipeProcess, wait;
import std.array : join, split;
import std.format : format;
import std.file : dirEntries, SpanMode, readText, exists, remove;
import std.json : JSONValue, parseJSON;
import std.net.curl : download;
import std.string : strip;
import std.typecons : Nullable;
import std.algorithm : canFind, cmp;

struct PackageLoc
{
    string prefix;
    string name;
}

PackageLoc findPackage(string pname)
{
    bool found = false;
    PackageLoc loc;
    foreach (string file; dirEntries("/etc/luna/repos", SpanMode.shallow, true))
    {
        string lines = readText(file);
        JSONValue repo = parseJSON(lines);
        foreach (name, packages; repo["constellations"].object)
        {
            foreach (pkg; packages.array)
            {
                if (pkg.str == pname)
                {
                    if (found)
                    {
                        throw new Exception("luna: multiple packages with name" ~ pname);
                    }
                    found = true;
                    loc = PackageLoc(repo["prefix"].str, name);
                }
            }
        }
    }
    if (!found)
    {
        throw new Exception("luna: couldn't find package " ~ pname);
    }
    return loc;
}

PackageLoc findPackage(string constellation, string pname)
{
    foreach (string file; dirEntries("/etc/luna/repos", SpanMode.shallow, true))
    {
        string lines = readText(file);
        JSONValue repo = parseJSON(lines);
        foreach (name, packages; repo["constellations"].object)
        {
            if (cmp(name, constellation) > 0)
                continue;
            foreach (pkg; packages.array)
            {
                if (pkg.str == pname)
                {
                    return PackageLoc(repo["prefix"].str, name);
                }
            }
        }
    }
    throw new Exception("luna: couldn't find package " ~ pname);
}

void addCommand(string action, string cmd, ref string[] commands)
{
    commands ~= format("echo 'luna: %s' 1>&2", action);
    commands ~= cmd;
}

void getPackage(PackageLoc loc, string pname)
{
    download(format("%s%s/%s/%s.lpkg", loc.prefix, loc.name, pname, pname), format(
            "/tmp/%s.lpkg", pname));
}

void installPackage(string[] args)
{
    bool clean = false;
    getopt(
        args,
        std.getopt.config.bundling,
        std.getopt.config.caseSensitive,
        std.getopt.config.stopOnFirstNonOption,
        std.getopt.config.passThrough,
        "c|clean", "removes old files (if available) and clean compiles", &clean,
    );
    installPackage(args[1], clean);

}

void installPackage(string pname, bool clean)
{
    installPackage(pname, clean, false, PackageLoc("", ""));
}

void installPackage(string pname, bool clean, bool useCached, PackageLoc loc)
{
    string[] commands;

    bool found = false;
    string pnameprefix = "";
    if (!useCached)
    {
        writeln("luna: getting package info");
        if (canFind(pname, "/"))
        {
            string[] splt = split(pname, "/");
            pname = splt[1];
            pnameprefix = splt[0];
            loc = findPackage(pnameprefix, pname);
            getPackage(loc, pname);
        }
        else
        {
            loc = findPackage(pname);
            pnameprefix = loc.name;
            getPackage(loc, pname);
        }
    }
    else
    {
        writeln("luna: using cached package info");
    }

    commands ~= format("source /tmp/%s.lpkg", pname);
    void configCommands()
    {
        if (exists(format("/etc/luna/src/%s_%s", pnameprefix, pname)) && !clean)
        {
            addCommand("cloning repo", format("cd /etc/luna/src/%s_$NAME && git pull origin $TAG", pnameprefix), commands);
        }
        else if (exists(format("/etc/luna/src/%s_%s", pnameprefix, pname)))
        {
            addCommand("cleaning old files", "rm -rf /etc/luna/src/$NAME", commands);
            addCommand("cloning repo", format("git clone $REPO /etc/luna/src/%s_$NAME -b $TAG", pnameprefix), commands);
        }
        else
        {
            addCommand("cloning repo", format("git clone $REPO /etc/luna/src/%s_$NAME -b $TAG", pnameprefix), commands);
        }
        commands ~= "cd /etc/luna/src/$NAME/";
        addCommand("building", "BUILD -j$(nproc --all)", commands);
        addCommand("installing", "INSTALL", commands);
    }

    configCommands();
    auto proc = pipeProcess(["sh", "-c", join(commands, " && ")], Redirect.all);

    foreach (line; proc.stderr.byLine())
    {
        writeln(line);
    }

    int status = wait(proc.pid);
    if (status != 0)
    {
        writefln("luna: failed to install %s. please check /etc/luna/log/%s.log for more information.", pname, pname);
    }
    else
    {
        commands = [];
        commands ~= format("source /tmp/%s.lpkg", pname);
        commands ~= "mv /etc/luna/packages.conf /etc/luna/packages.conf.bak";
        commands ~= "grep -vi $NAME= /etc/luna/packages.conf.bak | grep -v '^$' > /etc/luna/packages.conf";
        commands ~= format(`echo -e "%s/$NAME=$TAG" >> /etc/luna/packages.conf`, loc.name);
        proc = pipeProcess(["sh", "-c", join(commands, "; ")], Redirect.all);
        foreach (line; proc.stdout.byLine())
        {
            writeln(line);
        }
        foreach (line; proc.stderr.byLine())
        {
            writeln(line);
        }
        wait(proc.pid);
        writefln("luna: installed %s", pname);
    }
    remove(format("/tmp/%s.lpkg", pname));
}
