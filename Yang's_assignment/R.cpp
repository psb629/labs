#include "R.h"

void R1(double **data, int i){
	/* i행 normalize */
	int column = sizeof(data) / sizeof(data[0]);
	double a = data[i][i];
	for(int k=i;k<column;k++)
		data[i][k] /= a;
}
void R2(double **data, int i, int j, double a){
	/* j행 = j행 - i행.*a */
	int column = sizeof(data) / sizeof(data[0]);
	printf("%.5lf\n",column)
	for(int k=0;k<column;k++)
		data[j][k] = data[j][k] - data[i][k]*a;
}

