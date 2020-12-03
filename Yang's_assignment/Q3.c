#include <stdio.h>

double Babylonian(int a, int iter);

int main(){
	int a=7, iter=10;
	printf("a를 입력해주세요.");
	scanf("%d",&a);
	printf("iter를 입력해주세요.");
	scanf("%d",&iter);
	double x = Babylonian(a,iter);
	printf("%.5f\n",x);

	return 0;
}

double Babylonian(int a, int iter){
	double x=1;
	for(int i=0;i<iter;i++)
		x = 0.5*(x+a/x);
	return x;
}
