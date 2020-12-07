#include <stdio.h>

double **data;
int row, column;

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
void R2(int i, int j, double a){
	/* j행 = j행 - i행.*a */
	for(int k=0;k<column;k++)
		data[j][k] = data[j][k] - data[i][k]*a;
}
void R1(int i){
	/* i행 normalize */
	double a = data[i][i];
	for(int k=i;k<column;k++)
		data[i][k] /= a;
}
void f1(){
	/* 행렬을 입력받고, 확대행렬을 구성한다. */
//	FILE *mat;
//	sprintf(fname,"matrix.txt\0");
//	mat = fopen(fname,"r");
//	fclose(mat);
	int i, j;
	row = 1;
	printf("행렬의 크기 n\n");
	while(row<2){
		printf("n>1 을 입력하세요.\n");
		scanf("%d", &row);
	}
	column = row*2;
	/* 동적메모리 할당 */
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
			R2(i,j,temp);
		}
	if(data[row-1][row-1]==0){
		printf("유일해 없음\n");
		return 0;
	}
	/* 가우스 소거 시작, 역방향 */
 	for(j=0;j<row-1;j++)
		for(i=j+1;i<row;i++){
			temp = data[j][i]/data[i][i];
			R2(i,j,temp);
		}
	for(i=0;i<row;i++)
		R1(i);
	return 0;
}
void f3(){
	/* 동적메모리 제거 */
	for(int i=0;i<row;i++)
		delete [] data[i];
	delete [] data;
}
int main()
{
	f1();
	f2();
	view_data();
	answer();
	f3();
	return 0;
}
