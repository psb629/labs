#include <stdio.h>
#include <math.h>

int judge_prime(int a);

int main(void) {
	int N_max=100;
	printf("양의 정수 1부터 N_max까지의 소수를 출력하는 프로그램입니다.\nN_max는 얼마로 세팅하겠습니까?");
	scanf("%d", &N_max);
	for(int n=2;n<=N_max;n++)
		if(judge_prime(n))
			printf("%d ",n);
	printf("\n");
	return 0;
}

int judge_prime(int a)
{
	double a_p = sqrt(a);
	for(int n=2;n<=a_p;n++)
		if(a % n == 0)
			return 0;
	return 1;
}
