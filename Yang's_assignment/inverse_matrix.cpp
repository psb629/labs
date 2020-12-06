#include <stdio.h>

float **data, *x, n;
unsigned int row, column;

void f1(){
	int i, j;
	printf("행렬의 크기\n");
	scanf("%d", &row);
	column = row * 2;
	data = new float *[row];
	for (i = 0; i < row; i++)
		data[i] = new float [column];
	printf("행렬의 성분(열 순으로)\n");
	for (i = 0; i < row; i++)
		for (j = 0; j < row; j++){
			scanf("%f", &data[i][j]);
			if (i==j)
				data[i][j+row] = 1;
			else
				data[i][j+row] = 0;
		}
 //	for(i=0;i<row;i++){
 //		for(j=0;j<column;j++)
 //			printf("%f ",data[i][j]);
 //		printf("\n");
 //	}
}
void f2(){
	float temp, n;
	int i, j, k, p;
	/* 가우스 소거 시작 */
	for(i=0;i<row-1;i++){					//i열
		for(p=i;p<row;p++)
			if(data[p][i]!=0)				//p행
				break;						//0이 아닌 첫 i열p행 탐색
		if(p==row)							//i열 전체값이 다 0인 경우
			printf("유일 해 없음\n");		//x_i에 대한 정보가 없음
		if(p!=i){							//행렬의 대각선 상의 값이 0인 경우
			for(j=i;j<column;j++){			//0이 아닌 p행과 i행 자리를 바꿈
				temp = data[i][j];
				data[i][j] = data[p][j];
				data[p][j] = temp;
			}
		}
		for(k=i+1;k<row;k++){
			n = data[k][i] / data[i][i];
			for(j=i;j<column;j++)
				data[k][j] = data[k][j] - n * data[i][j];
		}
	}
	/* 유일 해 체크*/
	if (data[row-1][row-1] == 0)			//마지막 행이 모두 0인 경우
		printf("유일 해 없음\n");
}
void f3(){
	float sum;
	unsigned int i, j, k, p, dummy;
	/* 후진 대입법 시작 */
	for (dummy = row - 1; dummy >= 0; dummy--)
	{
		if (dummy == row - 1)
			x[dummy] = data[row - 1][row] / data[row - 1][row - 1];
		else
		{
			sum = 0;
			for (j = dummy + 1; j < row; j++)
				sum += data[dummy][j] * x[j];		//전에 구한 x들과 그 계수를 곱한 것의 총합
			x[dummy] = (data[dummy][row] - sum) / data[dummy][dummy]; //dummy열의 x값 계산
		}
		printf("x[%d]=%f\n", dummy, x[dummy]);		//해 출력
	}
}
int main()
{
	f1();
			
	return 0;
}
