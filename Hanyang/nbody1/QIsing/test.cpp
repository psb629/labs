#include <iostream>
#include <cstdio>
#include <ctime>
#include <cmath>
#include "utils.h"
#include "mt19937ar.h"
#include "/Users/park/project/CLAPACK-3.2.1/INCLUDE/blaswrap.h"
#include "/Users/park/project/CLAPACK-3.2.1/INCLUDE/f2c.h"
#include "/Users/park/project/CLAPACK-3.2.1/INCLUDE/clapack.h"
using namespace std;

#define M 4
#define N 4
#define LDA M
#define LDU M
#define LDVT N

void test_dgesvd();
void test_zgesvd();
void test_cbracat();
void test_SUBLOUTINE_DGESVD();
int main()
{
	test_spend_time();
	return 0;
}
void test_dgesvd()
{
	long int m = M, n = N, lda = LDA, ldu = LDU, ldvt = LDVT;
	integer info=0, lwork;
	double wkopt, *work;
	/* Local arrays */
	double s[min(M,N)], u[LDU*M], vt[LDVT*N];
	double a[LDA*N], backup_a[LDA*N];

	init_genrand((unsigned)time(NULL));
	for(int i=0;i<lda;i++)
		for(int j=0;j<N;j++)
			//backup_a[i+j*lda]=a[i+j*lda]=genrand_real3();
			backup_a[j+i*lda]=backup_a[i+j*lda]=a[j+i*lda]=a[i+j*lda]=genrand_real3();

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
	/* Print left singular vectors */
	print_array( "Left singular vectors (stored columnwise, M-by-M)", m, m, u);
	/* Print singular values */
	print_array( "Singular values (min(M,N))", 1, min(m,n), s);
	/* Print right singular vectors */
	print_array( "Right singular vectors (stored rowwise N-by-N)", n, n, vt);

	for(int i=0;i<m;i++)
		for(int j=0;j<n;j++)
		{
			a[i+j*lda]=0.;
			for(int k=0;k<min(m,n);k++)
				a[i+j*lda]+=u[i+k*ldu]*s[k]*vt[k+j*ldvt];
			a[i+j*lda]-=backup_a[i+j*lda];
		}
	print_array( "usvt-a (M by N)", m, n, a);
	printf( "\n//////////////////////////////////////////////////////////\n");
	double trace_1=0., trace_2=0.;
	for(int i=0;i<min(m,n);i++)
	{
		trace_1+=backup_a[i+i*lda];
		trace_2+=s[i];
	}
	printf(" trace of A=%.8e\n trace of s=%.8e\n",trace_1,trace_2);

	/* Free workspace */
//	free( (void*)work );
	delete [] work;
	exit( 0 );
} /* End of DGESVD Example */
void test_SUBLOUTINE_DGESVD()
{
	long int m = M, n = N, lda = LDA, ldu = LDU, ldvt = LDVT;
	/* Local arrays */
	double s[min(M,N)], u[LDU*M], vt[LDVT*N];
	double a[LDA*N], backup_a[LDA*N];

	init_genrand((unsigned)time(NULL));
	for(int i=0;i<lda;i++)
		for(int j=0;j<N;j++)
			//backup_a[i+j*lda]=a[i+j*lda]=genrand_real3();
			backup_a[j+i*lda]=backup_a[i+j*lda]=a[j+i*lda]=a[i+j*lda]=genrand_real3();

	/* Executable statements */
	printf( "\n///////////// DGESVD Example Program Results /////////////\n\n" );
	print_array( "Original vectors before zgesvd (M-by-N)", m, n, a);
	/* Compute SVD */
	SUBLOUTINE_DGESVD(a,u,s,vt,m,n);
	/* Print left singular vectors */
	print_array( "Left singular vectors (stored columnwise, M-by-M)", m, m, u);
	/* Print singular values */
	print_array( "Singular values (min(M,N))", 1, min(m,n), s);
	/* Print right singular vectors */
	print_array( "Right singular vectors (stored rowwise N-by-N)", n, n, vt);

	for(int i=0;i<m;i++)
		for(int j=0;j<n;j++)
		{
			a[i+j*lda]=0.;
			for(int k=0;k<min(m,n);k++)
				a[i+j*lda]+=u[i+k*ldu]*s[k]*vt[k+j*ldvt];
			a[i+j*lda]-=backup_a[i+j*lda];
		}
	print_array( "usvt-a (M by N)", m, n, a);
	printf( "\n//////////////////////////////////////////////////////////\n");
	double trace_1=0., trace_2=0.;
	for(int i=0;i<min(m,n);i++)
	{
		trace_1+=backup_a[i+i*lda];
		trace_2+=s[i];
	}
	printf(" trace of A=%.8e\n trace of s=%.8e\n",trace_1,trace_2);
	exit( 0 );
}
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
			backup_a[i+j*lda].r=a[i+j*lda].r=genrand_real1()-0.5;
			backup_a[i+j*lda].i=a[i+j*lda].i=genrand_real1()-0.5;
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
	//print_carray( "Original vectors before zgesvd (M-by-N)", m, n, a, lda );
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
	//print_carray( "Original vectors after zgesvd, be durty (M-by-N)", m, n, a, lda );
	print_carray( "Original vectors after zgesvd, be durty (M-by-N)", m, n, a);
	/* Print left singular vectors */
	//print_carray( "Left singular vectors (stored columnwise, M-by-M)", m, m, u, ldu );
	print_carray( "Left singular vectors (stored columnwise, M-by-M)", m, m, u);
	/* Print singular values */
	//print_array( "Singular values (min(M,N))", 1, min(m,n), s, 1 );
	print_array( "Singular values (min(M,N))", 1, min(m,n), s);
	/* Print right singular vectors */
	//print_carray( "Right singular vectors (stored rowwise N-by-N)", n, n, vt, ldvt );
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
	//print_carray( "usvt-a (M by N)", m, n, a, lda );
	print_carray( "usvt-a (M by N)", m, n, a);
	printf( "//////////////////////////////////////////////////////////\n" );

	/* Free workspace */
