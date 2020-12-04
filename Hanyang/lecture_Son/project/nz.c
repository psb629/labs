#include <cstdio>
#include <ctime>
#include "nz.h"

void init_genrand(unsigned long s);
double genrand_real2();
double genrand_real3();
unsigned long genrand_int32();

int nz_findroot(int *ptr, int i)	//ptr[N]: Array of pointers
{
	if(ptr[i]<0) return i;
	return ptr[i]=nz_findroot(ptr, ptr[i]);
}
void nz_boudnaries(int **nn, int L, int N)	//nn[N][4], L: Linear dimension, N: Number of sites(=L*L)
{
	for(int i=0;i<N;i++)
	{
		nn[i][0]=(i+1)%N;
		nn[i][2]=(i+N-1)%N;
		nn[i][2]=(i+L)%N;
		nn[i][3]=(i+N-L)%N;
		if(i%L==0)
			nn[i][1]=i+L-1;
		if((i+1)%L==0)
			nn[i][0]=i-L+1;
	}
}
void nz_permutation(int *order, int N)	//order[N]: Occupation order
{
	init_genrand((unsigned)time(NULL));
	for(int i=0;i<N;i++)
		order[i]=i;
	for(int i=0;i<N;i++)
	{
		int j=i+(N-i)*genrand_real3();
		int temp=order[i];
		order[i]=order[j];
		order[j]=temp;
	}
}
void nz_percolate(int **nn, int *order, int *ptr, int N, double p)
{
	init_genrand((unsigned)time(NULL));
	int s1,s2,r1,r2;
	int big=0;
	int EMPTY=-N-1;
	for(int i=0;i<N;i++)
		ptr[i]=EMPTY;
	int iter=((N*p) > (N) ? (N) : ((int)N*p));
	for(int i=0;i<iter;i++)
	{
		r1=s1=order[i];
		ptr[s1]=-1;
		for(int j=0;j<4;j++)
		{
			s2=nn[s1][j];
			if(ptr[s2]!=EMPTY)
			{
				r2=nz_findroot(ptr,s2);
				if(r2!=r1)
				{
					if(ptr[r1]>ptr[r2])
					{
						ptr[r2]+=ptr[r1];
						ptr[r1]=r2;
						r1=r2;
					}
					else
					{
						ptr[r1]+=ptr[r2];
						ptr[r2]=r1;
					}
					if(-ptr[r1]>big)
						big=-ptr[r1];
				}
			}
		}
		printf("%d %d\n",i+1,big);
	}
}
