volatile const unsigned int disp_addr = 0x0;
volatile const unsigned int finish_addr = 0x8;
volatile const unsigned int intdisp_addr = 0x4;

#define DISPLAY_CHAR(chr) *((int*)(disp_addr)) = chr
#define FINISH_PROGRAM *((int*)(finish_addr)) = 1
//#define DISPLAY_INT(num) *((int*)(intdisp_addr)) = num

int comb(int n, int k)
{
	if (k == 0 || k == n) return 1;
	/* if (k == 1) return n; */
	return comb(n - 1, k - 1) + comb(n - 1, k);
}

void DISPLAY_INT(int n) {
  int i;
  int temp;
  for (i = 7 ; i >= 0 ; i--) {
    temp = (n >> 4*i) & 0x0f;
    DISPLAY_CHAR(temp >= 10 ? (temp+55) : (temp+48));
  }
  return;
}

unsigned long combination(int n, int k)
{
	int i, j;
	unsigned long a[17];

	if (n - k < k) k = n - k;
	if (k == 0) return 1;
	if (k == 1) return n;
	if (k > 17) return 0;  /* error */
	for (i = 1; i < k; i++) a[i] = i + 2;
	for (i = 3; i <= n - k + 1; i++) {
		a[0] = i;
		for (j = 1; j < k; j++) a[j] += a[j - 1];
	}
	return a[k - 1];
}

#define N   8

int main()
{
	int n, k;

	DISPLAY_CHAR('\n');
	DISPLAY_CHAR(' ');
	DISPLAY_CHAR(' ');
	DISPLAY_CHAR('k');
	for (k = 0; k <= N; k++) DISPLAY_INT(k);
	DISPLAY_CHAR('\n');
	DISPLAY_CHAR('n');
	DISPLAY_CHAR(' ');
	DISPLAY_CHAR(' ');
	for (k = 0; k <= N; k++) {
	  DISPLAY_CHAR('-');
	  DISPLAY_CHAR('-');
	  DISPLAY_CHAR('-');
	  DISPLAY_CHAR('-');
	  DISPLAY_CHAR('-');
	  DISPLAY_CHAR('-');
	}
	DISPLAY_CHAR('\n');
	for (n = 0; n <= N; n++) {
	  //		printf("%10d |", n);
	  DISPLAY_INT(n);
	  DISPLAY_CHAR(' ');
	  DISPLAY_CHAR('|');
	  for (k = 0; k <= n; k++) //printf("%10d", comb(n, k));
	    DISPLAY_INT(comb(n, k));
	  DISPLAY_CHAR('\n');
	}

	DISPLAY_CHAR('\n');
	DISPLAY_CHAR(' ');
	DISPLAY_CHAR(' ');
	DISPLAY_CHAR('k');
	for (k = 0; k <= N; k++) DISPLAY_INT(k);
	DISPLAY_CHAR('\n');
	DISPLAY_CHAR('n');
	DISPLAY_CHAR(' ');
	DISPLAY_CHAR(' ');
	for (k = 0; k <= N; k++) {
	  DISPLAY_CHAR('-');
	  DISPLAY_CHAR('-');
	  DISPLAY_CHAR('-');
	  DISPLAY_CHAR('-');
	  DISPLAY_CHAR('-');
	  DISPLAY_CHAR('-');
	}
	DISPLAY_CHAR('\n');
	for (n = 0; n <= N; n++) {
	  //		printf("%10d |", n);
	  DISPLAY_INT(n);
	  DISPLAY_CHAR(' ');
	  DISPLAY_CHAR('|');
	  for (k = 0; k <= n; k++) //printf("%10d", comb(n, k));
	    DISPLAY_INT(combination(n, k));
	  DISPLAY_CHAR('\n');
	}

	for (k = 0; k <= 17; k++)
	  {
	    DISPLAY_CHAR('3');
	    DISPLAY_CHAR('4');
	    DISPLAY_CHAR('C');
	    DISPLAY_INT(k);
	    DISPLAY_CHAR(' ');
	    DISPLAY_CHAR('=');
	    DISPLAY_CHAR(' ');
	    DISPLAY_INT(combination(34, k));
	    DISPLAY_CHAR('\n');
	  }
	  //		printf("34C%10d = %10lu\n", k, combination(34, k));

	FINISH_PROGRAM;
	return 0;
}

