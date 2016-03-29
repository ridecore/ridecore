
/*************************************************
Libraries
**************************************************/
//volatile char* disp = (char*)(0);
//volatile char* finish = (char*)(1);

#include "mat.h"

volatile const unsigned int disp_addr = 0x0;
volatile const unsigned int finish_addr = 0x8;
volatile const unsigned int intdisp_addr = 0x4;

#define DISPLAY_CHAR(chr) *((int*)(disp_addr)) = chr
#define FINISH_PROGRAM *((int*)(finish_addr)) = 1
//#define DISPLAY_INT(num) *((int*)(intdisp_addr)) = num

void DISPLAY_INT(int n) {
  int i;
  int temp;
  for (i = 7 ; i >= 0 ; i--) {
    temp = (n >> 4*i) & 0x0f;
    DISPLAY_CHAR(temp >= 10 ? (temp+55) : (temp+48));
  }
  return;
}

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
      DISPLAY_INT(mat_C[i][j]);
      if (j != MATSIZE-1)
	DISPLAY_CHAR(',');
    }
    DISPLAY_CHAR('\n');
  }

  FINISH_PROGRAM;
  return 0;
}
