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

int main()
{
  int i, s, sign[10];
  long n, x;

  for (i = 1; i <= 9; i++) sign[i] = -1;
  do {
    x = 0;  s = 1; n = 0;
    for (i = 1; i <= 9; i++)
      if (sign[i] == 0) n = 10 * n + i;
      else {
	x += s * n;  s = sign[i];  n = i;
      }
    x += s * n;
    if (x == 100) {
      for (i = 1; i <= 9; i++) {
	if      (sign[i] ==  1) {
	  //printf(" + ");
	  DISPLAY_CHAR(' ');
	  DISPLAY_CHAR('+');
	  DISPLAY_CHAR(' ');
	}
	else if (sign[i] == -1) {
	  //			    printf(" - ");
	  DISPLAY_CHAR(' ');
	  DISPLAY_CHAR('-');
	  DISPLAY_CHAR(' ');
	}
	//			  printf("%10d", i);
	DISPLAY_INT(i);
      }
      //printf(" = 100\n");
      DISPLAY_CHAR(' ');
      DISPLAY_CHAR('=');
      DISPLAY_CHAR(' ');
      DISPLAY_CHAR('1');
      DISPLAY_CHAR('0');
      DISPLAY_CHAR('0');
      DISPLAY_CHAR('\n');
    }
    i = 9;  s = sign[i] + 1;
    while (s > 1) {
      sign[i] = -1;  i--;  s = sign[i] + 1;
    }
    sign[i] = s;
  } while (sign[1] < 1);
  FINISH_PROGRAM;
  return 0;
}
