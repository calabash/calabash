#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include "md5.h"

#define BUFFER_SIZE 1024

MD5_CTX ctx;

int read_file(char *file_path, void  (*func)(char *, int)) {
  char buffer[BUFFER_SIZE];
  FILE *file;
  size_t read;

  file = fopen(file_path, "r");

  if (file > 0) {
    while ((read = fread(buffer, sizeof(char), sizeof(buffer), file)) > 0) {
      func(buffer, read);
    }

    if (ferror(file)) {
      fprintf(stderr, "Error reading file: %s (%i)\n", strerror(errno), errno);
      fclose(file);

      return 2;
    }

    fclose(file);

    return 0;
  } else {
    fprintf(stderr, "Could not open file: %s (%i)\n", strerror(errno), errno);
    return 1;
  }
}

void update(char *str, int length) {
  MD5_Update(&ctx, str, length);
}

int main(int argc, char** argv) {
  if (argc != 2) {
    fprintf(stderr, "Usage: calmd5 <file>\n");
    return 1;
  }

  char *file_path = argv[1];
  unsigned char digest[16];

  MD5_Init(&ctx);

  if (read_file(file_path, update)) {
    return 2;
  }

  MD5_Final(digest, &ctx);

  int i;

  for (i = 0; i < 16; i++) {
    fprintf(stdout, "%02x", (unsigned int)digest[i]);
  }

  fprintf(stdout, "\n");

  return 0;
}
