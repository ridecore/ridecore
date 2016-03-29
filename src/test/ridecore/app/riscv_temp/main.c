
/*************************************************
Libraries
**************************************************/
//volatile char* disp = (char*)(0);
//volatile char* finish = (char*)(1);

const unsigned int disp_addr = 0x0;
const unsigned int int_addr = 0x4;
const unsigned int finish_addr = 0x8;

void outchar(char a) {  *((int*)(disp_addr))=a;  }

void outstring(char* str) {  while (*str != '\0')  *((int*)(disp_addr)) = *(str++); }

void outnum(int num) {
  *((int*)int_addr) = num;
}

int fib(int n) {
  if (n < 3)
    return 1;
  else 
    return fib(n-1)+fib(n-2);
}

void main(void) {
  //outnum(fib(5));
  outchar('A');
  *((int*)(disp_addr)) = 'B';
  *((int*)(finish_addr)) = 1;
}
