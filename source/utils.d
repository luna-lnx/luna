module utils;

import core.sys.posix.unistd : geteuid;

bool isSu() {
    return geteuid() == 0;
}
