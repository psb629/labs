#include <stdio.h>
#include <time.h>
#include <math.h>
#include "hk.h"	//Hoshen-Kopelman algorighm
#include "nz.h"	//Newman-Ziff algorighm

#define WORK(a)	((a==0) ? (-1):(1))
#define SD(x,y)	(x*x+y*y)	//square distance
#define PERI_t(s) (s+2)		//perimeter t is the function of a cluster size s in Bethe lattice
#define CONST_pi 3.1415926535898
#define FLIP(a) ((a<0) ? (1):(-1))
#define ABS(a) ((a<0) ? (-a):(a))
#define tau_c 2.26918531421

#define File_2D_Ising "2D_Ising_add3.dat"	//u 1:2=fig_2_26a & u 1:3=fig_2_28a
#define File_2D_percolation "2D_percolation_add.dat" //u 1:2=fig_1_14a.dat & u 1:3=fig_1_15a.dat

void init_genrand(unsigned long s);
double genrand_real1();
double genrand_real2();
double genrand_real3();
unsigned long genrand_int32();
//////////////////////////////////////////
void lecture1();	//check genrand_real2()
//2015.03.24 //과제: 오늘 한 수업 내용(diffusion)에 대한 것을 APS format의 TEX 2 page 분량으로 정리
void lecture2_1();	//2D random work, the movement is an one of the 4 directions(+x,-x,+y,-y)
void lecture2_2();	//1D random work
void lecture2_3();	
void lecture2_4();
void lecture2_5();
//2015.04.07-14 //과제: Newman-Ziff 알고리즘을 이용하여 논문에 나와있는 Fig.9와 lecture3_1의 그림을 그리고, LATEX으로 2페이지 정리
void lecture3_1();	//percolation in 1D
void lecture3_2();	//percolation in 2D with Hoshen-Kopelman algorighm
void lecture3_3();	//percolation in 2D with Newman-Ziff algorighm(http://arxiv.org/abs/cond-mat/0101295)
//////////////////////////////////////////
void lecture4();	//classical 2D Ising model
//////////////////////////////////////////
void lecture5();	//kinetic roughening in 1D through Random Deposition
//////////////////////////////////////////
//2015.06.02 //TRANSFORMATION MAETHOD: Probability Distribution Function <TRANSFORM> Cumulative Distribution Function.
void lecture6_1();	//uniform distribution
void lecture6_2();	//exponential distribution
void lecture6_3();	//normal(Gaussian) distribution
void lecture6_4();	//Lorentz distribution
void lecture6_5();	//power-law distribution
double gaussian(double variance);
//pajek(complex network program): http://vlado.fmf.uni-lj.si/pub/networks/pajek/
void lecture7_1();	//random network
void lecture7_2();	//small-world network
////////////////////////////////////////////
void test();		//test suffling numbers
////These are homworks for a lecture on 22, September
void HW1_1();		//percolation in 1D lattice
void HW1_2();		//percolation in Bethe lattice
////Soyoung's homeworks
void soyoung_1();
void soyoung_2();
void soyoung_3();
void soyoung_4();
void soyoung_5();
////Ising model
void Ising_2D();
void percolation_2D();
int main()
{
	lecture6_5();
	return 0;
}
void lecture1()
{
	init_genrand((unsigned)time(NULL));
	for(int i=0;i<10;i++)
		printf("%lf\n",genrand_real2());
}
void lecture2_1()
{
	int x=0,y=0,check;
	init_genrand((unsigned)time(NULL));
	for(int i=0;i<1e4;i++)
	{
		printf("%d\t%d\n",x,y);
		check=(int)(2*genrand_real2());
		if(WORK(check)==-1)
			x+=WORK((int)(2*genrand_real2()));	//WORK(genrand_int32()%2); 보다 나음
		else
			y+=WORK((int)(2*genrand_real2()));
	}
}
void lecture2_2()
{
	int x=0;
	double p;
	init_genrand((unsigned)time(NULL));
	for(int i=0;i<1e4;i++)
	{
		printf("%d\t%d\n",i,x);
		p=genrand_real2();
		if(p<0.5)
			x++;
		else
			x--;
	}
}
void lecture2_3()
{
	int x, count[1000];
	double p;
	init_genrand((unsigned)time(NULL));
	for(int i=0;i<1e3;i++)
		count[i]=0;
	for(int j=0;j<1e4;j++)
	{
		x=0;
		for(int i=0;i<1e4;i++)
		{
			p=genrand_real2();
			if(p<0.5)
				x++;
			else
				x--;
		}
		if(x>-500 && x<500)
			count[x+500]++;
	}
	for(int i=0;i<1e3;i++)
		printf("%d\t%d\n",i,count[i]);
}
void lecture2_5()
{
	int NoP=1e3, N=1e4;	// the Number of points
	int x[NoP], y[NoP];
	double p, r[N];
	init_genrand((unsigned)time(NULL));
	for(int i=0;i<NoP;i++)
	{
		x[i]=0;
		y[i]=0;
	}
	for(int j=0;j<N;j++)
		r[j]=0.;
	for(int i=0;i<N;i++)
	{
		for(int j=0;j<NoP;j++)
		{
			p=genrand_real2();
			if(p<0.25)
				x[j]++;
			else if(p<0.5)
				x[j]--;
			else if(p<0.75)
				y[j]++;
			else
				y[j]--;
			r[i]+=SD(x[j],y[j]);
		}
		r[i]/=NoP;
		printf("%d\t%.8f\n",i+1,r[i]);
	}
}
void lecture3_1()
{
	int L=2e2, *exist, *n, ensembles=1e3;
	int *log_n, N_occupation=0;
	double *Nden;	//the cluster number density, n(s,p)=n/L
	double Nave;	//the average cluster size, x(p)=SUM_{k=1}^{N_clusters}{s_{k}^{2}}/N_occupation
	double p;
	
	init_genrand((unsigned)time(NULL));
	
	exist=new int[L];
	n=new int[L+1];
	log_n=new int[L+1];
	Nden=new double[L+1];
	
	for(int x=2;x<=16;x*=2)
	{
		p=1.-1./((double)x);
		for(int i=0;i<=L;i++)
			n[i]=0;
		for(int iter=0;iter<ensembles;iter++)
		{
			for(int i=0;i<L;i++)
			{
				if(genrand_real2()<p)
					exist[i]=1;
				else
					exist[i]=0;
			}
			int count=0, recount;
			for(int i=0;i<L;i++)
			{
				if(exist[i])
				{
					count++;
					if(count==L)
					{
						n[L]=1;
						break;
					}
					if(i==L-1)
					{
						n[recount]--;
						n[recount+count]++;
						break;
					}
				}
				else
				{
					if(i+1==count)
						recount=count;
					n[count]++;
					count=0;
				}
			}
		}
		for(int i=1;i<=L;i++)
		{
			Nden[i]=n[i]/((double)ensembles*L);
			printf("%.4e\t%d\t%d\t%.5e\n",p,i,n[i],Nden[i]);
		}
	//the average cluster size, x(p)=SUM_{k=1}^{N_clusters}{s_{k}^{2}}/N_occupation
	}
	delete [] exist;
	delete [] n;
	delete [] log_n;
	delete [] Nden;
}
void lecture3_2()
{
	int **occupation;
	int M=64, N=64, L=M*N, ensembles=100;
	int *cluster_size, *n;
	double *Nden;	//the cluster number density, n(s,p)=n/L
	double Nave;	//the average cluster size, x(p)=SUM_{k=1}^{N_clusters}{s_{k}^{2}}/N_occupation
	double p;
	init_genrand((unsigned)time(NULL));
	
	occupation=new int *[M];
	for(int i=0;i<M;i++)
		occupation[i]=new int [N];
	cluster_size=new int [L];
	n=new int [L];
	Nden=new double [L];

	p=0.495;
	for(int i=0;i<L;i++)
		n[i]=0;
	for(int sample=0;sample<ensembles;sample++)
	{
		for(int i=0;i<L;i++)
			cluster_size[i]=0;
		for(int i=0;i<M;i++)
			for(int j=0;j<N;j++)
			{
				if(genrand_real2()<p)
					occupation[i][j]=1;
				else
					occupation[i][j]=0;
			}
		//print_matrix(occupation,M,N);	printf("\n");
		hoshen_kopelman(occupation,M,N);
		//print_matrix(occupation,M,N);
		for(int count=1;count<L;count++)
		{
			for(int i=0;i<M;i++)
				for(int j=0;j<N;j++)
				{
					if(occupation[i][j]==count)
						cluster_size[count]++;
				}
			n[cluster_size[count]]++;
		}
	}
	for(int i=1;i<L;i++)
	{
		Nden[i]=n[i]/((double)ensembles*L);
		printf("%.4e\t%d\t%d\t%.5e\n",p,i,n[i],Nden[i]);
	}
	for(int i=0;i<M;i++)
		delete [] occupation[i];
	delete [] occupation;
	delete [] cluster_size;
	delete [] n;
	delete [] Nden;
}
void lecture3_3()
{
	int L=128;
	int N=(L*L);
	double p=1.;
	int **nn, *order, *ptr;

	nn=new int *[N];
	for(int i=0;i<N;i++)
		nn[i]=new int [4];
	order=new int [N];
	ptr=new int [N];
	
	nz_boudnaries(nn,L,N);
	nz_permutation(order,N);
	nz_percolate(nn,order,ptr,N,p);

	/*for(int i=0;i<N;i++)
	{
		if(i%L==0 && i!=0)
			printf("\n");
		printf("%d\t",ptr[i]);
	}*/
	
	for(int i=0;i<N;i++)
		delete [] nn[i];
	delete [] nn;
	delete [] order;
	delete [] ptr;
}
void lecture4()
{
	init_genrand((unsigned)time(NULL));
	int L=50, **s;
	double beta=1.;	//Boltzmann distribution

	s=new int *[L];
	for(int i=0;i<L;i++)
		s[i]=new int [L];
	//initializing spins//
	for(int i=0;i<L;i++)
		for(int j=0;j<L;j++)
		{
			if(0.5<genrand_real2())
				s[i][j]=1;
			else
				s[i][j]=-1;
		}
	//magnetization//
	double M=0.;
	for(int a=0;a<L;a++)
		for(int b=0;b<L;b++)
			M+=s[a][b];
	printf("#time\tm\n");
	for(int iter=0;iter<1e6;iter++)
	{
		//random sampling//
		int i=(int)(L*genrand_real2()), j=(int)(L*genrand_real2());
		//calculate the dE//
		double dE=2.*(s[i][j]*s[(i+1)%L][j]+s[i][j]*s[(i-1+L)%L][j]+s[i][j]*s[i][(j+1)%L]+s[i][j]*s[i][(j-1+L)%L]);
		//Metropolis algorithm//
		if(dE<=0.)
		{
			s[i][j]=-s[i][j];
			M+=2*s[i][j];
		}
		else
			if(genrand_real3()<exp(-dE*beta))
			{
				s[i][j]=-s[i][j];
				M+=2*s[i][j];
			}
		printf("%d\t%.8f\n",iter+1,M/(L*L));
	}
	for(int i=0;i<L;i++)
		delete [] s[i];
	delete [] s;
}
void lecture5()
{
	init_genrand((unsigned)time(NULL));
	int L=400, *height;
	int N=100;	//time steps
	double m_h;	//mean height
	double w;	//interface width
	height=new int [L];

	for(int i=0;i<L;i++)
		height[i]=0;
	for(int t=0;t<(N*L);t++)
	{	
		/*mean height*/
		m_h=0.;
		for(int j=0;j<L;j++)
			m_h+=height[j];
		m_h*=1./(double)L;
		/*interface width*/
		w=0.;
		for(int j=0;j<L;j++)
			w+=(height[j]-m_h)*(height[j]-m_h);
		w=pow(w/L,0.5);
		/*print results*/
		if(t%(1*L)==0)
			for(int j=0;j<L;j++)
				printf("%d\t%d\t%d\t%.8e\t%.8e\n",(int)t/L,j,height[j],m_h,w);
		int i=(int)L*genrand_real2();
		height[i]++;
	}
	delete [] height;
}
void lecture6_1()
{
	init_genrand((unsigned)time(NULL));
	int iter=1e5, *N, CDF=0;
	double a=0.5, b=1.0;	//distribution region [a,b)
	double dx=1e-2;
	double x;
	
	int num_samples=(int)((b-a)/dx);
	N=new int [num_samples];
	
	for(int i=0;i<num_samples;i++)
		N[i]=0;
	for(int i=0;i<iter;i++)
	{
		x=(b-a)*genrand_real2();	//qauntile function
		N[(int)(x/dx)]++;
	}
	for(int i=0;i<num_samples;i++)
	{
		CDF+=N[i];
		/*x PDF CDF*/
		printf("%.8e\t%.8e\t%.8e\n",(double)(a+i*dx),N[i]/(double)(dx*iter),CDF/(double)iter);
	}
	delete [] N;
}
void lecture6_2()
{
	init_genrand((unsigned)time(NULL));
	int iter=1e5, *N, CDF=0;
	double a=0., b=5.;	//distribution region [a,b)
	double dx=1e-2, lambda=2.;
	double x;
	
	int num_samples=(int)((b-a)/dx);
	N=new int [num_samples];
	
	for(int i=0;i<num_samples;i++)
		N[i]=0;
	for(int i=0;i<iter;i++)
	{
		x=-log(1.-genrand_real2())/lambda;	//qauntile function
		if((int)(x/dx)>=num_samples)
			continue;
		N[(int)(x/dx)]++;
	}
	for(int i=0;i<num_samples;i++)
	{
		CDF+=N[i];
		/*x PDF CDF*/
		printf("%.8e\t%.8e\t%.8e\n",(double)(a+i*dx),N[i]/(double)(dx*iter),CDF/(double)iter);
	}
	delete [] N;
}
void lecture6_3()
{
	init_genrand((unsigned)time(NULL));
	int iter=1e7, *N, CDF=0;
	int count=0;
	double a=-5., b=5.;	//distribution region [a,b)
	double mean=1.0;	//mean value
	double dx=1.e-2;
	double x,y;
	
	int num_samples=(int)((b-a)/dx);
	N=new int [num_samples];
	
	for(int i=0;i<num_samples;i++)
		N[i]=0;
	for(int i=0;i<iter;i++)
	{
		x=gaussian(3.0);	//qauntile function
		double j=(x/dx);
		if(-0.5*num_samples<j && j<0.5*num_samples)
		{
			N[(int)(j+0.5*num_samples)]++;
			count++;
		}
	}
	for(int i=0;i<num_samples;i++)
	{
		CDF+=N[i];
		/*x PDF CDF*/
		printf("%.8e\t%.8e\t%.8e\n",(double)(a+i*dx)+mean,N[i]/(double)(dx*count),CDF/(double)count);
	}
	delete [] N;
}
double gaussian(double variance)
{
	static bool flag=true;
	static double reserve;
	if(flag)
	{
		double u,v,s,factor;
		do{
			u=2.0*genrand_real2()-1.0;
			v=2.0*genrand_real2()-1.0;
			s=u*u+v*v;
		}while(s==0.0 || s>=1.0);
		factor=sqrt(-2.0*variance*log(s)/s);
		reserve=u*factor;
		flag=false;
		return v*factor;
	}
	else
	{
		flag=true;
		return reserve;
	}
}
void lecture6_4()
{
	init_genrand((unsigned)time(NULL));
	int iter=1e5, *N, CDF=0;
	double a=0., b=10.;	//distribution region [a,b)
	double median=1.0;
	double gamma=2.0;
	double dx=1e-2;
	double x;
	int count=0;
	
	int num_samples=(int)((b-a)/dx);
	N=new int [num_samples];
	
	for(int i=0;i<num_samples;i++)
		N[i]=0;
	for(int i=0;i<iter;i++)
	{
		x=gamma*tan(CONST_pi*(genrand_real2()-0.5))+median;	//qauntile function
		double j=x/dx;
		if(-0.5*num_samples<j && j<0.5*num_samples)
		{
			N[(int)(j+0.5*num_samples)]++;
			count++;
		}
	}
	for(int i=0;i<num_samples;i++)
	{
		CDF+=N[i];
		/*x PDF CDF*/
		printf("%.8e\t%.8e\t%.8e\n",(double)(a+i*dx),N[i]/(double)(dx*count),CDF/(double)count);
	}
	delete [] N;
}
void lecture6_5()
{
	init_genrand((unsigned)time(NULL));
	int iter=1e5, *N, CDF=0;
	double a=0., b=5.;	//distribution region [a,b)
	double mode=1.0;
	double alpha=2.5;
	double dx=1e-2;
	double x;
	int count=0;
	
	int num_samples=(int)((b-a)/dx);
	N=new int [num_samples];
	
	for(int i=0;i<num_samples;i++)
		N[i]=0;
	for(int i=0;i<iter;i++)
	{
		x=mode*pow(1.-genrand_real2(),-1.0/alpha);	//qauntile function
		double j=x/dx;
		if(j<num_samples)
		{
			N[(int)j]++;
			count++;
		}
	}
	for(int i=0;i<num_samples;i++)
	{
		CDF+=N[i];
		/*x PDF CDF*/
		printf("%.8e\t%.8e\t%.8e\n",(double)(a+i*dx),N[i]/(double)(dx*count),CDF/(double)count);
	}
	delete [] N;
}
void lecture7_1()
{
	init_genrand((unsigned)time(NULL));
	FILE *result;
	double p=0.1;
	int N=1000, *num_of_link, *count;
	num_of_link=new int [N];
	count=new int [N];
	result=fopen("random.net","w");
	fprintf(result,"*Vertices %d\n",N);
	for(int i=0;i<N;i++)
	{
		num_of_link[i]=0;
		count[i]=0;
		fprintf(result,"%d \"%d\"\n",i+1,i+1);
	}
	fprintf(result,"*Edges\n");
	for(int i=0;i<N;i++)
	{
//		int count=0;
		for(int j=i+1;j<N;j++)
		{
			if(genrand_real2()<p)
			{
				fprintf(result,"%d %d\n",i+1,j+1);
				num_of_link[i]++;
//				if(count==0)
//					fprintf(result,"%d %d ",i+1,j+1);
//				else
//					fprintf(result,"%d ",j+1);
//				count++;
			}
		}
//		if(count!=0)
//			fprintf(result,"\n");
	}
	for(int i=0;i<N;i++)
		count[num_of_link[i]]++;
	for(int i=0;i<N;i++)
		printf("%d %d\n",i,count[i]);
	fclose(result);
	delete [] num_of_link;
	delete [] count;
}
void lecture7_2()
{
	init_genrand((unsigned)time(NULL));
	FILE *result;
	bool **link;
	double p=0.1;
	int N=1000, *num_of_link, *count;
	link=new bool *[N];
	for(int i=0;i<N;i++)
		link[i]=new bool [N];
	num_of_link=new int [N];
	count=new int [N];
	result=fopen("random.net","w");
	fprintf(result,"*Vertices %d\n",N);
	for(int i=0;i<N;i++)
	{
		for(int j=0;j<N;j++)
			link[i][j]=false;
		link[i][(i+1)%N]=true; link[i][(i+2)%N]=true; link[i][(i-1+N)%N]=true;
		num_of_link[i]=0;
		count[i]=0;
		fprintf(result,"%d \"%d\"\n",i+1,i+1);
	}
	fprintf(result,"*Edges\n");
	for(int i=0;i<N;i++)
	{
		for(int j=0;j<N;j++)
		{
			if(genrand_real2()<p)
			{
				fprintf(result,"%d %d\n",i+1,j+1);
				num_of_link[i]++;
			}
		}
	}
	for(int i=0;i<N;i++)
		count[num_of_link[i]]++;
	for(int i=0;i<N;i++)
		printf("%d %d\n",i,count[i]);
	fclose(result);
	for(int i=0;i<N;i++)
		delete [] link[i];
	delete [] link;
	delete [] num_of_link;
	delete [] count;
}
void test()	//suffler
{
	init_genrand((unsigned)time(NULL));
	int *order, N=150;
	order=new int [N];
	for(int i=0;i<N;i++)
		order[i]=i;
	for(int i=0;i<N;i++)
	{
		int j=i+(N-i)*genrand_real3();
		int temp=order[i];
		order[i]=order[j];
		order[j]=temp;
	}
	for(int i=0;i<N;i++)
		printf("%3d ",1+order[i]);
	delete [] order;
}
void HW1_1()
{
	int L=1e4, *exist, *n, ensembles=1e4;
	int *log_n, N_occupation=0;
	double *Nden;	//the cluster number density, n(s,p)=n/L
	double Nave;	//the average cluster size, x(p)=SUM_{k=1}^{N_clusters}{s_{k}^{2}}/N_occupation
	double p;
	
	init_genrand((unsigned)time(NULL));
	
	exist=new int[L];
	n=new int[L+1];
	log_n=new int[L+1];
	Nden=new double[L+1];
	
//	for(int x=2;x<=16;x*=2)
	{
		int x=2;
		p=1.-1./((double)x);
		for(int i=0;i<=L;i++)
			n[i]=0;
		for(int iter=0;iter<ensembles;iter++)
		{
			for(int i=0;i<L;i++)
			{
				if(genrand_real2()<p)
					exist[i]=1;
				else
					exist[i]=0;
			}
			int count=0, recount;
			for(int i=0;i<L;i++)
			{
				if(exist[i])
				{
					count++;
					if(count==L)
					{
						n[L]=1;
						break;
					}
					if(i==L-1)
					{
						n[recount]--;
						n[recount+count]++;
						break;
					}
				}
				else
				{
					if(i+1==count)
						recount=count;
					n[count]++;
					count=0;
				}
			}
		}
		for(int i=1;i<=L;i++)
		{
			Nden[i]=n[i]/((double)ensembles*L);
			printf("%.4e\t%d\t%d\t%.5e\n",p,i,n[i],Nden[i]);
		}
	//the average cluster size, x(p)=SUM_{k=1}^{N_clusters}{s_{k}^{2}}/N_occupation
	}
	delete [] exist;
	delete [] n;
	delete [] log_n;
	delete [] Nden;
}
void HW1_2()
{
	int L=1e4, ensembles=1e4;
	int l=1e2;	//The lattice has l-th sub-branches
	int z=3;	//the number of nearest neighbours
	int *exist;	//check a site for occupancy
	double *N_den;	//the cluster number density, n(s,p)=n/L
	double N_ave;	//the average cluster size, x(p)=SUM_{k=1}^{N_clusters}{s_{k}^{2}}/N_occupation
	double p;
	
	init_genrand((unsigned)time(NULL));

	N_den=new double [(int)(1+3*(pow(2,l)-1))];
	exist=new int [(int)(1+3*(pow(2,l)-1))];

	

	delete [] N_den;
	delete [] exist;
}
void soyoung_1()
{
	init_genrand((unsigned)time(NULL));
	double x=0., y=0.;
	double theta;

	for(int i=0;i<1e3;i++)
	{
		theta=2.*CONST_pi*genrand_real2();
		x+=cos(theta);
		y+=sin(theta);
		printf("%d\t%.8e\t%.8e\n",i,x,y);
	}
}
void soyoung_2()
{
	init_genrand((unsigned)time(NULL));
	int N=1e3;
	double *x, *y;
	double theta, r;

	x=new double [N];
	y=new double [N];
	for(int n=0;n<N;n++)
	{
		x[n]=0.;
		y[n]=0.;
	}
	for(int i=0;i<1e3;i++)
	{
		r=0.;
		for(int n=0;n<N;n++)
		{
			theta=2.*CONST_pi*genrand_real2();
			x[n]+=cos(theta);
			y[n]+=sin(theta);
			r+=x[n]*x[n]+y[n]*y[n];
		}
		printf("%d\t%.8e\n",i+1,r/((double)N));
	}
	delete [] x;
	delete [] y;
}
void soyoung_3()
{
	init_genrand((unsigned)time(NULL));
	int tot_samp=1e5;	//total number of samples
	int N=1e2;
	int count[N];
	double x, y, r;
	double theta;

	for(int n=0;n<N;n++)
		count[n]=0;
	for(int iter=0;iter<tot_samp;iter++)
	{
		x=0.;	y=0.;
		r=0.;
		for(int i=0;i<1e3;i++)
		{
			theta=2.*CONST_pi*genrand_real2();
			x+=cos(theta);
			y+=sin(theta);
		}
		r=pow(x*x+y*y,0.5);
		if(r<N)
			count[(int)(r)]++;
	}
	for(int n=0;n<N;n++)
		printf("%.4e\t%d\n",(double)(n),count[n]);
}
void soyoung_4()
{
	init_genrand((unsigned)time(NULL));
	int N=1e3, sample=1e3, *ball;
	int count;
	int choose1, choose2;
	bool loop=true;
	double total=0.;
	ball=new int [N];
	for(int iter=0;iter<sample;iter++)
	{
		for(int i=0;i<N;i++)
			ball[i]=i;
		loop=true;
		count=0;
		while(loop)
		{
			choose1=(int)(N*genrand_real2());
			choose2=(int)(N*genrand_real2());
			ball[choose2]=ball[choose1];
			count++;
			for(int i=0;i<N;i++)
			{
				if(ball[0]!=ball[i])
					break;
				if(i==N-1)
					loop=false;
			}
		}
		total+=count;
	}
	printf("#(N-1)**2\t<N>\n");
	printf("%.8f\t%.8f",pow((double)(N-1),2.),total/((double)sample));
	delete [] ball;
}
void soyoung_5()
{
	int a;
}
void Ising_2D()
{
	init_genrand((unsigned)time(NULL));
	int L=100, LSQ=L*L;
	int sample=1;
	int M;
	double df;	//delta(free energy)
	double magnet, energy;
	double beta, tau;
	FILE *result;
	result=fopen(File_2D_Ising,"w");
	fprintf(result,"#L=%dx%d\n#tau/tau_c\t<m>\t\tE\n",L,L);
	fclose(result);
	int **spin;
	spin=new int *[L];
	for(int i=0;i<L;i++)
		spin[i]=new int [L];
	for(tau=0.9801*tau_c;tau<1.02*tau_c;tau+=0.001*tau_c)
	{
		beta=(tau<1.e-15)?(1.e6):(1./tau);
		magnet=0.;
		for(int avg=0;avg<sample;avg++)
		{
			M=0;	energy=0.;
			for(int i=0;i<L;i++)
			for(int j=0;j<L;j++)
				spin[i][j]=(0.5-genrand_real2()<0)?(-1):(1);
			for(int sweep=0;sweep<10*LSQ;sweep++)
			{
				for(int i=0;i<L;i++)
				for(int j=0;j<L;j++)
				{
					//calculate the df//
					df=2.*spin[i][j]*(spin[(i+1)%L][j]+spin[(i-1+L)%L][j]+spin[i][(j+1)%L]+spin[i][(j-1+L)%L]);
					//Metropolis algorithm//
					if(df<=0.)
						spin[i][j]=FLIP(spin[i][j]);
					else
					if(genrand_real2()<exp(-df*beta))
						spin[i][j]=FLIP(spin[i][j]);
				}
			}
			for(int i=0;i<L;i++)
			for(int j=0;j<L;j++)
			{
				M+=spin[i][j];
				energy-=0.5*spin[i][j]*(spin[(i+1)%L][j]+spin[(i-1+L)%L][j]+spin[i][(j+1)%L]+spin[i][(j-1+L)%L]);
			}
			magnet+=ABS(M);
		}
		result=fopen(File_2D_Ising,"a");
		fprintf(result,"%.8e\t%.8e\t%.8e\n",tau/tau_c,magnet/((double)LSQ*sample),energy/((double)LSQ*sample));
		fclose(result);
	}
	for(int i=0;i<L;i++)
		delete [] spin[i];
	delete [] spin;
}
void percolation_2D()
{
	int **occupation;
	int M=128, N=128, L=M*N, ensembles=1e4;
	int percolating_cluster_size;
	int *cluster_size, *n;	//cluster_size[i] is a cluster size of label i, n[i] is a number of clusters size of i
	double *Nden;	//the cluster number density, n(s,p)=n/L
	double Nave;	//the average cluster size, x(p)=SUM_{k=1}^{N_clusters}{s_{k}^{2}}/N_occupation
	double p;
	double P_infty;	//the probability of an existance of an infinite cluster sizea
	double denominator, numerator;
	bool percolation;
	FILE *result;
	init_genrand((unsigned)time(NULL));
	
	occupation=new int *[M];
	for(int i=0;i<M;i++)
		occupation[i]=new int [N];
	cluster_size=new int [L];
	n=new int [L];
	Nden=new double [L];

	result=fopen(File_2D_percolation,"w");
	fprintf(result,"#L=%dx%d\n#p\t\tP_infty(p)\tX(p)\n",M,N);
	fclose(result);
	for(p=0.55;p<0.7;p+=0.0002)
	{
		for(int i=0;i<L;i++)
			n[i]=0;
		P_infty=0.;
		for(int sample=0;sample<ensembles;sample++)
		{
			for(int i=0;i<L;i++)
				cluster_size[i]=0;
			for(int i=0;i<M;i++)
			for(int j=0;j<N;j++)
			{
				if(genrand_real2()<p)
					occupation[i][j]=1;
				else
					occupation[i][j]=0;
			}
			hoshen_kopelman(occupation,M,N);
			/*for(int count=1;count<L;count++)
			{
				for(int i=0;i<M;i++)
				for(int j=0;j<N;j++)
					if(occupation[i][j]==count)
						cluster_size[count]++;
				n[cluster_size[count]]++;
			}*/
			for(int i=0;i<M;i++)
			for(int j=0;j<N;j++)
				cluster_size[occupation[i][j]]++;
			for(int i=1;i<L;i++)
				n[cluster_size[i]]++;
			//check percolation//
			percolation=false;
			percolating_cluster_size=0;
			for(int i=0;i<M&&!percolation;i++)
			for(int j=0;j<M&&!percolation;j++)
			{
				if(occupation[i][0]>0)
					if(occupation[i][0]==occupation[j][N-1])
					{
						percolation=true;
						percolating_cluster_size=cluster_size[occupation[i][0]];
					}
			}
			for(int i=0;i<N&&!percolation;i++)
			for(int j=0;j<N&&!percolation;j++)
			{
				if(occupation[0][i]>0)
					if(occupation[0][i]==occupation[M-1][j])
					{
						percolation=true;
						percolating_cluster_size=cluster_size[occupation[0][i]];
					}
			}
			if(percolation)
				P_infty+=percolating_cluster_size/(double)L;
		}
		P_infty/=(double)ensembles;
		denominator=0.;	numerator=0.;
		for(int i=1;i<L*(1.-P_infty);i++)
		{
			Nden[i]=n[i]/((double)ensembles*L);
			denominator+=i*Nden[i];
			numerator+=i*i*Nden[i];
		}
		//printf("p=%.3f\tnumerator=%.8e\tdenominator=%.8e\tp-P_infty=%.8e\n",p,numerator,denominator,p-P_infty);
		Nave=(numerator==0.)?(0.):(numerator/denominator);
		result=fopen(File_2D_percolation,"a");
		fprintf(result,"%.8e\t%.8e\t%.8e\n",p,P_infty,Nave);
		fclose(result);
	}
	for(int i=0;i<M;i++)
		delete [] occupation[i];
	delete [] occupation;
	delete [] cluster_size;
	delete [] n;
	delete [] Nden;
}
