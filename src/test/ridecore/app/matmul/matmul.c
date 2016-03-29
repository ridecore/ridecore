#include <stdio.h>
#include "mat.h"

int main(void) {
  int i, j, k;
  int mat_C[MATSIZE][MATSIZE];
  
  for (i = 0 ; i < MATSIZE ; i++) {
    for (j = 0 ; j < MATSIZE ; j++) {
      mat_C[i][j] = 0;
      for (k = 0 ; k < MATSIZE ; k++) {
	mat_C[i][j] += mat_A[i][k] * mat_B[k][j];
      }
    }
  }

  for (i = 0 ; i < MATSIZE ; i++) {
    for (j = 0 ; j < MATSIZE ; j++) {
      printf("%10d", (mat_C[i][j]));
      if (j != MATSIZE-1)
	printf(",");
    }
    printf("\n");
  }

  return 0;
}
