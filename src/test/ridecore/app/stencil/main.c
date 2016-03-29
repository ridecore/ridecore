
/*************************************************
Libraries
**************************************************/
//volatile char* disp = (char*)(0);
//volatile char* finish = (char*)(1);

volatile const unsigned int disp_addr = 0x0;
volatile const unsigned int int_addr = 0x4;
volatile const unsigned int finish_addr = 0x8;

#define DISPLAY_CHAR(chr) *((int*)(disp_addr)) = chr
#define FINISH_PROGRAM *((int*)(finish_addr)) = 1
//#define DISPLAY_INT(num) *((int*)(intdisp_addr)) = num

int mat[8][8] = {
  {4,3,7,2,9,3,2,1},
  {6,3,8,1,0,4,2,9},
  {4,3,5,2,1,5,9,2},
  {9,1,1,2,3,4,7,1},
  {0,5,4,8,9,7,6,8},
  {4,3,4,2,3,5,0,2},
  {9,1,8,2,7,4,1,1},
  {0,5,4,8,0,7,0,8}
};

int result[6][6] = {0};

void DISPLAY_INT(int n) {
  int i;
  int temp;
  for (i = 7 ; i >= 0 ; i--) {
    temp = (n >> 4*i) & 0x0f;
    DISPLAY_CHAR(temp >= 10 ? (temp+55) : (temp+48));
  }
  return;
}

void outchar(int a) {  
  *((int*)(disp_addr)) = a;  
  return;
}

int main(void) {
  int i, j;
  for (i = 0 ; i < 6 ; i++) {
    for (j = 0 ; j < 6 ; j++) {
      result[i][j] = 
	mat[i+1][j+1]+mat[i+1+1][j+1]+mat[i+1-1][j+1]
	+mat[i+1][j+1+1]+mat[i+1+1][j+1+1]+mat[i+1-1][j+1+1]
	+mat[i+1][j+1-1]+mat[i+1+1][j+1-1]+mat[i+1-1][j+1-1];
      DISPLAY_INT(result[i][j]);
      /*
      outnum(	mat[i+1][j+1]+mat[i+1+1][j+1]+mat[i+1-1][j+1]
	+mat[i+1][j+1+1]+mat[i+1+1][j+1+1]+mat[i+1-1][j+1+1]
	+mat[i+1][j+1-1]+mat[i+1+1][j+1-1]+mat[i+1-1][j+1-1]
		);
      */
    }
    outchar('\n');
  }
  //return;
  *((int*)(finish_addr)) = 1;
  return 0;
}
