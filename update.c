#include <stdio.h>
#include <string.h>
#include <curl/curl.h>
#include <curl/easy.h>
#include "trim.h"

// sauce: curl docs
size_t write_data(void *ptr, size_t size, size_t nmemb, FILE *stream) {
    size_t written = fwrite(ptr, size, nmemb, stream);
    return written;
}

int update(int argc, char **argv) {
  curl_global_init(CURL_GLOBAL_ALL);
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
    const char* filename = strrchr(repos[z], '/')+1;
    char basePath[72] = "/etc/luna/galaxies/";
    printf("getting %d/%d\n", z + 1, i);
    FILE *fp = fopen(strcat(basePath, filename), "wb");
    CURL *easy = curl_easy_init();
    curl_easy_setopt(easy, CURLOPT_URL, trim(repos[z]));
    curl_easy_setopt(easy, CURLOPT_WRITEFUNCTION, write_data);
    curl_easy_setopt(easy, CURLOPT_WRITEDATA, fp);
    CURLcode res = curl_easy_perform(easy);
    if(res != CURLE_OK){
      printf("curl: failed to download %s with %s", filename, curl_easy_strerror(res));
      perror("failed to get repo");
      return 2;
    }
    fclose(fp);
    curl_easy_cleanup(easy);
  }
  curl_global_cleanup();
  return 0;
}