//The model is Bose-Hubbard model on grand cannonical
//the tensors A_oddsite, A_evensite are uniform
//can get norm
//calculating energies is possible
//make h_ij tables
//theta=(U)(S)(Vt) -> A1=U, A2=Vt
//memory optimized(the problem is caused by a lots of global array)
//Big-chi problem is solved(caused by wrong initializations of matrix_A and lambda)
//TEBD normalizing is from the biggest lambda
//zgesvd a function of LAPACK is applied in TEBD process
//extrapolation is not useful

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

#define File_matrix_A "L2XA.dat"		//L,chi,mu0.
#define File_properties "T26M1586X12_.dat"
#define File_correlator "T26M1586x12_r-C(r).dat"

//mu=-1.625*t+0.5815 : T30,32 (X)
//mu=-1.625*t+0.581417 : T30,31,32 
//mu=-1.6157*t+0.578728 : T24-32 !
#define TNS_energy(lam_0,ep) ((lam_0 > 1.0e-16) ? (-log(lam_0)/ep) : 1.e2)
#define TNS_extrapolation(a,b) (5.*b-4.*a)
#define L 40			//the size of the lattice(must be even #)
#define L_trans 2		//the size of translatinally invariant sites(must be even #)
#define n_max 6			//maximum occupation-number
#define phy_dim (n_max+1)	//physical dimension, () is important!
#define bond_dim 12		//bond dimension chi

double U=1., t=0.26, mu=0.1586, epsilon=0.02, twist=0.;
doublecomplex ****matrix_A, ****backup_A, ****before_A, **numerical_table;
doublecomplex *a, *u, *vt, wkopt, *work;
double *s, *rwork;
double **lambda, **backup_s, **before_lambda;
int converge_count, non_converge;
int **Op_identity, **Op_occupation;	//Operator matrices
double E_NoTwist, entropy_S;
double norm=0., expect_b=0.;		//norm, expectation value of an operator b

