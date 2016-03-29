/***********************************************************
	Stirling.c
***********************************************************/

int Stirling2(int n, int k)  /* n > 0 */
{
	if (k < 1 || k > n) return 0;
	if (k == 1 || k == n) return 1;
	return k * Stirling2(n - 1, k)
			 + Stirling2(n - 1, k - 1);
}

int Stirling1(int n, int k)  /* n > 0 */
{
	if (k < 1 || k > n) return 0;
	if (k == n) return 1;
	return (n - 1) * Stirling1(n - 1, k)
				   + Stirling1(n - 1, k - 1);
}

#include <stdio.h>
#include <stdlib.h>

int main()
{
	int n, k;

	printf("Stirling numbers of the 2nd kind\n");
	printf("  k");
	for (k = 0; k <= 8; k++) printf("%10d", k);
	printf("\nn  ");
	for (k = 0; k <= 8; k++) printf("------");
	printf("\n");
	for (n = 0; n <= 8; n++) {
		printf("%10d |", n);
		for (k = 0; k <= n; k++) printf("%10d", Stirling2(n, k));
		printf("\n");
	}

	printf("\nStirling numbers of the 1st kind\n");
	printf("  k");
	for (k = 0; k <= 8; k++) printf("%10d", k);
	printf("\nn  ");
	for (k = 0; k <= 8; k++) printf("------");
	printf("\n");
	for (n = 0; n <= 8; n++) {
		printf("%10d |", n);
		for (k = 0; k <= n; k++) printf("%10d", Stirling1(n, k));
		printf("\n");
	}

	return 0;
}
