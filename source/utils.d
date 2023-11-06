module utils;

import core.sys.posix.unistd : geteuid;
import core.stdc.stdlib;

bool isSu() {
    return geteuid() == 0;
}