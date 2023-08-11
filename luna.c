#include "update.h"
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "trim.h"

#define VERSION "v0.01"

// Thanks https://stackoverflow.com/a/17215441
#define ARR_SIZE(arr) (sizeof((arr)) / sizeof((arr[0])))

int main(int argc, char **argv) {
  // Snarky error messages, just in case, hehe.
  char errorMsgs[][50] = {"rats!",
                          "someone call neo!",
                          "good luck",
                          "worked fine on my machine",
                          "did you turn it off and back on again?",
                          "your fault",
                          "have you considered a life of crime?",
                          "really? you did that?",
                          "it's not a bug, it's a feature",
                          "uwaaah!"};
  printf("luna - %s\n", VERSION);
  if(argc < 2){
    printf("missing arguments, quitting");
    return 1;
  }
  if (!strcmp(trim(argv[1]), "u")) {
    if (({
          int r = update(argc, argv);
          r > 0;
        })) {
      srand(time(NULL));
      const char *comment = errorMsgs[rand() % ARR_SIZE(errorMsgs)];
      printf("exited with error - %s\n", comment);
      return 1;
    }
  } else {
  }
  return 0;
}