//	free( (void*)work );
	delete [] work;
	exit( 0 );
}
void test_cbracat()
{
	doublecomplex ****matrix_A;
	double **lambda;
	/*set_matrices*/
	int L=2, phy_dim=10, bond_dim=20;
	int thetadim=bond_dim*phy_dim;
	
	lambda=new double *[L];
	for(int k=0;k<L;k++)
		lambda[k]=new double [bond_dim];
	matrix_A=new doublecomplex ***[L];
	for(int iL=0;iL<L;iL++)
	{
		matrix_A[iL]=new doublecomplex **[phy_dim];
		for(int is=0;is<phy_dim;is++)
		{
			matrix_A[iL][is]=new doublecomplex *[bond_dim];
			for(int a=0;a<bond_dim;a++)
				matrix_A[iL][is][a]=new doublecomplex [bond_dim];
		}
	}
	/*initializing*/
	init_genrand((unsigned)time(NULL));

	for(int site=0;site<L;site++)
	for(int a2=0;a2<bond_dim;a2++)
		lambda[site][a2]=genrand_real3();
	for(int site=0;site<L;site++)
	for(int n=0;n<phy_dim;n++)
	for(int a1=0;a1<bond_dim;a1++)
	for(int a2=0;a2<bond_dim;a2++)
	{
		matrix_A[site][n][a1][a2].r=genrand_real1()-0.5;
		matrix_A[site][n][a1][a2].i=genrand_real1()-0.5;
	}
	/*test cbracat func.*/
	cbracat(matrix_A, lambda, matrix_A, lambda, L, phy_dim, bond_dim, bond_dim);
	/*unset_matrices*/
	for(int k=0;k<L;k++)
		delete [] lambda[k];
	delete [] lambda;
	for(int iL=0;iL<L;iL++)
	{
		for(int is=0;is<phy_dim;is++)
		{
			for(int a=0;a<bond_dim;a++)
				delete [] matrix_A[iL][is][a];
			delete [] matrix_A[iL][is];
		}
		delete [] matrix_A[iL];
	}
	delete [] matrix_A;
}