double SUBLOUTINE_normalizing_lambda(double div, double *w, int n);
void SUBLOUTINE_entropy(double *s);
void SUBLOUTINE_initializing();
void SUBLOUTINE_set_matrices();
void SUBLOUTINE_unset_matrices();
void SUBLOUTINE_set_operators();
void SUBLOUTINE_unset_operators();
void SUBLOUTINE_set_table(double twist);	//table[m1+m2*phy_dim][n1+n2*phy_dim]=<m1 m2| U |n1 n2>
void SUBLOUTINE_unset_table();
void SUBLOUTINE_TEBD(doublecomplex ****A, double **lam);
double SUBLOUTINE_norm(int **No_Oper, int r, doublecomplex ****A, double **lam, int x); //x=0,r<L:<psi|O[r]|psi> / x=0,r=L:<psi|O|psi> / x!=0,r>0:<psi|O[r]O[0]|psi>
void SUBLOUTINE_export(doublecomplex ****bA, double **blam);
void SUBLOUTINE_import(doublecomplex ****bA, double **blam);
void SUBLOUTINE_fprint();
void SUBLOUTINE_fprint_correlation(int **Operator);
void SUBLOUTINE_fprint_columnhead();
///////////////////////////// MAIN /////////////////////////////////
int main()
{
	double before_y, backup_y, y;
	SUBLOUTINE_fprint_columnhead();
	SUBLOUTINE_set_matrices();
//	for(mu=0.2960;mu<=0.2970;mu+=0.001)
	{
		for(int p=0;p<=20;p++)
		{
//			int p=0;
			SUBLOUTINE_initializing();
			converge_count=1;	non_converge=0;
			before_y=0.;	y=1.;
			twist=(double)0.002*p;
			SUBLOUTINE_set_table(twist);
			for(int i=0;i<1000;i++)
				SUBLOUTINE_TEBD(matrix_A,lambda);
			converge_count=1000;
			while(fabs(y-before_y)>Tolerance)
			{
				/*save the previous datas*/
				before_y=TNS_energy(backup_s[0][0],epsilon);
				/*TEBD*/
				converge_count++;
				if(converge_count>1e5)
				{
					non_converge++;
					SUBLOUTINE_initializing();
					converge_count=1;
				}
				SUBLOUTINE_TEBD(matrix_A,lambda);
				y=backup_y=TNS_energy(backup_s[1][0],epsilon);
			}
			if(p==0)
				E_NoTwist=TNS_energy(backup_s[0][0],epsilon);
			SUBLOUTINE_entropy(backup_s[0]);
			SUBLOUTINE_fprint_correlation(Op_occupation);
			SUBLOUTINE_fprint();
			SUBLOUTINE_unset_table();
		}
	}
	SUBLOUTINE_unset_matrices();
	return 0;
}
////////////////////////////////////////////////////////////////////
double SUBLOUTINE_normalizing_lambda(double div, double *w, int n)
{
	return (div <= 1e-16 || w[n] <= 1e-16) ? 0. : w[n]/div;
}
void SUBLOUTINE_entropy(double *s)
{
	double sum=0.;

	for(int i=0;i<bond_dim;i++)
		sum+=s[i]*s[i];
	entropy_S=0.;
	for(int i=0;i<bond_dim;i++)
		entropy_S-=s[i]*s[i]*(log(s[i]*s[i])-log(sum));
	entropy_S=entropy_S/(log(2.)*sum);
}
void SUBLOUTINE_initializing()
{
	init_genrand((unsigned)time(NULL));

	for(int site=0;site<L_trans;site++)
	for(int a2=0;a2<bond_dim;a2++)
		lambda[site][a2]=genrand_real3();
	for(int site=0;site<L_trans;site++)
	for(int n=0;n<phy_dim;n++)
	for(int a1=0;a1<bond_dim;a1++)
	for(int a2=0;a2<bond_dim;a2++)
	{
		matrix_A[site][n][a1][a2].r=genrand_real1()-0.5;
		matrix_A[site][n][a1][a2].i=genrand_real1()-0.5;
	}
}
void SUBLOUTINE_set_matrices()
{
	integer thetadim=phy_dim*bond_dim;

	lambda=new double *[L_trans];
	backup_s=new double *[L_trans];
	before_lambda=new double *[L_trans];
	for(int k=0;k<L_trans;k++)
	{
		lambda[k]=new double [bond_dim];
		backup_s[k]=new double [bond_dim];
		before_lambda[k]=new double [bond_dim];
	}
	matrix_A=new doublecomplex ***[L_trans];
	backup_A=new doublecomplex ***[L_trans];
	before_A=new doublecomplex ***[L_trans];
	for(int iL=0;iL<L_trans;iL++)
	{
		matrix_A[iL]=new doublecomplex **[phy_dim];
		backup_A[iL]=new doublecomplex **[phy_dim];
		before_A[iL]=new doublecomplex **[phy_dim];
		for(int is=0;is<phy_dim;is++)
		{
			matrix_A[iL][is]=new doublecomplex *[bond_dim];
			backup_A[iL][is]=new doublecomplex *[bond_dim];
			before_A[iL][is]=new doublecomplex *[bond_dim];
			for(int a=0;a<bond_dim;a++)
			{
				matrix_A[iL][is][a]=new doublecomplex [bond_dim];
				backup_A[iL][is][a]=new doublecomplex [bond_dim];
				before_A[iL][is][a]=new doublecomplex [bond_dim];
			}
		}
	}
	SUBLOUTINE_initializing();
	
	a=new doublecomplex [thetadim*thetadim];
	u=new doublecomplex [thetadim*thetadim];
	vt=new doublecomplex [thetadim*thetadim];
	s=new double [thetadim];
	rwork=new double [5*thetadim];
}
void SUBLOUTINE_unset_matrices()
{	
	for(int k=0;k<L_trans;k++)
	{
		delete [] lambda[k];
		delete [] backup_s[k];
		delete [] before_lambda[k];
	}
	delete [] lambda;
	delete [] backup_s;
	delete [] before_lambda;
	for(int iL=0;iL<L_trans;iL++)
	{
		for(int is=0;is<phy_dim;is++)
		{
			for(int a=0;a<bond_dim;a++)
			{
				delete [] matrix_A[iL][is][a];
				delete [] backup_A[iL][is][a];
				delete [] before_A[iL][is][a];
			}
			delete [] matrix_A[iL][is];
			delete [] backup_A[iL][is];
			delete [] before_A[iL][is];
		}
		delete [] matrix_A[iL];
		delete [] backup_A[iL];
		delete [] before_A[iL];
	}
	delete [] matrix_A;
	delete [] backup_A;
	delete [] before_A;

	delete [] a;
	delete [] u;
	delete [] vt;
	delete [] s;
	delete [] rwork;
}
void SUBLOUTINE_set_operators()
{
	Op_identity=new int *[phy_dim];
	Op_occupation=new int *[phy_dim];
	
	for(int i=0;i<phy_dim;i++)
	{
		Op_identity[i]=new int [phy_dim];
		Op_occupation[i]=new int [phy_dim];
	}

	for(int n=0;n<phy_dim;n++)
	{
		for(int m=0;m<phy_dim;m++)
		{
			Op_identity[n][m]=0;
			Op_occupation[n][m]=0;
		}
		Op_identity[n][n]=1;
		Op_occupation[n][n]=n;
	}
}
void SUBLOUTINE_unset_operators()
{
	for(int i=0;i<phy_dim;i++)
	{
		delete [] Op_identity[i];
		delete [] Op_occupation[i];
	}
	delete [] Op_identity;
	delete [] Op_occupation;
}
void SUBLOUTINE_set_table(double twist)	//table[m1*phy_dim+m2][n1*phy_dim+n2]=<m1 m2| h |n1 n2>
{
	int phySQ=phy_dim*phy_dim;
	doublecomplex **h_ij, **h_prime, **Q;

	numerical_table=new doublecomplex *[phySQ];
	h_ij=new doublecomplex *[phySQ];	h_prime=new doublecomplex *[phySQ];	Q=new doublecomplex *[phySQ];
	for(int k=0;k<phySQ;k++)
	{
		numerical_table[k]=new doublecomplex [phySQ];
		h_ij[k]=new doublecomplex [phySQ];	h_prime[k]=new doublecomplex [phySQ];	Q[k]=new doublecomplex [phySQ];
	}
	for(int m=0;m<phy_dim;m++)
	for(int n=0;n<phy_dim;n++)
	for(int i=0;i<phy_dim;i++)
	for(int j=0;j<phy_dim;j++)
	{
		double a=0., b1=0., b2=0., c1=0., c2=0.;
		if(m==i && n==j)
			a=U*0.25*(i*i+j*j)-0.5*(U*0.5+mu)*(i+j);
		if(m==i+1 && n==j-1)
		{
			b1=-t*pow((double)(i+1)*j,0.5)*cos(twist);
			b2=-t*pow((double)(i+1)*j,0.5)*(-sin(twist));
		}
		if(m==i-1 && n==j+1)
		{
			c1=-t*pow((double)i*(j+1),0.5)*cos(twist);
			c2=-t*pow((double)i*(j+1),0.5)*sin(twist);
		}
		h_ij[m+n*phy_dim][i+j*phy_dim].r=a+b1+c1;
		h_ij[m+n*phy_dim][i+j*phy_dim].i=b2+c2;
	}
	for(int i=0;i<phySQ;i++)
	{
		for(int j=0;j<phySQ;j++)
		{
			h_prime[i][j].r=0.;	h_prime[i][j].i=0.;
			numerical_table[i][j].r=0.;	numerical_table[i][j].i=0.;
		}
		h_prime[i][i].r=1.;
		numerical_table[i][i].r=1.;
	}
	int count=1;
	while(count<=30)
	{
		for(int i=0;i<phySQ;i++)
		for(int j=0;j<phySQ;j++)
		{
			Q[i][j].r=0.;	Q[i][j].i=0.;
			for(int k=0;k<phySQ;k++)
			{
				Q[i][j].r+=h_prime[i][k].r*h_ij[k][j].r-h_prime[i][k].i*h_ij[k][j].i;
				Q[i][j].i+=h_prime[i][k].r*h_ij[k][j].i+h_prime[i][k].i*h_ij[k][j].r;
			}
		}
		for(int i=0;i<phySQ;i++)
		for(int j=0;j<phySQ;j++)
		{
			h_prime[i][j].r=Q[i][j].r*(-epsilon)/(double)count;
			h_prime[i][j].i=Q[i][j].i*(-epsilon)/(double)count;
			numerical_table[i][j].r+=h_prime[i][j].r;
			numerical_table[i][j].i+=h_prime[i][j].i;
		}
		count++;
	}
//	print_cmatrix("<m1 m2 | h | n1 n2>", phySQ, phySQ, h_ij);
//	print_cmatrix("<m1 m2 | U | n1 n2>", phySQ, phySQ, numerical_table);
	for(int i=0;i<phySQ;i++)
	{
		delete [] h_ij[i];
		delete [] h_prime[i];
		delete [] Q[i];
	}
	delete [] h_ij;
	delete [] h_prime;
	delete [] Q;
}
void SUBLOUTINE_unset_table()
{
	int phySQ=phy_dim*phy_dim;
	for(int i=0;i<phySQ;i++)
		delete [] numerical_table[i];
	delete [] numerical_table;
}
void SUBLOUTINE_TEBD(doublecomplex ****A, double **lam)
{
	integer thetadim=(long int)phy_dim*bond_dim;
	integer lda=thetadim, ldu=thetadim, ldvt=thetadim;

	for(int site=0;site<L_trans;site+=2)
	{
		int L_left=(site-1+L_trans)%L_trans, L_right=(site+1)%L_trans;
		for(int m1=0;m1<phy_dim;m1++)
		for(int m2=0;m2<phy_dim;m2++)
		for(int aL=0;aL<bond_dim;aL++)
		for(int a2=0;a2<bond_dim;a2++)
		{
			a[(m1+aL*phy_dim)+(m2+a2*phy_dim)*lda].r=0.;
			a[(m1+aL*phy_dim)+(m2+a2*phy_dim)*lda].i=0.;
			for(int n1=0;n1<phy_dim;n1++)
			for(int n2=0;n2<phy_dim;n2++)
			for(int a1=0;a1<bond_dim;a1++)
			{
				a[(m1+aL*phy_dim)+(m2+a2*phy_dim)*lda].r += lam[L_left][aL]*lam[site][a1]*lam[L_right][a2] * ( numerical_table[m1+m2*phy_dim][n1+n2*phy_dim].r*(A[site][n1][aL][a1].r*A[L_right][n2][a1][a2].r-A[site][n1][aL][a1].i*A[L_right][n2][a1][a2].i) - numerical_table[m1+m2*phy_dim][n1+n2*phy_dim].i*(A[site][n1][aL][a1].i*A[L_right][n2][a1][a2].r+A[site][n1][aL][a1].r*A[L_right][n2][a1][a2].i) );
				a[(m1+aL*phy_dim)+(m2+a2*phy_dim)*lda].i += lam[L_left][aL]*lam[site][a1]*lam[L_right][a2] * ( numerical_table[m1+m2*phy_dim][n1+n2*phy_dim].r*(A[site][n1][aL][a1].i*A[L_right][n2][a1][a2].r+A[site][n1][aL][a1].r*A[L_right][n2][a1][a2].i) + numerical_table[m1+m2*phy_dim][n1+n2*phy_dim].i*(A[site][n1][aL][a1].r*A[L_right][n2][a1][a2].r-A[site][n1][aL][a1].i*A[L_right][n2][a1][a2].i) );
			}
		}
//		print_carray("matrix theta", thetadim, thetadim, a, lda );
		integer info=0, lwork=-1;
		zgesvd_("A","A", &thetadim, &thetadim, a, &lda, s, u, &ldu, vt, &ldvt, &wkopt, &lwork, rwork, &info );
		lwork=(integer)wkopt.r;
		work=new doublecomplex [lwork*sizeof(doublecomplex)];
		zgesvd_("A","A", &thetadim, &thetadim, a, &lda, s, u, &ldu, vt, &ldvt, work, &lwork, rwork, &info );
		/* Check fr convergence */
		if(info!=0){
			printf("The algorithm computing SVD failed to converge. info=%ld\n",info);
			exit(1);
		}
		delete [] work;
		
//		printf(" s (site=%d)\n",site);
//		for(int i=0;i<thetadim;i++)
//			printf("%.5e\t",s[i]);
//		printf("\n");
//		print_carray("u", thetadim, thetadim, u, ldu );
//		print_carray("vt", thetadim, thetadim, vt, ldvt );

		for(int p=0;p<phy_dim;p++)
		for(int b0=0;b0<bond_dim;b0++)
		for(int b1=0;b1<bond_dim;b1++)
		{
			A[site][p][b0][b1].r=u[(p+b0*phy_dim)+ldu*(b1)].r/(lam[L_left][b0]);
			A[site][p][b0][b1].i=u[(p+b0*phy_dim)+ldu*(b1)].i/(lam[L_left][b0]);
			A[L_right][p][b0][b1].r=vt[(b0)+ldvt*(p+b1*phy_dim)].r/(lam[L_right][b1]);
			A[L_right][p][b0][b1].i=vt[(b0)+ldvt*(p+b1*phy_dim)].i/(lam[L_right][b1]);
		}
		for(int x=0;x<bond_dim;x++)
		{
			backup_s[site][x]=s[x];
			lam[site][x]=SUBLOUTINE_normalizing_lambda(s[0],s,x);
		}
		for(int i=0;i<bond_dim;i++)
		if(site==L_trans-2)
			site=-1;
	}
}
double SUBLOUTINE_norm(int **No_Oper, int r, doublecomplex ****A, double **lam, int x) //x=0,r<L:<psi|O[r]|psi> / x=0,r=L:<psi|O|psi> / x!=0,r>0:<psi|O[r]O[0]|psi>
{
	double **matrix_B, **u, *w, **v, sum, norm=0.;
	int chiSQ=bond_dim*bond_dim;
	
	w=new double [chiSQ];
	u=new double *[chiSQ];
	v=new double *[chiSQ];
	matrix_B=new double *[chiSQ];
	for(int k=0;k<chiSQ;k++)
	{
		u[k]=new double [chiSQ];
		v[k]=new double [chiSQ];
		matrix_B[k]=new double [chiSQ];
	}
	for(int i=0;i<chiSQ;i++)
	{
		for(int j=0;j<chiSQ;j++)
			u[i][j]=0.;
		u[i][i]=1.;
	}
	if(x==0 && r==L)
	{
		for(int site=0;site<L;site++)
		{
			for(int ap1=0;ap1<bond_dim;ap1++)
				for(int a1=0;a1<bond_dim;a1++)
					for(int ap2=0;ap2<bond_dim;ap2++)
						for(int a2=0;a2<bond_dim;a2++)
						{
							sum=0.;
							for(int n=0;n<phy_dim;n++)
								for(int m=0;m<phy_dim;m++)
										sum+=No_Oper[n][m]*A[site%L_trans][n][ap1][ap2]*lam[site%L_trans][ap2]*A[site%L_trans][m][a1][a2]*lam[site%L_trans][a2];
							matrix_B[ap1*bond_dim+a1][ap2*bond_dim+a2]=sum;
						}
			for(int i=0;i<chiSQ;i++)
				for(int j=0;j<chiSQ;j++)
				{
					v[i][j]=0.;
					for(int k=0;k<chiSQ;k++)
						v[i][j]+=u[i][k]*matrix_B[k][j];
				}
			for(int m=0;m<chiSQ;m++)
				for(int n=0;n<chiSQ;n++)
					u[m][n]=v[m][n];
		}
	}
	else if(x==0)
	{
		for(int site=0;site<L;site++)
		{
			for(int ap1=0;ap1<bond_dim;ap1++)
				for(int a1=0;a1<bond_dim;a1++)
					for(int ap2=0;ap2<bond_dim;ap2++)
						for(int a2=0;a2<bond_dim;a2++)
						{
							sum=0.;
							for(int n=0;n<phy_dim;n++)
								for(int m=0;m<phy_dim;m++)
								{
									if(site!=r)
										sum+=Op_identity[n][m]*A[site%L_trans][n][ap1][ap2]*lam[site%L_trans][ap2]*A[site%L_trans][m][a1][a2]*lam[site%L_trans][a2];
									else
										sum+=No_Oper[n][m]*A[site%L_trans][n][ap1][ap2]*lam[site%L_trans][ap2]*A[site%L_trans][m][a1][a2]*lam[site%L_trans][a2];
								}
							matrix_B[ap1*bond_dim+a1][ap2*bond_dim+a2]=sum;
						}
			for(int i=0;i<chiSQ;i++)
				for(int j=0;j<chiSQ;j++)
				{
					v[i][j]=0.;
					for(int k=0;k<chiSQ;k++)
						v[i][j]+=u[i][k]*matrix_B[k][j];
				}
			for(int m=0;m<chiSQ;m++)
				for(int n=0;n<chiSQ;n++)
					u[m][n]=v[m][n];
		}
	}
	else if(r>=0)
	{
		for(int site=0;site<=r;site++)
		{
			for(int ap1=0;ap1<bond_dim;ap1++)
				for(int a1=0;a1<bond_dim;a1++)
					for(int ap2=0;ap2<bond_dim;ap2++)
						for(int a2=0;a2<bond_dim;a2++)
						{
							sum=0.;
							for(int n=0;n<phy_dim;n++)
								for(int m=0;m<phy_dim;m++)
								{
									if(site!=0 && site!=r)
										sum+=Op_identity[n][m]*A[site%L_trans][n][ap1][ap2]*lam[site%L_trans][ap2]*A[site%L_trans][m][a1][a2]*lam[site%L_trans][a2];
									else
										sum+=No_Oper[n][m]*A[site%L_trans][n][ap1][ap2]*lam[site%L_trans][ap2]*A[site%L_trans][m][a1][a2]*lam[site%L_trans][a2];
								}
							matrix_B[ap1*bond_dim+a1][ap2*bond_dim+a2]=sum;
						}
			for(int i=0;i<chiSQ;i++)
				for(int j=0;j<chiSQ;j++)
				{
					v[i][j]=0.;
					for(int k=0;k<chiSQ;k++)
						v[i][j]+=u[i][k]*matrix_B[k][j];
				}
			for(int m=0;m<chiSQ;m++)
				for(int n=0;n<chiSQ;n++)
					u[m][n]=v[m][n];
		}
	}
	for(int i=0;i<chiSQ;i++)
		norm+=u[i][i];
	for(int k=0;k<chiSQ;k++)
	{
		delete [] u[k];
		delete [] v[k];
		delete [] matrix_B[k];
	}
	delete [] w;
	delete [] u;
	delete [] v;
	delete [] matrix_B;
	return norm;
}
void SUBLOUTINE_export(doublecomplex ****bA, double **blam)
{
	for(int site=0;site<L_trans;site++)
	for(int a2=0;a2<bond_dim;a2++)
	{
		blam[site][a2]=lambda[site][a2];
		for(int n=0;n<phy_dim;n++)
		for(int a1=0;a1<bond_dim;a1++)
		{
			bA[site][n][a1][a2].r=matrix_A[site][n][a1][a2].r;
			bA[site][n][a1][a2].i=matrix_A[site][n][a1][a2].i;
		}
	}
}
void SUBLOUTINE_import(doublecomplex ****bA, double **blam)
{
	for(int site=0;site<L_trans;site++)
	for(int a2=0;a2<bond_dim;a2++)
	{
		lambda[site][a2]=blam[site][a2];
		for(int n=0;n<phy_dim;n++)
		for(int a1=0;a1<bond_dim;a1++)
		{
			matrix_A[site][n][a1][a2].r=bA[site][n][a1][a2].r;
			matrix_A[site][n][a1][a2].i=bA[site][n][a1][a2].i;
		}
	}
}
void SUBLOUTINE_fprint()
{
	double *Energy_0;
	FILE *result;

	result=fopen(File_properties,"a");
	Energy_0=new double [L_trans];
	for(int site=0;site<1;site++)
		Energy_0[site]=TNS_energy(backup_s[site][0],epsilon);
	for(int site=0;site<1;site++)
		fprintf(result,"%d\t%d\t%.4e\t%.4e\t%.8e\t%.8e\t%.8e\t%.8e\t%.8e\t%.8e\t%.8e\t%.8e\t%.8e\t%d\n",n_max,bond_dim,mu,t,twist,Energy_0[site],(Energy_0[site]-E_NoTwist),backup_s[site][0],backup_s[site][1],backup_s[site][2],entropy_S,norm,expect_b,converge_count);
	delete [] Energy_0;
	fclose(result);
}
void SUBLOUTINE_fprint_correlation(int **Operator)
{
	FILE *result;
	double norm, norm_r0;

	result=fopen(File_correlator,"a");
	for(int site=1;site<L;site++)
	{
		norm_r0=SUBLOUTINE_norm(Operator,site,A,lam,1);
		norm=SUBLOUTINE_norm(Op_identity,L,A,lam,0)
		fprintf(result,"%d\t%d\t%.4f\t%.0e\t%d\t%.8e\t%d\t%d\n",L,n_max,bond_dim,mu/U,t/U,norm,site,norm_r0,converge_count,non_converge);
	}
	fclose(result);
}
void SUBLOUTINE_fprint_columnhead()
{
	FILE *results, *result_A, *result_B, *result_C;

	results=fopen(File_properties,"w");
	fprintf(results,"#n_max\tchi\tmu/U\t\tt/U\t\ttwist\t\tEnergy[site]\tdE\t\ts_0[site]\ts_1[site]\ts_2[site]\tentropy_S\tnorm\t\t<b>\t\tcount\n");
	fclose(results);
	result_A=fopen(File_correlator,"w");
	fprintf(result_A,"#L\tn_max\tchi\tmu/U\t\tt/U\t\tnorm\t\tr\t\t<n_r n_1>\tcount\tre\n");
	fclose(result_A);
//	result_A=fopen(File_matrix_A,"w");
//	fprintf(result_A,"#U\tmu\tt\t[L][n][a1][a2]\tA[L][n][a1][a2]\tlambda[L][a2]\tcount\tre\n");
//	fclose(result_A);
}
