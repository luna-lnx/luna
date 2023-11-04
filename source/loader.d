module loader;

import std.stdio : writef, writefln, writeln, stdout;
import core.thread.osthread : Thread;
import core.time : dur;
import core.atomic : atomicStore;

private immutable string[] icons = ["/", "|", "\\", "-"];

class Loader {
    private bool stop = false;
    private string message = "";
    private void delegate() action;
    this(string message, void delegate() action) {
        this.message = message;
        this.action = action;
    }

    void showLoader() {
        Thread t = new Thread({
            while (!stop) {
                foreach (icon; icons) {
                    writef("\r%s %s", icon, message);
                    stdout.flush();
                    Thread.sleep(dur!"msecs"(150));
                }
            }
            writefln("\r%s... done!", message);
            stdout.flush();
        }).start();
        this.action();
        this.stopLoader();
        t.join();
        return;
    }

    void stopLoader() {
        atomicStore(stop, true);
    }

}
