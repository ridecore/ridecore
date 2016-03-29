
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
#define TEST 1

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

void Hanoi(int n,int x,int y) {
  if(n>=2) Hanoi(n-1,x,6-x-y);

  //  printf("%d %d %d\n",n,x,y);
  DISPLAY_INT(n);
  outchar(' ');
  DISPLAY_INT(x);
  outchar(' ');
  DISPLAY_INT(y);
  outchar('\n');

  if(n>=2) Hanoi(n-1,6-x-y,y);
  return;
}

int main(void) {
  Hanoi(5,1,5);
  *((int*)(finish_addr)) = 1;
  return 0;
}

