
/*************************************************
Libraries
**************************************************/
//volatile char* disp = (char*)(0);
//volatile char* finish = (char*)(1);

const unsigned int disp_addr = 0x0;
const unsigned int int_addr = 0x4;
const unsigned int finish_addr = 0x8;

void outchar(int a) {  
  *((int*)(disp_addr)) = a;  
}

void outnum(int num) {
  *((int*)int_addr) = num;
}

/*
void outstring(char* str) {  
  while (*str != '\0')  
    *((int*)(disp_addr)) = ((int)*(str++));
}
*/

int fib(int n) {
  if (n < 3)
    return 1;
  else 
    return fib(n-1)+fib(n-2);
}

#include<stdio.h>

void Hanoi(int n,int x,int y) {
  if(n>=2) Hanoi(n-1,x,6-x-y);

  printf("%10d %10d %10d\n",n,x,y);

  if(n>=2) Hanoi(n-1,6-x-y,y);
}

void main(void) {
  Hanoi(5,1,5);
  return;
  //*((int*)(finish_addr)) = 1;
}

