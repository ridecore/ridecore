/***********************************************************
	combinat.c
***********************************************************/

int comb(int n, int k)
{
	if (k == 0 || k == n) return 1;
	/* if (k == 1) return n; */
	return comb(n - 1, k - 1) + comb(n - 1, k);
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

#include <stdio.h>
#include <stdlib.h>
#define N   8

int main()
{
	int n, k;

	printf("\n  k");
	for (k = 0; k <= N; k++) printf("%10d", k);
	printf("\nn  ");
	for (k = 0; k <= N; k++) printf("------");
	printf("\n");
	for (n = 0; n <= N; n++) {
		printf("%10d |", n);
		for (k = 0; k <= n; k++) printf("%10d", comb(n, k));
		printf("\n");
	}

	printf("\n  k");
	for (k = 0; k <= N; k++) printf("%10d", k);
	printf("\nn  ");
	for (k = 0; k <= N; k++) printf("------");
	printf("\n");
	for (n = 0; n <= N; n++) {
		printf("%10d |", n);
		for (k = 0; k <= n; k++) printf("%10lu", combination(n, k));
		printf("\n");
	}

	for (k = 0; k <= 17; k++)
		printf("34C%10d = %10lu\n", k, combination(34, k));

	return 0;
}
