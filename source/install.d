module install;

import std.stdio : writefln, writeln;
import std.getopt;
import std.process : Redirect, pipeProcess, wait;
import std.array : join, split;
import std.format : format;
import std.file : dirEntries, SpanMode, readText, exists;
import std.json : JSONValue, parseJSON;
import std.net.curl : download;
import std.string : strip;

struct packageLoc
{
    string prefix;
    string name;
}

packageLoc findPackage(string pname)
{
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
                    return packageLoc(repo["prefix"].str, name);
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

void installPackage(string[] args)
{
    string[] commands;

    bool clean = false;

    getopt(
        args,
        std.getopt.config.bundling,
        std.getopt.config.caseSensitive,
        std.getopt.config.stopOnFirstNonOption,
        std.getopt.config.passThrough,
        "c|clean", "removes old files (if available) and clean compiles", &clean,
    );

    bool found = false;
    string pname = args[1];
    packageLoc loc = findPackage(pname);
    writeln("luna: getting package info");
    download(format("%s%s/%s/%s.lpkg", loc.prefix, loc.name, pname, pname), format(
            "/tmp/%s.lpkg", pname));
    commands ~= format("source /tmp/%s.lpkg", pname);
    void configCommands()
    {
        if (exists("/etc/luna/src/" ~ pname) && !clean)
        {
            addCommand("cloning repo", "cd /etc/luna/src/$NAME && git pull origin $TAG", commands);
        }
        else if (exists("/etc/luna/src/" ~ pname))
        {
            addCommand("cleaning old files", "rm -rf /etc/luna/src/$NAME", commands);
            addCommand("cloning repo", "git clone $REPO /etc/luna/src/$NAME -b $TAG", commands);
        }
        else
        {
            addCommand("cloning repo", "git clone $REPO /etc/luna/src/$NAME -b $TAG", commands);
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
        commands ~= `echo -e "$NAME=$TAG" >> /etc/luna/packages.conf`;
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
}
