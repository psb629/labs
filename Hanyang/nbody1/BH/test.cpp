#include <iostream>
#include <cstdio>
#include <ctime>
#include <cmath>
#include "utils.h"
#include "mt19937ar.h"
#include <stdlib.h>
using namespace std;

#define M 4
#define N 4
#define LDA M
#define LDU M
#define LDVT N

void test_dgesvd();
void test_zgesvd();
void test_SUBLOUTINE_ZGESVD();
void test_printf_binary();
void test_timer();
void test_string_filename();
void test_char_filename();
void test_fscanf();
int main()
{
	char *name;
	name="name1\0";
	printf("%s\n",name);
	name="name2\0";
	printf("%s\n",name);
	name="name3\0";
	printf("%s\n",name);
	return 0;
}
void test_dgesvd()
{
	long int m = M, n = N, lda = LDA, ldu = LDU, ldvt = LDVT, info=0, lwork;
	double wkopt;
	double *work;
	/* Local arrays */
	double s[min(M,N)], u[LDU*M], vt[LDVT*N];
	double a[LDA*N], backup_a[LDA*N];

	init_genrand((unsigned)time(NULL));
	for(int i=0;i<lda;i++)
		for(int j=0;j<N;j++)
			a[j+i*lda]=backup_a[j+i*lda]=genrand_real1()-0.5;

	/* Executable statements */
	printf( "\n///////////// DGESVD Example Program Results /////////////\n\n" );
	/* Query and allocate the optimal workspace */
	lwork = -1;
	dgesvd_( "A", "A", &m, &n, a, &lda, s, u, &ldu, vt, &ldvt, &wkopt, &lwork, &info );
	lwork = (int)wkopt;
//	work = (double*)malloc( lwork*sizeof(double) );
	work = new double [lwork*sizeof(double)];

	printf("info=%ld\n",info);
	/* Print original vectors */
	print_array( "Original vectors before zgesvd (M-by-N)", m, n, a);

	/* Compute SVD */
	dgesvd_( "A", "A", &m, &n, a, &lda, s, u, &ldu, vt, &ldvt, work, &lwork, &info );
	/* Check for convergence */
	if( info > 0 ) {
		printf( "The algorithm computing SVD failed to converge.\n" );
		exit( 1 );
	}
	/* Print singular values */
	print_array( "Singular values (min(M,N))", 1, min(m,n), s);
	/* Print left singular vectors */
	print_array( "Left singular vectors (stored columnwise, M-by-M)", m, m, u);
	/* Print right singular vectors */
	print_array( "Right singular vectors (stored rowwise N-by-N)", n, n, vt);

	for(int i=0;i<M;i++)
		for(int j=0;j<N;j++)
		{
			a[i+j*lda]=0.;
			for(int k=0;k<min(M,N);k++)
				a[i+j*lda]+=u[i+k*ldu]*s[k]*vt[k+j*ldvt];
			a[i+j*lda]-=backup_a[i+j*lda];
		}
	print_array( "usvt-a (M by N)", m, n, a);
	printf( "//////////////////////////////////////////////////////////\n" );

	/* Free workspace */
//	free( (void*)work );
	delete [] work;
	exit( 0 );
} /* End of DGESVD Example */
void test_zgesvd()
{
	/* Locals */
	long int m = M, n = N, lda = LDA, ldu = LDU, ldvt = LDVT, info=0, lwork;
	doublecomplex wkopt;
	doublecomplex* work;
	/* Local arrays */
	/* rwork dimension should be at least max( 1, 5*min(m,n) ) */
	double s[min(m,n)], rwork[5*min(m,n)];
	doublecomplex u[LDU*M], vt[LDVT*N];
	doublecomplex a[LDA*N], backup_a[LDA*N];
/*	doublecomplex a[LDA*N] = {
	{ 5.91, -5.69}, {-3.15, -4.08}, {-4.89,  4.20},
	{ 7.09,  2.72}, {-1.89,  3.27}, { 4.10, -6.70},
	{ 7.78, -4.06}, { 4.57, -2.07}, { 3.28, -3.84},
	{-0.79, -7.21}, {-3.88, -3.30}, { 3.84,  1.19}};*/

	init_genrand((unsigned)time(NULL));
	for(int i=0;i<lda;i++)
		for(int j=0;j<N;j++)
		{
			a[i+j*lda].r=genrand_real1()-0.5;
			a[i+j*lda].i=0.;
			backup_a[i+j*lda].r=a[i+j*lda].r;
			backup_a[i+j*lda].i=a[i+j*lda].i;
		}
	/* Executable statements */
	printf( "\n///////////// ZGESVD Example Program Results /////////////\n\n" );
	/* Query and allocate the optimal workspace */
	lwork = -1;
	zgesvd_( "A", "A", &m, &n, a, &lda, s, u, &ldu, vt, &ldvt, &wkopt, &lwork, rwork, &info );
	lwork = (int)wkopt.r;
//	work = (doublecomplex*)malloc( lwork*sizeof(doublecomplex) );
	work = new doublecomplex [lwork*sizeof(doublecomplex)];
	
	/* Print original vectors */
	print_carray( "Original vectors before zgesvd (M-by-N)", m, n, a);
	
	/* Compute SVD */
	zgesvd_( "A", "A", &m, &n, a, &lda, s, u, &ldu, vt, &ldvt, work, &lwork, rwork, &info );

	printf("info=%ld\n",info);
	/* Check for convergence */
        if( info > 0 ) {
                printf( "The algorithm computing SVD failed to converge.\n" );
                exit( 1 );
	}
	/* Print original vectors */
	print_carray( "Original vectors after zgesvd, be durty (M-by-N)", m, n, a);
	/* Print singular values */
	print_array( "Singular values (min(M,N))", 1, min(m,n), s);
	/* Print left singular vectors */
	print_carray( "Left singular vectors (stored columnwise, M-by-M)", m, m, u);
	/* Print right singular vectors */
	print_carray( "Right singular vectors (stored rowwise N-by-N)", n, n, vt);
	
	for(int i=0;i<M;i++)
		for(int j=0;j<N;j++)
		{
			a[i+j*lda].r=0.;
			a[i+j*lda].i=0.;
			for(int k=0;k<min(M,N);k++)
			{
				a[i+j*lda].r+=u[i+k*ldu].r*s[k]*vt[k+j*ldvt].r-u[i+k*ldu].i*s[k]*vt[k+j*ldvt].i;
				a[i+j*lda].i+=u[i+k*ldu].r*s[k]*vt[k+j*ldvt].i+u[i+k*ldu].i*s[k]*vt[k+j*ldvt].r;
			}
			a[i+j*lda].r-=backup_a[i+j*lda].r;
			a[i+j*lda].i-=backup_a[i+j*lda].i;
		}
	print_carray( "usvt-a (M by N)", m, n, a);
	printf( "//////////////////////////////////////////////////////////\n" );

	/* Free workspace */
//	free( (void*)work );
	delete [] work;
	exit( 0 );
}
void test_SUBLOUTINE_ZGESVD()
{
	integer m=M, n=N;
	integer lda=LDA, ldu=LDU, ldvt=LDVT;
	double s[min(m,n)];
	doublecomplex u[LDU*M], vt[LDVT*N];
	doublecomplex a[LDA*N], backup_a[LDA*N];

	init_genrand((unsigned)time(NULL));
	for(int i=0;i<lda;i++)
		for(int j=0;j<N;j++)
		{
			a[i+j*lda].r=genrand_real1()-0.5;
			a[i+j*lda].i=genrand_real1()-0.5;
			backup_a[i+j*lda].r=a[i+j*lda].r;
			backup_a[i+j*lda].i=a[i+j*lda].i;
		}
	/* Executable statements */
	printf( "\n///////////// ZGESVD Example Program Results /////////////\n\n" );
	
	/* Print original vectors */
	print_carray( "Original vectors before zgesvd (M-by-N)", m, n, a);
	
	/* Compute SVD */
	SUBLOUTINE_ZGESVD(a,u,s,vt,M,N);

	/* Print original vectors */
	print_carray( "Original vectors after zgesvd, be durty (M-by-N)", m, n, a);
	/* Print singular values */
	print_array( "Singular values (min(M,N))", 1, min(m,n), s);
	/* Print left singular vectors */
	print_carray( "Left singular vectors (stored columnwise, M-by-M)", m, m, u);
	/* Print right singular vectors */
	print_carray( "Right singular vectors (stored rowwise N-by-N)", n, n, vt);
	
	for(int i=0;i<M;i++)
		for(int j=0;j<N;j++)
		{
			a[i+j*lda].r=0.;
			a[i+j*lda].i=0.;
			for(int k=0;k<min(M,N);k++)
			{
				a[i+j*lda].r+=u[i+k*ldu].r*s[k]*vt[k+j*ldvt].r-u[i+k*ldu].i*s[k]*vt[k+j*ldvt].i;
				a[i+j*lda].i+=u[i+k*ldu].r*s[k]*vt[k+j*ldvt].i+u[i+k*ldu].i*s[k]*vt[k+j*ldvt].r;
			}
			a[i+j*lda].r-=backup_a[i+j*lda].r;
			a[i+j*lda].i-=backup_a[i+j*lda].i;
		}
	print_carray( "usvt-a (M by N)", m, n, a);
	printf( "//////////////////////////////////////////////////////////\n" );
}
void test_printf_binary()
{
	double x=0.12345;
	unsigned t=*(unsigned *)&x;
	printf("t=%d\n",t);
	int a = 0x3F800000; // 1.000
	float *b = (float *)&a;
	printf("%f\n",*b);
}
void test_timer()
{
	static time_t time_start, time_end;
	int hour,min,sec;
	time(&time_start);
	sleep(11);
	time(&time_end);
	hour=(int)((time_end-time_start)/3600.);
	min=(int)(((time_end-time_start)%3600)/60.);
	sec=(int)(((time_end-time_start)%3600)%60);
	printf("%ld\t%ld\t%02d:%02d:%02d\n",time_start,time_end,hour,min,sec);
}
void test_string_filename()
{
	FILE *filename;
	char name[0];
	double t=0.2, mu=0.40;
	sprintf(name, "t=%.2f,mu=%.2f.dat\0",t,mu);
	filename=fopen(name,"w");
	fprintf(filename,"hello, this is %s. t=%.2f, mu=%.2f\n",name,t,mu);
	fclose(filename);
	t=0.3; mu=0.30;
	sprintf(name, "t=%.2f,mu=%.2f.dat\0",t,mu);
	filename=fopen(name,"w");
	fprintf(filename,"hello, this is %s. t=%.2f, mu=%.2f\n",name,t,mu);
	fclose(filename);
	t=0.4; mu=0.20;
	sprintf(name, "t=%.2f,mu=%.2f.dat\0",t,mu);
	filename=fopen(name,"w");
	fprintf(filename,"hello, this is %s. t=%.2f, mu=%.2f\n",name,t,mu);
	fclose(filename);
}
void test_char_filename()
{
	FILE *file;
	char name[50];
	double t=0.2, mu=0.40;
	sprintf(name,"./trash/t=%.2f,mu=%.2f.dat\0",t,mu);
	file=fopen(name,"w");
	fprintf(file,"Hello, this is %s. t=%.2f, mu=%.2f\n",name,t,mu);
	fclose(file);
	file=fopen(name,"a");
	fprintf(file,"\n\n\nHello, nice to see you agian!\n");
	fclose(file);
}
void test_fscanf()
{
	FILE *fp_1, *fp_2;
	double i[3], j[3];
	int count, m;
	char *route_1="./tensors/n_max=2/ini_1/t=0.20000,mu=0.20000,chi=17_Gamma.dat\0";
	char *route_2="./tensors/n_max=2/ini_1/t=0.20000,mu=0.20000,chi=17_lambda.dat\0";
	fp_1=fopen(route_1,"r");
	fp_2=fopen(route_2,"r");
	if(fp_1==NULL || fp_2==NULL)
	{
		printf(" There is no file.\n");
		exit(0);
	}
	printf(" fp is directing %s\n",route_1);
	printf(" fp is directing %s\n",route_2);
	count=0;
	while(!feof(fp_1))
	{
		m=(int)(count%3);
		fscanf(fp_1,"%lf\t%lf\n",&i[m],&j[m]);
		//printf("i[%d]=%.15e\tj[%d]=%.15e\n",m,i[m],m,j[m]);
		count++;
	}
	fclose(fp_1);
	count=0;
	while(!feof(fp_2))
	{
		m=(int)(count%3);
		fscanf(fp_2,"%lf\t%lf\n",&i[m],&j[m]);
		printf("i[%d]=%.15e\tj[%d]=%.15e\n",m,i[m],m,j[m]);
		count++;
	}
	fclose(fp_2);
}
