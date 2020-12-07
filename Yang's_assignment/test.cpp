#include <stdio.h>
#include "R.h"

double **data, *x, n;
unsigned int row, column;

void view_data(){
	int i, j;
	for(i=0;i<row;i++){
		for(j=0;j<column;j++)
			printf("%.4lf ",data[i][j]);
		printf("\n");
	}
}
void answer(){
	int i, j;
	for(i=0;i<row;i++){
		for(j=row;j<column;j++)
			printf("%.4lf ",data[i][j]);
		printf("\n");
	}
}

void f1(){
	/* 행렬을 입력받고, 확대행렬을 구성한다. */
	int i, j;
	row = 1;
	printf("행렬의 크기 n\n");
	while(row<2){
		printf("n>1 을 입력하세요.\n");
		scanf("%d", &row);
	}
	column = row*2;
	data = new double *[row];
	for(i=0;i<row;i++)
		data[i] = new double [column];
	printf("행렬의 성분(열 순으로)\n");
	for(i=0;i<row;i++)
		for(j=0;j<row;j++){
			scanf("%lf", &data[i][j]);
			if(i==j)
				data[i][j+row] = 1;
			else
				data[i][j+row] = 0;
		}
}
int f2(){
	int i=-1, j, k;
	/* a_11 가 0이면 a_i1!=0 인 행과 자리교환 */
	double a1 = 0., temp;
	while(a1==0){
		i++;
		a1 = data[i][0];
	}
	for(j=0;j<column;j++){
		temp = data[i][j];
		data[i][j] = data[0][j];
		data[0][j] = temp;
	}
	/* 가우스 소거 시작, 정방향 */
	for(i=0;i<row-1;i++)
		for(j=i+1;j<row;j++){
			temp = data[j][i]/data[i][i];
			R2(data,i,j,temp);
		}
	if(data[row-1][row-1]==0){
		printf("유일해 없음\n");
		return 0;
	}
	/* 가우스 소거 시작, 역방향 */
 	for(j=0;j<row-1;j++)
		for(i=j+1;i<row;i++){
			temp = data[j][i]/data[i][i];
			R2(data,i,j,temp);
		}
	for(i=0;i<row;i++)
		R1(data,i);
	return 0;
}
int main()
{
	f1();
	f2();
	view_data();
	answer();
	return 0;
}
