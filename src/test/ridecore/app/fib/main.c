
/*************************************************
Libraries
**************************************************/
//volatile char* disp = (char*)(0);
//volatile char* finish = (char*)(1);

volatile const unsigned int disp_addr = 0x0;
volatile const unsigned int int_addr = 0x4;
volatile const unsigned int finish_addr = 0x8;

int outchar(int a) {  
  *((int*)(disp_addr)) = a;  
  return 0;
}

int outnum(int num) {
  *((int*)int_addr) = num;
  return 0;
}

void DISPLAY_INT(int n) {
  int i;
  int temp;
  for (i = 7 ; i >= 0 ; i--) {
    temp = (n >> 4*i) & 0x0f;
    outchar(temp >= 10 ? (temp+55) : (temp+48));
  }
  return;
}

int fib(int n) {
  if (n < 3)
    return 1;
  else 
    return fib(n-1)+fib(n-2);
}

int main(void) {
  //outnum(fib(3));
  //*((int*)int_addr) = fib(13);
  DISPLAY_INT(fib(13));
  *((int*)(disp_addr)) = '\n';
  *((int*)(disp_addr)) = 'B';
  outchar('A');
  *((int*)(finish_addr)) = 1;
  return 0;
}
