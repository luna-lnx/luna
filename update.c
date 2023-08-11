#include <stdio.h>
#include <string.h>

int update(int argc, char **argv) {
  printf("updating repos...\n");

  FILE *galaxiesptr = fopen("/etc/luna/galaxies.conf", "r");
  if (galaxiesptr == NULL) {
    perror("couldnt load galaxies.conf");
    return 1;
  }
  char galaxy[2048];
  char repos[24][512];

  int i = 0;
  while (fgets(galaxy, 2048, galaxiesptr)) {
    galaxy[strcspn(galaxy, "\n")] = '\0';
    strcpy(repos[i], galaxy);
    ++i;
    if (i >= 24) {
      break;
    }
  };
  fclose(galaxiesptr);
  for (int z = 0; z < i; ++z) {
    printf("getting %d/%d\n", z + 1, i);
  }
  return 0;
}