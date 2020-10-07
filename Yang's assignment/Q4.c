#include <stdio.h>

double my_method(int a, int n);

int main(){
	int a=7, n=7;
	printf("a를 입력해주세요.");
	scanf("%d",&a);
	printf("n을 입력해주세요.");
	scanf("%d",&n);
	double x = my_method(a,n);
	printf("%.10f\n",x);

	return 0;
}

double my_method(int a, int n){
	double x=1;
	int cnt=-1;
	while(1){
		cnt++;
		double y=0, dy=1;
		for(int i=0;i<cnt;i++)
			dy*=0.1;
		while((x+y)*(x+y) < a){
			y+=dy;
		}
		y-=dy;
		x=x+y;
		if(cnt==n)
			break;
	}
	return x;
}
