#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

int nummax = 32;
int matsiz = 16;

int main(int argc, char** argv) {
  unsigned int seed;
  int i, j;
  if (argc == 2) {
    seed = (unsigned int)atoi((const char*)argv[1]);
  } else if (argc == 3) {
    seed = (unsigned int)atoi((const char*)argv[1]);
    matsiz = atoi((const char*)argv[2]);
  } else if (argc == 4) {
    seed = (unsigned int)atoi((const char*)argv[1]);
    matsiz = atoi((const char*)argv[2]);
    nummax = atoi((const char*)argv[3]);
  } else {
    seed = (unsigned int)time(NULL);
  }
  srand(seed);

  printf("//seed: %d, nummax: %d\n\n", seed, nummax);
  printf("#define MATSIZE %d\n\n", matsiz);
  printf("int mat_A[%d][%d] = {\n", matsiz, matsiz);
  for (j = 0 ; j < matsiz ; j++) {
    printf("\t{");
    for (i = 0 ; i < matsiz ; i++) {
      printf("%d", rand()%nummax);
      if (i != matsiz-1)
	printf(", ");
    }
    printf("}");
    if (j != matsiz-1)
      printf(",\n");
  }
  printf("\n};\n");

  printf("int mat_B[%d][%d] = {\n", matsiz, matsiz);
  for (j = 0 ; j < matsiz ; j++) {
    printf("\t{");
    for (i = 0 ; i < matsiz ; i++) {
      printf("%d", rand()%nummax);
      if (i != matsiz-1)
	printf(", ");
    }
    printf("}");
    if (j != matsiz-1)
      printf(",\n");
  }
  printf("\n};\n");

  return 0;
}
