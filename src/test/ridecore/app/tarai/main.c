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

int tarai(int x, int y, int z)
{
	if (x <= y) return y;
	return tarai(tarai(x - 1, y, z),
				 tarai(y - 1, z, x),
				 tarai(z - 1, x, y));
}

int main(void) {
  int x, y, z;
  x=8;
  y=4;
  z=0;
  DISPLAY_INT(tarai(x, y, z));
  DISPLAY_CHAR('\n');
  FINISH_PROGRAM;
  return 0;
}
