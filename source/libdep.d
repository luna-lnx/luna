module libdep;

import std.algorithm : canFind, remove, countUntil;
import std.format : format;
import liblpkg;
import liblrepo;
import logger;

// https://www.electricmonk.nl/docs/dependency_resolving_algorithm/dependency_resolving_algorithm.html

Lpkg[] resolveDependencies(Lpkg pkg) {
    Lpkg[] unresolved, resolved;
    return resolveDependencies(pkg, unresolved, resolved);
}

Lpkg[] resolveDependencies(Lpkg pkg, ref Lpkg[] unresolved, ref Lpkg[] resolved) {
    unresolved ~= pkg;
    foreach (dep; pkg.dependencies) {
        Lpkg[] deppkgs = parseLpkgFromRepos(parseReposFromDir("/var/lib/luna/repos.conf.d/"), dep);
        if (deppkgs.length != 1)
            logger.fatal(format("%s packages with name %s while resolving dependencies", deppkgs.length == 0 ? "found no" : "found too many", dep));
        Lpkg deppkg = deppkgs[0];
        if (!canFind(resolved, deppkg)) {
            if (canFind(unresolved, deppkg))
                logger.fatal("circular dependencies");
            resolveDependencies(deppkg, unresolved, resolved);
        }
    }
    resolved ~= pkg;
    unresolved.remove(countUntil(unresolved, pkg));
    return resolved;
}
