// https://stackoverflow.com/a/657508
#include <stdio.h>
#include <string.h>
#include <ctype.h>

char *trim(char *s) {
  char *ptr;
  if (!s)
    return NULL;
  if (!*s)
    return s;
  for (ptr = s + strlen(s) - 1; (ptr >= s) && isspace(*ptr); --ptr)
    ;
  ptr[1] = '\0';
  return s;
}