/***********************************************************
	komachi.c
***********************************************************/
#include <stdio.h>
#include <stdlib.h>

int main()
{
	int i, s, sign[10];
	long n, x;

	for (i = 1; i <= 9; i++) sign[i] = -1;
	do {
		x = n = 0;  s = 1;
		for (i = 1; i <= 9; i++)
			if (sign[i] == 0) n = 10 * n + i;
			else {
				x += s * n;  s = sign[i];  n = i;
			}
		x += s * n;
		if (x == 100) {
			for (i = 1; i <= 9; i++) {
				if      (sign[i] ==  1) printf(" + ");
				else if (sign[i] == -1) printf(" - ");
				printf("%10d", i);
			}
			printf(" = 100\n");
		}
		i = 9;  s = sign[i] + 1;
		while (s > 1) {
			sign[i] = -1;  i--;  s = sign[i] + 1;
		}
		sign[i] = s;
	} while (sign[1] < 1);
	return 0;
}
