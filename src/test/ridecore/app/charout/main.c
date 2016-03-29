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
  for (k = 0 ; k < 20 ; k++) {
    for (i = 65 ; i < 65+26 ; i++) {
      for (j = 0 ; j < 100 ; j++) {
	DISPLAY_CHAR(i);
      }
      DISPLAY_CHAR('\n');
    }
  }
  FINISH_PROGRAM;
  return 0;
}
