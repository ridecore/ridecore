/***********************************************************
	cprimes
***********************************************************/
#include <stdio.h>
#include <stdlib.h>
#define N 39
#define SQRTN 6  /* floor(sqrt(N)) */
//char a[N + 1][N + 1];
int a[N + 1][N + 1];
int main()
{
	int i, j, p, q, x, y;

	for (i = 0; i <= N; i++)
		for (j = 0; j <= N; j++) a[i][j] = 1;
	a[0][0] = a[1][0] = a[0][1] = 0;
	for (i = 1; i <= SQRTN; i++) {
		for (j = 0; j <= i; j++) {
			if (a[i][j]) {
				p = i;  q = j;
				do {
					x = p;  y = q;
					do {
						a[x][y] = a[y][x] = 0;
					} while ((x -= j) >= 0 && (y += i) <= N);
					x = p;  y = q;
					do {
						a[x][y] = a[y][x] = 0;
					} while ((x += j) <= N && (y -= i) >= 0);
					p += i;  q += j;
				} while (p <= N);
				a[i][j] = a[j][i] = 1;
			}
		}
	}
	for (i = -N; i <= N; i++) {
		for (j = -N; j <= N; j++) {
			if (a[abs(i)][abs(j)] && i * i + j * j <= N * N)
				printf("*");
			else
				printf(" ");
		}
		printf("\n");
	}
	return 0;
}
