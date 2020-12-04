#include "utils.h"

void SUBLOUTINE_DGESVD(double *A, double *U, double *S, double *Vt, int M, int N)
{
	double wkopt, *work;
	integer m=(integer)M, n=(integer)N;
	integer lda=M, ldu=M, ldvt=N;
	integer info=0, lwork=-1;
	dgesvd_("A","A", &m, &n, A, &lda, S, U, &ldu, Vt, &ldvt, &wkopt, &lwork, &info );
	lwork=(int)wkopt;
	work=new double [lwork*sizeof(double)];
	dgesvd_("A","A", &m, &n, A, &lda, S, U, &ldu, Vt, &ldvt, work, &lwork, &info );
	// Check for convergence //
	if(info!=0)
	{
		printf("The algorithm computing SVD failed to converge. info=%ld\n",info);
		exit(1);
	}
	delete [] work;
}
double pythag(double a, double b)
{
	double absa,absb;
	absa=fabs(a);
	absb=fabs(b);
	if (absa > absb)
		return absa*sqrt(1.0+SQR(absb/absa));
	else 
		return (absb == 0.0 ? 0.0 : absb*sqrt(1.0+SQR(absa/absb)));
}
void reorder(double **u, double *w, double **v, int m, int n) 
{
	int i,j,k,s,inc=1;
	double sw,*su,*sv;
	su=new double [m];
	sv=new double [n];
	do { inc *= 3; inc++; } while (inc <= n);
	do {
		inc /= 3;
		for (i=inc;i<n;i++) {
			sw = w[i];
			for (k=0;k<m;k++) su[k] = u[k][i];
			for (k=0;k<n;k++) sv[k] = v[k][i];
			j = i;
			while (w[j-inc] < sw) {
				w[j] = w[j-inc];
				for (k=0;k<m;k++) u[k][j] = u[k][j-inc];
				for (k=0;k<n;k++) v[k][j] = v[k][j-inc];
				j -= inc;
				if (j < inc) break;
			}
			w[j] = sw;
			for (k=0;k<m;k++) u[k][j] = su[k];
			for (k=0;k<n;k++) v[k][j] = sv[k];

		}
	} while (inc > 1);
	for (k=0;k<n;k++) {
		s=0;
		for (i=0;i<m;i++) if (u[i][k] < 0.) s++;
		for (j=0;j<n;j++) if (v[j][k] < 0.) s++;
		if (s > (m+n)/2) {
			for (i=0;i<m;i++) u[i][k] = -u[i][k];
			for (j=0;j<n;j++) v[j][k] = -v[j][k];
		}
	}
	delete [] su;
	delete [] sv;
}
void print_carray( char* desc, int m, int n, doublecomplex *a)
{
	printf("***********matrix %s***********\n", desc);
	for(int i=0;i<m;i++) 
	{
		for(int j=0;j<n;j++)
                        printf("(%.4e,%.4e) ", a[i+j*m].r, a[i+j*m].i);
		printf("\n");
	}
	printf("\n");
}
void print_array( char* desc, int m, int n, double *a)
{
	printf("***********matrix %s***********\n", desc);
	for(int i=0;i<m;i++) 
	{
		for(int j=0;j<n;j++)
                        printf("%.4e ", a[i+j*m]);
		printf("\n");
	}
	printf("\n");
}
void print_cmatrix( char* desc, int m, int n, doublecomplex **a)
{
	printf("***********matrix %s***********\n", desc);
	for(int i=0;i<m;i++) 
	{
		for(int j=0;j<n;j++)
                        printf("(%.4e,%.4e) ", a[i][j].r, a[i][j].i);
		printf("\n");
	}
	printf("\n");
}
void print_matrix( char* desc, int m, int n, double **a)
{
	printf("***********matrix %s***********\n", desc);
	for(int i=0;i<m;i++) 
	{
		for(int j=0;j<n;j++)
                        printf("%.4e\t", a[i][j]);
		printf("\n");
	}
	printf("\n");
}
