/***********************************************************
	tarai.c
***********************************************************/

int tarai(int x, int y, int z)
{
	if (x <= y) return y;
	return tarai(tarai(x - 1, y, z),
				 tarai(y - 1, z, x),
				 tarai(z - 1, x, y));
}

#include <stdio.h>
#include <stdlib.h>

int main()
{
	int x, y, z;
	x=12;
	y=6;
	z=0;
	//printf("x = ");  scanf("%d", &x);
	//printf("y = ");  scanf("%d", &y);
	//printf("z = ");  scanf("%d", &z);
	printf("%d\n", tarai(x, y, z));
	return 0;
}
