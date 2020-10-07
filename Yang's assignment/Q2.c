#include <stdio.h>
#include <math.h>

int judge_prime(int a);

int main(void) {
	int N=50;
	printf("몇 번째 소수 출력을 원하십니까?");
	scanf("%d", &N);
	int i=2, cnt=0;
	while(1){
		if(judge_prime(i))
			cnt++;
		if(cnt==N){
			printf("%d\n",i);
			break;
		}
		i++;
	}
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
