volatile const unsigned int disp_addr = 0x0;
volatile const unsigned int finish_addr = 0x8;
volatile const unsigned int intdisp_addr = 0x4;

#define DISPLAY_CHAR(chr) *((int*)(disp_addr)) = chr
#define FINISH_PROGRAM *((int*)(finish_addr)) = 1
//#define DISPLAY_INT(num) *((int*)(intdisp_addr)) = num

void sort(int *x, int n);
void msort(int*, int, int);
void qsort(int*, int, int);
void swap(int*, int, int);
void showdata(int *x, int n);

void DISPLAY_INT(int n) {
  int i;
  int temp;
  for (i = 7 ; i >= 0 ; i--) {
    temp = (n >> 4*i) & 0x0f;
    DISPLAY_CHAR(temp >= 10 ? (temp+55) : (temp+48));
  }
  return;
}

//For msort
int temp[10];
int a[] = {7, 6, 4, 2, 1, 8, 0, 5, 9, 3};
int b[] = {7, 6, 4, 2, 1, 8, 0, 5, 9, 3};
int c[] = {7, 6, 4, 2, 1, 8, 0, 5, 9, 3};

void sort(int *x, int n) {
  int i, j, t;

  for (i = 0; i < n - 1; i++) {
    for (j = n - 1; j > i; j--) {
      if (x[j - 1] > x[j]) {
	t = x[j];
	x[j] = x[j - 1];
	x[j - 1]= t;
      }
    }
  }
  return;
}

void msort(int *x, int left, int right) {
  int mid, i, j, k;
  
  if (left >= right)
    return;

  mid = (left + right) >> 1;
  msort(x, left, mid);
  msort(x, mid + 1, right);

  for (i = left; i <= mid; i++)
    temp[i] = x[i];

  for (i = mid + 1, j = right; i <= right; i++, j--)
    temp[i] = x[j];

  i = left;  j = right;

  for (k = left; k <= right; k++)
    if (temp[i] <= temp[j])
      x[k] = temp[i++];
    else
      x[k] = temp[j--];

  return;
}

void qsort(int *x, int left, int right) {
  int i, j;
  int pivot;

  i = left;             
  j = right;            

  pivot = x[(left + right) >> 1];

  while (1) {             
    while (x[i] < pivot)  i++;                
    while (pivot < x[j])  j--;                
    if (i >= j)           
      break;              

    swap(x, i, j);        
    i++; j--;
  }

  if (left < i - 1)
    qsort(x, left, i - 1);
  if (j + 1 <  right)
    qsort(x, j + 1, right);

  return;
}

void swap(int *x, int i, int j) {
  int t;

  t = x[i];
  x[i] = x[j];
  x[j] = t;

  return;
}

void showdata(int *x, int n) {
  int i;
  for (i = 0 ; i < n ; i++) {
    DISPLAY_INT(x[i]);
    if (i != n-1) 
      DISPLAY_CHAR(',');
  }
  DISPLAY_CHAR('\n');

  return;
}

int main(void) {
  sort(a, 10);  
  showdata(a, 10);
  msort(b, 0, 9);
  showdata(b, 10);
  qsort(c, 0, 9);
  showdata(c, 10);
  FINISH_PROGRAM;
  return 0;
}
