
/*************************************************
Libraries
**************************************************/
//volatile char* disp = (char*)(0);
//volatile char* finish = (char*)(1);

const unsigned int disp_addr = 0x0;
const unsigned int int_addr = 0x4;
const unsigned int finish_addr = 0x8;

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

void outchar(int a) {  
  *((int*)(disp_addr)) = a;  
}

void outnum(int num) {
  *((int*)int_addr) = num;
}

void main(void) {
  int i, j;
  for (i = 0 ; i < 6 ; i++) {
    for (j = 0 ; j < 6 ; j++) {
      result[i][j] = 
	mat[i+1][j+1]+mat[i+1+1][j+1]+mat[i+1-1][j+1]
	+mat[i+1][j+1+1]+mat[i+1+1][j+1+1]+mat[i+1-1][j+1+1]
	+mat[i+1][j+1-1]+mat[i+1+1][j+1-1]+mat[i+1-1][j+1-1];
      printf("%10d,", result[i][j]);
    }
    printf("\n");
  }
  return;
  //  *((int*)(finish_addr)) = 1;
}
