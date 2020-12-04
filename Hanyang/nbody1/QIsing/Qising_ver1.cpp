//the tensors A of ground state are uniform
//get norm(found the error and fix it)
//checking the energies is possible
//make h_ij tables
//make correlator
//memory optimized(the problem is caused by a lots of global array)
//TEBD normalizing is from summation of lambdas square
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

#define FLIP(a)		(((a)==(0))?(1):(0))
#define SPIN(a)		(((a)==(0))?(1):(-1))
#define TNS_energy(lam_0,ep) ((lam_0 > 1.0e-5) ? (-log(lam_0)/ep) : 1.e2)
#define ERROR(a,b)	((b-a)/fabs(MIN(a,b)))
//#define Error(a,b)	((fabs(a) > fabs(b)) ? (fabs((fabs(a)-fabs(b))/b)) : (fabs((fabs(b)-fabs(a))/a)))

#define File_matrix_A "gChgep0.005x12_A.dat"		//L,chi
#define File_lambda "gChgep0.005x12_lam.dat"
#define File_magnetization "gChgep0.005x12_g-m.dat"	//g,epsilon,chi_X-Y axis.dat
#define File_printf "gChgep0.005x12_g-dE.dat"	//g,epsilon,chi_X-Y axis.dat
#define File_correlator "gChgep0.005x12_r-C(r).dat"
#define L 120			//Lattice size(must be even #)
#define phy_dim 2		//physical dimension(spin up/down)
#define bond_dim 11		//bond dimension chi

double ini_ep=0.005, fin_ep=0.005;
double g_initial=0.0, g_final=1.41, g_gap=0.2;
double J=1., g=g_initial, h=0.0, epsilon=0.005;
double NORM, SUM_norm, lamRSS;
double ****matrix_A, **lambda, ****backup_A, **backup_lam;
double **numerical_table;
double *TEBD_a, *TEBD_u, *TEBD_vt, TEBD_wkopt, *TEBD_work;
double *TEBD_s, **backup_s;
int converge_count, non_converge;
int **Op_identity, **Op_sigmaZ, **Op_sigmaX;	//Operator matrices
integer thetadim=phy_dim*bond_dim;
double *lambda_0, error, min_error=1.;

double SUBLOUTINE_normalizing_lambda(double div, double *w, int n);
void SUBLOUTINE_initializing();
void SUBLOUTINE_set_matrices();
void SUBLOUTINE_unset_matrices();
void SUBLOUTINE_set_table();		//table[m1*phy_dim+m2][n1*phy_dim+n2]=<m1 m2| h |n1 n2>
void SUBLOUTINE_unset_table();
void SUBLOUTINE_set_operators();
void SUBLOUTINE_unset_operators();
void SUBLOUTINE_TEBD(double ****A, double **lam);
double SUBLOUTINE_norm(int **Operator, int r, double ****A, double **lam, int x); //x=0,r<L:<psi|O[r]|psi> / x=0,r=L:<psi|O|psi> / x!=0,r>0:<psi|O[r]O[0]|psi>
void SUBLOUTINE_normalizing_state(double ****A, double **lam);
double SUBLOUTINE_exact(int size);
void SUBLOUTINE_fprint_columnhead();
void SUBLOUTINE_fprint_energy();
void SUBLOUTINE_fprintf_lambda(double **lam);
void SUBLOUTINE_fprint_matrix(double ****A, double **lam);
void SUBLOUTINE_fprint_magnetization(double ****A, double **lam);
void SUBLOUTINE_fprint_correlator(int **Operator, double ****A, double **lam);
void printFORsteps();
void backup_main();
void exact_diagonalizaion();
void check_TransSym_Alam(double ****A, double**lam);
int check_matrix_symmetry(char *word,double **matrix, int M);
void test();
int main()
{
	test();
	return 0;
}
double SUBLOUTINE_normalizing_lambda(double div, double *w, int n)
{
	return (div <= 1e-20 || w[n] <= 1e-20) ? 0. : w[n]/div;
}
void SUBLOUTINE_initializing()
{
	init_genrand((unsigned)time(NULL));

	for(int site=0;site<2;site++)
	for(int a2=0;a2<bond_dim;a2++)
	{
		for(int n=0;n<phy_dim;n++)
		for(int a1=0;a1<bond_dim;a1++)
			matrix_A[site][n][a1][a2]=genrand_real3()-0.5;
		lambda[site][a2]=genrand_real3();
	}
}
void SUBLOUTINE_set_matrices()
{
	lambda_0=new double [2];
	lambda=new double *[2];
	backup_lam=new double *[2];
	backup_s=new double *[2];
	matrix_A=new double ***[2];
	backup_A=new double ***[2];
	for(int site=0;site<2;site++)
	{
		lambda[site]=new double [bond_dim];
		backup_lam[site]=new double [bond_dim];
		backup_s[site]=new double [bond_dim];
		matrix_A[site]=new double **[phy_dim];
		backup_A[site]=new double **[phy_dim];
		for(int n=0;n<phy_dim;n++)
		{
			matrix_A[site][n]=new double *[bond_dim];
			backup_A[site][n]=new double *[bond_dim];
			for(int a=0;a<bond_dim;a++)
			{
				matrix_A[site][n][a]=new double [bond_dim];
				backup_A[site][n][a]=new double [bond_dim];
			}
		}
	}
	TEBD_a=new double [thetadim*thetadim];
	TEBD_u=new double [thetadim*thetadim];
	TEBD_vt=new double [thetadim*thetadim];
	TEBD_s=new double [thetadim];
}
void SUBLOUTINE_unset_matrices()
{	
	for(int site=0;site<2;site++)
	{
		for(int n=0;n<phy_dim;n++)
		{
			for(int a=0;a<bond_dim;a++)
			{
				delete [] matrix_A[site][n][a];
				delete [] backup_A[site][n][a];
			}
			delete [] matrix_A[site][n];
			delete [] backup_A[site][n];
		}
		delete [] lambda[site];
		delete [] backup_lam[site];
		delete [] backup_s[site];
		delete [] matrix_A[site];
		delete [] backup_A[site];
	}
	delete [] lambda;
	delete [] backup_lam;
	delete [] backup_s;
	delete [] lambda_0;
	delete [] matrix_A;
	delete [] backup_A;
	delete [] TEBD_a;
	delete [] TEBD_u;
	delete [] TEBD_vt;
	delete [] TEBD_s;
}
void SUBLOUTINE_set_table()		//table[m1*phy_dim+m2][n1*phy_dim+n2]=<m1 m2| h |n1 n2>
{
	int phySQ=phy_dim*phy_dim, count=1;
	double **h_ij, **h_prime, **Q;

	numerical_table=new double *[phySQ];
	h_ij=new double *[phySQ];	h_prime=new double *[phySQ];	Q=new double *[phySQ];
	for(int k=0;k<phySQ;k++)
	{
		numerical_table[k]=new double [phySQ];
		h_ij[k]=new double [phySQ];	h_prime[k]=new double [phySQ];	Q[k]=new double [phySQ];
	}
	for(int m=0;m<phy_dim;m++)
	for(int n=0;n<phy_dim;n++)
	for(int i=0;i<phy_dim;i++)
	for(int j=0;j<phy_dim;j++)
		h_ij[m*phy_dim+n][i*phy_dim+j]=-J*Op_sigmaZ[m][i]*Op_sigmaZ[n][j]-J*h*0.5*(Op_sigmaZ[m][i]+Op_sigmaZ[n][j])-J*g*0.5*(Op_sigmaX[m][i]*Op_identity[n][j]+Op_identity[m][i]*Op_sigmaX[n][j]);
	for(int i=0;i<phySQ;i++)
	{
		for(int j=0;j<phySQ;j++)
		{
			h_prime[i][j]=0.;
			numerical_table[i][j]=0.;
		}
		h_prime[i][i]=1.;
		numerical_table[i][i]=1.;
	}
	while(count<=20)
	{
		for(int i=0;i<phySQ;i++)
		for(int j=0;j<phySQ;j++)
		{
			Q[i][j]=0.;
			for(int k=0;k<phySQ;k++)
				Q[i][j]+=h_prime[i][k]*h_ij[k][j];
		}
		for(int i=0;i<phySQ;i++)
		for(int j=0;j<phySQ;j++)
			h_prime[i][j]=Q[i][j]*(-epsilon)/(double)count;
		for(int i=0;i<phySQ;i++)
		for(int j=0;j<phySQ;j++)
			numerical_table[i][j]+=h_prime[i][j];
		count++;
	}
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
	{
		delete [] numerical_table[i];
	}
	delete [] numerical_table;
}
void SUBLOUTINE_set_operators()
{
	Op_identity=new int *[phy_dim];
	Op_sigmaZ=new int *[phy_dim];
	Op_sigmaX=new int *[phy_dim];
	
	for(int i=0;i<phy_dim;i++)
	{
		Op_identity[i]=new int [phy_dim];
		Op_sigmaZ[i]=new int [phy_dim];
		Op_sigmaX[i]=new int [phy_dim];
	}

	for(int n=0;n<phy_dim;n++)
	{
		for(int m=0;m<phy_dim;m++)
		{
			Op_identity[n][m]=0;
			Op_sigmaZ[n][m]=0;
			Op_sigmaX[n][m]=1;
		}
		Op_identity[n][n]=1;
		Op_sigmaZ[n][n]=(int)SPIN(n);
		Op_sigmaX[n][n]=0;
	}
}
void SUBLOUTINE_unset_operators()
{
	for(int i=0;i<phy_dim;i++)
	{
		delete [] Op_identity[i];
		delete [] Op_sigmaZ[i];
		delete [] Op_sigmaX[i];
	}
	delete [] Op_identity;
	delete [] Op_sigmaZ;
	delete [] Op_sigmaX;
}
void SUBLOUTINE_TEBD(double ****A, double **lam)
{
	int lda=thetadim, ldu=thetadim, ldvt=thetadim;

	for(int site=0;site<2;site++)
	{
		int L_left=(site-1+2)%2, L_right=(site+1)%2;
		for(int m1=0;m1<phy_dim;m1++)
		for(int m2=0;m2<phy_dim;m2++)
		for(int aL=0;aL<bond_dim;aL++)
		for(int a2=0;a2<bond_dim;a2++)
		{
			TEBD_a[(m1+aL*phy_dim)+(m2+a2*phy_dim)*lda]=0.;
			for(int n1=0;n1<phy_dim;n1++)
			for(int n2=0;n2<phy_dim;n2++)
			for(int a1=0;a1<bond_dim;a1++)
				TEBD_a[(m1+aL*phy_dim)+lda*(m2+a2*phy_dim)] += numerical_table[m1*phy_dim+m2][n1*phy_dim+n2]*lam[L_left][aL]*lam[site][a1]*lam[L_right][a2]*A[site][n1][aL][a1]*A[L_right][n2][a1][a2];
				//TEBD_a[lda*(m1+aL*phy_dim)+(m2+a2*phy_dim)] += numerical_table[m1*phy_dim+m2][n1*phy_dim+n2]*lam[L_left][aL]*lam[site][a1]*lam[L_right][a2]*A[site][n1][aL][a1]*A[L_right][n2][a1][a2];
		}
		SUBLOUTINE_DGESVD(TEBD_a,TEBD_u,TEBD_s,TEBD_vt,thetadim,thetadim);
		for(int p=0;p<phy_dim;p++)
		for(int b0=0;b0<bond_dim;b0++)
		for(int b1=0;b1<bond_dim;b1++)
		{
			A[site][p][b0][b1]=TEBD_u[(p+b0*phy_dim)+ldu*(b1)]/lam[L_left][b0];
			A[L_right][p][b0][b1]=TEBD_vt[(b0)+ldvt*(p+b1*phy_dim)]/lam[L_right][b1];
			//A[site][p][b0][b1]=TEBD_u[ldu*(p+b0*phy_dim)+(b1)]/lam[L_left][b0];
			//A[L_right][p][b0][b1]=TEBD_vt[ldvt*(b0)+(p+b1*phy_dim)]/lam[L_right][b1];
		}
		lamRSS=0.;
		for(int x=0;x<bond_dim;x++)
			lamRSS+=TEBD_s[x]*TEBD_s[x];
		lamRSS=pow(lamRSS,0.5);
		for(int x=0;x<bond_dim;x++)
		{
			backup_s[site][x]=TEBD_s[x];
			lam[site][x]=SUBLOUTINE_normalizing_lambda(TEBD_s[0],TEBD_s,x);
			//lam[site][x]=SUBLOUTINE_normalizing_lambda(lamRSS,TEBD_s,x);
		}
	}
}
double SUBLOUTINE_norm(int **Operator, int r, double ****A, double **lam, int x)
{
	double **Bp1, **Bp2, **B1, **B2, **Bp12, **B12;
	double **mat_u, **mat_v, norm=0.;
	double *svd_A, *svd_U, *svd_Vt, *S_B1, *S_B2, *S_Bp1, *S_Bp2, *S_B12, *S_Bp12;
	int chiSQ=bond_dim*bond_dim;
	
	mat_u=new double *[chiSQ];
	mat_v=new double *[chiSQ];
	Bp1=new double *[chiSQ];
	Bp2=new double *[chiSQ];
	B1=new double *[chiSQ];
	B2=new double *[chiSQ];
	Bp12=new double *[chiSQ];
	B12=new double *[chiSQ];
	svd_A=new double [chiSQ*chiSQ]; svd_U=new double [chiSQ*chiSQ]; svd_Vt=new double [chiSQ*chiSQ];
	S_B1=new double [chiSQ]; S_B2=new double [chiSQ]; S_Bp1=new double [chiSQ]; S_Bp2=new double [chiSQ];
	S_B12=new double [chiSQ]; S_Bp12=new double [chiSQ];

	for(int k=0;k<chiSQ;k++)
	{
		mat_u[k]=new double [chiSQ];
		mat_v[k]=new double [chiSQ];
		Bp1[k]=new double [chiSQ];
		Bp2[k]=new double [chiSQ];
		B1[k]=new double [chiSQ];
		B2[k]=new double [chiSQ];
		Bp12[k]=new double [chiSQ];
		B12[k]=new double [chiSQ];
	}
	for(int i=0;i<chiSQ;i++)
	for(int j=0;j<chiSQ;j++)
	{
		Bp1[i][j]=0.;
		Bp2[i][j]=0.;
		B1[i][j]=0.;
		B2[i][j]=0.;
		B12[i][j]=0.;
		Bp12[i][j]=0.;
	}
	for(int ap1=0;ap1<bond_dim;ap1++)
	for(int a1=0;a1<bond_dim;a1++)
	for(int ap2=0;ap2<bond_dim;ap2++)
	for(int a2=0;a2<bond_dim;a2++)
	{
		for(int n=0;n<phy_dim;n++)
		for(int m=0;m<phy_dim;m++)
		{
			//Bp1[ap1*bond_dim+a1][ap2*bond_dim+a2]+=Operator[n][m]*A[0][n][ap1][ap2]*A[0][m][a1][a2]*lam[0][ap2]*lam[0][a2];
			//Bp2[ap1*bond_dim+a1][ap2*bond_dim+a2]+=Operator[n][m]*A[1][n][ap1][ap2]*A[1][m][a1][a2]*lam[1][ap2]*lam[1][a2];
			//B1[ap1*bond_dim+a1][ap2*bond_dim+a2]+=Op_identity[n][m]*A[0][n][ap1][ap2]*A[0][m][a1][a2]*lam[0][ap2]*lam[0][a2];
			//B2[ap1*bond_dim+a1][ap2*bond_dim+a2]+=Op_identity[n][m]*A[1][n][ap1][ap2]*A[1][m][a1][a2]*lam[1][ap2]*lam[1][a2];
			Bp1[ap1*bond_dim+a1][ap2*bond_dim+a2]+=Operator[n][m]*pow(lam[1][ap1]*lam[0][ap2]*lam[1][a1]*lam[0][a2],0.5)*A[0][n][ap1][ap2]*A[0][m][a1][a2];
			Bp2[ap1*bond_dim+a1][ap2*bond_dim+a2]+=Operator[n][m]*pow(lam[0][ap1]*lam[1][ap2]*lam[0][a1]*lam[1][a2],0.5)*A[1][n][ap1][ap2]*A[1][m][a1][a2];
			B1[ap1*bond_dim+a1][ap2*bond_dim+a2]+=Op_identity[n][m]*pow(lam[1][ap1]*lam[0][ap2]*lam[1][a1]*lam[0][a2],0.5)*A[0][n][ap1][ap2]*A[0][m][a1][a2];
			B2[ap1*bond_dim+a1][ap2*bond_dim+a2]+=Op_identity[n][m]*pow(lam[0][ap1]*lam[1][ap2]*lam[0][a1]*lam[1][a2],0.5)*A[1][n][ap1][ap2]*A[1][m][a1][a2];
		}
		for(int k=0;k<chiSQ;k++)
		{
			B12[ap1*bond_dim+a1][ap2*bond_dim+a2]+=B1[ap1*bond_dim+a1][k]*B2[k][ap2*bond_dim+a2];
			Bp12[ap1*bond_dim+a1][ap2*bond_dim+a2]+=Bp1[ap1*bond_dim+a1][k]*Bp2[k][ap2*bond_dim+a2];
		}
	}
	//printf("Bp1:\n"); check_matrix_symmetry("Bp1", Bp1, chiSQ);
	//printf("Bp2:\n"); check_matrix_symmetry("Bp2", Bp2, chiSQ);
	// get a singular value(=eigenvalue) of each B matrix //
	for(int i=0;i<chiSQ;i++)
	for(int j=0;j<chiSQ;j++)
		svd_A[i+j*chiSQ]=B1[i][j];
	SUBLOUTINE_DGESVD(svd_A,svd_U,S_B1,svd_Vt,chiSQ,chiSQ);
	for(int i=0;i<chiSQ;i++)
	for(int j=0;j<chiSQ;j++)
		svd_A[i+j*chiSQ]=B2[i][j];
	SUBLOUTINE_DGESVD(svd_A,svd_U,S_B2,svd_Vt,chiSQ,chiSQ);
	for(int i=0;i<chiSQ;i++)
	for(int j=0;j<chiSQ;j++)
		svd_A[i+j*chiSQ]=Bp1[i][j];
	SUBLOUTINE_DGESVD(svd_A,svd_U,S_Bp1,svd_Vt,chiSQ,chiSQ);
	for(int i=0;i<chiSQ;i++)
	for(int j=0;j<chiSQ;j++)
		svd_A[i+j*chiSQ]=Bp2[i][j];
	SUBLOUTINE_DGESVD(svd_A,svd_U,S_Bp2,svd_Vt,chiSQ,chiSQ);
	for(int i=0;i<chiSQ;i++)
	for(int j=0;j<chiSQ;j++)
		svd_A[i+j*chiSQ]=B12[i][j];
	SUBLOUTINE_DGESVD(svd_A,svd_U,S_B12,svd_Vt,chiSQ,chiSQ);
	for(int i=0;i<chiSQ;i++)
	for(int j=0;j<chiSQ;j++)
		svd_A[i+j*chiSQ]=Bp12[i][j];
	SUBLOUTINE_DGESVD(svd_A,svd_U,S_Bp12,svd_Vt,chiSQ,chiSQ);
	////////////////////////////////////////////////////////
//	printf("S_B12[0]-1.=%.8e\tS_Bp12[0]-1.=%.8e\n",S_B12[0]-1.,S_Bp12[0]-1.);
	check_matrix_symmetry("Bp1", Bp1, chiSQ);
	check_matrix_symmetry("Bp2", Bp2, chiSQ);
	check_matrix_symmetry("Bp12", Bp12, chiSQ);
//	print_array("S_B1",chiSQ,1,S_B1);
//	print_array("S_B2",chiSQ,1,S_B2);
//	print_array("S_Bp1",chiSQ,1,S_Bp1);
//	print_array("S_Bp2",chiSQ,1,S_Bp2);
	for(int i=0;i<chiSQ;i++)
	{
		for(int j=0;j<chiSQ;j++)
			mat_u[i][j]=0.;
		mat_u[i][i]=1.;
	}
	//x=0,r<L:<psi|O[r]|psi> / x=0,r=L:<psi|O|psi> / x!=0,r>0:<psi|O[r]O[0]|psi>
	if(x==0 && r<L)
	{
		//print_array("S_B1",chiSQ,1,S_B1);
		//print_array("S_Bp1",chiSQ,1,S_Bp1);
		for(int site=0;site<L;site+=2)
		{
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
			{
				mat_v[i][j]=0.;
				for(int k=0;k<chiSQ;k++)
				{
					if(site!=r && site!=r+1)
						mat_v[i][j]+=mat_u[i][k]*B12[k][j];
					else if(site==r)
						for(int l=0;l<chiSQ;l++)
							mat_v[i][j]+=mat_u[i][k]*Bp1[k][l]*B2[l][j];
					else if(site==r+1)
						for(int l=0;l<chiSQ;l++)
							mat_v[i][j]+=mat_u[i][k]*B1[k][l]*Bp2[l][j];
				}
			}
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
				mat_u[i][j]=mat_v[i][j];
		}
		for(int i=0;i<chiSQ;i++)
			norm+=mat_u[i][i];
	}
	else if(x==0 && r==L)
	{
		for(int site=0;site<L;site+=2)
		{
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
			{
				mat_v[i][j]=0.;
				for(int k=0;k<chiSQ;k++)
					mat_v[i][j]+=mat_u[i][k]*Bp12[k][j];
			}
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
				mat_u[i][j]=mat_v[i][j];
		}
		for(int i=0;i<chiSQ;i++)
			norm+=mat_u[i][i];
		SUM_norm=0.;
		for(int i=0;i<chiSQ;i++)
			SUM_norm+=pow(S_Bp12[i],L*0.5);
	}
	else
	{
		for(int site=0;site<L;site+=2)
		{
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
			{
				mat_v[i][j]=0.;
				for(int k=0;k<chiSQ;k++)
				{
					if(site==0)
					{
						if(r==1)
							for(int l=0;l<chiSQ;l++)
								mat_v[i][j]+=mat_u[i][k]*Bp1[k][l]*Bp2[l][j];
						else
							for(int l=0;l<chiSQ;l++)
								mat_v[i][j]+=mat_u[i][k]*Bp1[k][l]*B2[l][j];
					}
					else if(site!=r && site!=r+1)
						mat_v[i][j]+=mat_u[i][k]*B12[k][j];
					else if(site==r)
						for(int l=0;l<chiSQ;l++)
							mat_v[i][j]+=mat_u[i][k]*Bp1[k][l]*B2[l][j];
					else if(site==r+1)
						for(int l=0;l<chiSQ;l++)
							mat_v[i][j]+=mat_u[i][k]*B1[k][l]*Bp2[l][j];
				}
			}
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
				mat_u[i][j]=mat_v[i][j];
		}
		for(int i=0;i<chiSQ;i++)
			norm+=mat_u[i][i];
		SUM_norm=0.;
		for(int i=0;i<chiSQ;i++)
			SUM_norm+=pow(S_Bp1[i]*S_Bp2[i],L*0.5);
	}
	for(int k=0;k<chiSQ;k++)
	{
		delete [] mat_u[k];
		delete [] mat_v[k];
		delete [] Bp1[k];
		delete [] Bp2[k];
		delete [] B1[k];
		delete [] B2[k];
		delete [] Bp12[k];
		delete [] B12[k];
	}
	delete [] mat_u;
	delete [] mat_v;
	delete [] Bp1;
	delete [] Bp2;
	delete [] B1;
	delete [] B2;
	delete [] Bp12;
	delete [] B12;
	delete [] svd_A; delete [] svd_U; delete [] svd_Vt;
	delete [] S_B1; delete [] S_B2; delete [] S_Bp1; delete [] S_Bp2;
	delete [] S_B12; delete [] S_Bp12;

	return norm;
}
void SUBLOUTINE_normalizing_state(double ****A, double **lam)
{
	double norm=0., x;
	
	x=1./(2.*L);
	norm=pow(NORM,x);
	for(int site=0;site<L;site++)
	for(int n=0;n<phy_dim;n++)
	for(int a1=0;a1<bond_dim;a1++)
	for(int a2=0;a2<bond_dim;a2++)
		A[site%2][n][a1][a2]/=norm;
}
double SUBLOUTINE_exact(int size)
{
	double sum=0,k;
	for(int n=0;n<size;n++)
	{
		k=(2.0*CONST_pi*n+0.5)/(double)size;
		sum-=pow(1.0+g*g-2.0*g*cos(k),0.5);
	}
	sum/=size;
	return sum;
}
void SUBLOUTINE_fprint_columnhead()
{
	FILE *result_E, *result_A, *result_B, *result_C, *result_lam;

	result_E=fopen(File_printf,"w");
	fprintf(result_E,"#L\tchi\tg\t\tepsilon\t\th\t\tE\t\tdelta_E\t\tcount\tre\n");
	fclose(result_E);
	result_lam=fopen(File_lambda,"w");
	fprintf(result_lam,"#g\t\tchi\t[site][a]\tlambda[0][a]\tlambda[1][a]\tError($4,$5)\tnorm\t\tsum(norm)\n");
	fclose(result_lam);
	result_A=fopen(File_matrix_A,"w");
	fprintf(result_A,"#g\t\tchi\t[site][n][a1][a2]\tA[0][n][a1][a2]\tA[1][n][a1][a2]\tError(A1,At2)\n");
	fclose(result_A);
	result_B=fopen(File_magnetization,"w");
	fprintf(result_B,"#L\tchi\tJ\tg\th\t<sigmaZ_0>\t<sigmaX_0>\tnorm\t\t[G(L/2)]^0.5\tcount\tre\n");
	fclose(result_B);
	result_C=fopen(File_correlator,"w");
	fprintf(result_C,"#L\tchi\tg\th\tr\tC(r)\t\tcount\tre\n");
	fclose(result_C);

}
void SUBLOUTINE_fprint_energy()
{
	double *Energy_0, hamiltonian=0.;
	double exact_1024=SUBLOUTINE_exact(1024);
	FILE *result;

	result=fopen(File_printf,"a");
	Energy_0=new double [2];
	
	for(int site=0;site<1;site++)
		Energy_0[site]=TNS_energy(backup_s[site][0],epsilon);
	for(int site=0;site<1;site++)
		fprintf(result,"%d\t%d\t%.4e\t%.4e\t%.4e\t%.8e\t%.8e\t%d\t%d\n",L,bond_dim,g,epsilon,h,Energy_0[site],ERROR(Energy_0[site],exact_1024),converge_count,non_converge);

	delete [] Energy_0;
	fclose(result);
}
void SUBLOUTINE_fprintf_lambda(double **lam)
{
	FILE *result;

	result=fopen(File_lambda,"a");
	for(int i=0;i<bond_dim;i++)
		fprintf(result,"%.3e\t%d\t[s][%d]\t\t%.8e\t%.8e\t%.8e\t%.8e\t%.8e\n",g,bond_dim,i,lam[0][i],lam[1][i],ERROR(lam[1][i],lam[0][i]),NORM,SUM_norm);
	fclose(result);
}
void SUBLOUTINE_fprint_matrix(double ****A, double **lam)
{
	FILE *result;
		
	result=fopen(File_matrix_A,"a");
	for(int n=0;n<phy_dim;n++)
	for(int a1=0;a1<bond_dim;a1++)
	for(int a2=0;a2<bond_dim;a2++)
		fprintf(result,"%.3e\t%d\t[s][%d][%d][%d]\t\t%.8e\t%.8e\t%.8e\n",g,bond_dim,n,a1,a2,A[0][n][a1][a2],A[1][n][a1][a2],ERROR(fabs(A[1][n][a1][a2]),fabs(A[0][n][a2][a1])));
	fprintf(result,"\n");
	fclose(result);
}
void SUBLOUTINE_fprint_magnetization(double ****A, double **lam)
{
	double magnet_z, magnet_x;
	double norm_0, norm_r, norm_r0;
	double GL2;	//G(L/2)
	int L2=(int)(L*0.5);
	FILE *result;

	magnet_z=SUBLOUTINE_norm(Op_sigmaZ,0,A,lam,0);
	magnet_x=SUBLOUTINE_norm(Op_sigmaX,0,A,lam,0);
	norm_r0=SUBLOUTINE_norm(Op_sigmaZ,L2,A,lam,1);

	GL2=norm_r0;
	
	result=fopen(File_magnetization,"a");
	fprintf(result,"%d\t%d\t%.4f\t%.4f\t%.0e\t%.8e\t%.8e\t%.8e\t%.8e\t%d\t%d\n",L,bond_dim,J,g,h,magnet_z/NORM,magnet_x/NORM,NORM,pow(GL2,0.5)/NORM,converge_count,non_converge);
	fclose(result);
}
void SUBLOUTINE_fprint_correlator(int **Operator, double ****A, double **lam)
{
	FILE *result;
	double norm_r0;

	result=fopen(File_correlator,"a");
	for(int site=1;site<L;site++)
	{
		norm_r0=SUBLOUTINE_norm(Operator,site,A,lam,1);
		fprintf(result,"%d\t%d\t%.4f\t%.0e\t%d\t%.8e\t%d\t%d\n",L,bond_dim,g,h,site,norm_r0/NORM,converge_count,non_converge);
	}
	fclose(result);
}
void printFORsteps()
{
	int steps, iter=1e2;
	double before=0.;
	SUBLOUTINE_fprint_columnhead();
	SUBLOUTINE_set_matrices();
	SUBLOUTINE_initializing();
	SUBLOUTINE_set_operators();

	steps=0;	converge_count=0;	non_converge=0;	
	epsilon=ini_ep;	SUBLOUTINE_set_table();
	for(int i=0;i<iter;i++)
	{
		SUBLOUTINE_TEBD(matrix_A,lambda);
		converge_count++;	steps++;
		SUBLOUTINE_fprint_energy();
	}
	SUBLOUTINE_unset_table();	epsilon=fin_ep;	SUBLOUTINE_set_table();
	while(fabs(before-TNS_energy(backup_s[0][0],epsilon))>Tolerance && converge_count<1e5)
	{
		before=TNS_energy(backup_s[0][0],epsilon);
		SUBLOUTINE_TEBD(matrix_A,lambda);
		converge_count++;	steps++;
		SUBLOUTINE_fprint_energy();
	}
//	SUBLOUTINE_fprint_magnetization(matrix_A, lambda);
//	SUBLOUTINE_fprint_correlator(Op_sigmaZ, matrix_A, lambda);
//	SUBLOUTINE_fprint_matrix(matrix_A, lambda);
	SUBLOUTINE_unset_operators();
	SUBLOUTINE_unset_matrices();
	SUBLOUTINE_unset_table();
}
void backup_main()
{
	int steps, iter=1e2;
	double before=0., after=1.;
	SUBLOUTINE_fprint_columnhead();
	SUBLOUTINE_set_matrices();
	SUBLOUTINE_set_operators();
	steps=0;	converge_count=0;	non_converge=0;	
	for(g=g_initial;g<g_final;g+=g_gap)
	{
		SUBLOUTINE_initializing();
		before=0.;	converge_count=0;	non_converge=0;
		SUBLOUTINE_set_table();
		SUBLOUTINE_TEBD(matrix_A,lambda);
		//while(fabs(before-after)>Tolerance)
		while(fabs(backup_s[1][0]-backup_s[0][0])>1e-18)
		{
			//before=after;
			converge_count++;
			if(converge_count>=1e5||ERROR(backup_s[0][0],backup_s[0][1])<1e-3)
			{
				if(non_converge>=1e2)
					break;
				SUBLOUTINE_initializing();
				non_converge++;
				converge_count=0;
			}
			SUBLOUTINE_TEBD(matrix_A,lambda);
			//after=backup_s[0][0];
		}
		//SUBLOUTINE_normalizing_state(matrix_A, lambda);
		SUBLOUTINE_fprint_matrix(matrix_A, lambda);
		NORM=SUBLOUTINE_norm(Op_identity,L,matrix_A,lambda,0);
		SUBLOUTINE_fprintf_lambda(lambda);
		SUBLOUTINE_fprint_energy();
		SUBLOUTINE_fprint_magnetization(matrix_A,lambda);
		SUBLOUTINE_fprint_correlator(Op_sigmaZ,matrix_A,lambda);
		SUBLOUTINE_unset_table();
	}
	SUBLOUTINE_unset_operators();
	SUBLOUTINE_unset_matrices();
}
void exact_diagonalizaion()
{
	double **H;
	double a,b,c,d, min=0;
	double *A, *U, *S, *Vt;
	int phy4=(int)pow((double)phy_dim,4);
	int phy3=(int)pow((double)phy_dim,3);
	int phy2=(int)pow((double)phy_dim,2);
	int phy1=(int)phy_dim;
	int phy4SQ=phy4*phy4;

	H=new double *[phy4];
	A=new double [phy4SQ]; U=new double [phy4SQ]; S=new double [phy4SQ]; Vt=new double [phy4SQ];
	for(int i=0;i<phy4;i++)
		H[i]=new double [phy4];
	for(int i1=0;i1<phy_dim;i1++)
	for(int j1=0;j1<phy_dim;j1++)
	for(int k1=0;k1<phy_dim;k1++)
	for(int l1=0;l1<phy_dim;l1++)
	for(int i2=0;i2<phy_dim;i2++)
	for(int j2=0;j2<phy_dim;j2++)
	for(int k2=0;k2<phy_dim;k2++)
	for(int l2=0;l2<phy_dim;l2++)
	{
		a=-J*Op_sigmaZ[i1][i2]*Op_sigmaZ[j1][j2]*Op_identity[k1][k2]*Op_identity[l1][l2]-J*h*Op_sigmaZ[i1][i2]*Op_identity[j1][j2]*Op_identity[k1][k2]*Op_identity[l1][l2]-J*g*Op_sigmaX[i1][i2]*Op_identity[j1][j2]*Op_identity[k1][k2]*Op_identity[l1][l2];
		b=-J*Op_identity[i1][i2]*Op_sigmaZ[j1][j2]*Op_sigmaZ[k1][k2]*Op_identity[l1][l2]-J*h*Op_identity[i1][i2]*Op_sigmaZ[j1][j2]*Op_identity[k1][k2]*Op_identity[l1][l2]-J*g*Op_identity[i1][i2]*Op_sigmaX[j1][j2]*Op_identity[k1][k2]*Op_identity[l1][l2];
		c=-J*Op_identity[i1][i2]*Op_identity[j1][j2]*Op_sigmaZ[k1][k2]*Op_sigmaZ[l1][l2]-J*h*Op_identity[i1][i2]*Op_identity[j1][j2]*Op_sigmaZ[k1][k2]*Op_identity[l1][l2]-J*g*Op_identity[i1][i2]*Op_identity[j1][j2]*Op_sigmaX[k1][k2]*Op_identity[l1][l2];
		d=-J*Op_sigmaZ[i1][i2]*Op_identity[j1][j2]*Op_identity[k1][k2]*Op_sigmaZ[l1][l2]-J*h*Op_identity[i1][i2]*Op_identity[j1][j2]*Op_identity[k1][k2]*Op_sigmaZ[l1][l2]-J*g*Op_identity[i1][i2]*Op_identity[j1][j2]*Op_identity[k1][k2]*Op_sigmaX[l1][l2];
		A[(i1*phy3+j1*phy2+k1*phy1+l1)*phy4+(i2*phy3+j2*phy2+k2*phy1+l2)]=H[i1*phy3+j1*phy2+k1*phy1+l1][i2*phy3+j2*phy2+k2*phy1+l2]=a+b+c+d;
		if(a+b+c+d<min)
			min=a+b+c+d;
	}
	printf("min=%5e\n",min);
	//print_matrix("H",phy4,phy4,H);
	check_matrix_symmetry("H",H,phy4);
	SUBLOUTINE_DGESVD(A,U,S,Vt,phy4,phy4);
	print_array("S",phy4,1,S);
	for(int i=0;i<phy4;i++)
		delete [] H[i];
	delete [] H;
	delete [] A; delete [] U; delete [] S; delete [] Vt; 
}
void check_TransSym_Alam(double ****A, double **lam)
{
	double *mat_A, *U, *Vt, *S;
	mat_A=new double [bond_dim*bond_dim]; U=new double [bond_dim*bond_dim]; Vt=new double [bond_dim*bond_dim]; S=new double [bond_dim];
	for(int n=0;n<phy_dim;n++)
	{
		for(int i=0;i<bond_dim;i++)
		for(int j=0;j<bond_dim;j++)
			//mat_A[i+j*bond_dim]=A[0][n][i][j]*pow(lambda[1][i]*lambda[0][j],0.5);
			mat_A[i+j*bond_dim]=A[0][n][i][j]*lambda[0][j];
		SUBLOUTINE_DGESVD(mat_A,U,S,Vt,bond_dim,bond_dim);
		printf("n=%d\n",n);
		print_array("U of A[0][n]*lam",bond_dim,bond_dim,U);
		print_array("singular values of A[0][n]*lam",bond_dim,1,S);
		print_array("Vt of A[0][n]*lam",bond_dim,bond_dim,Vt);
	}
}
int check_matrix_symmetry(char *word, double **matrix, int M)
{
	double error;
	for(int i=0;i<M;i++)
	for(int j=i+1;j<M;j++)
	{
		error=fabs((matrix[i][j]-matrix[j][i])/MIN(fabs(matrix[i][j]),fabs(matrix[j][i])));
		if(error>1e-5)
		{
			printf(" %s is non-symmetry came out at (%d,%d)-th, and the error is %.8e\n",word,i+1,j+1,error);
			return 0;
		}
	}
	printf(" %s is a symmetric matrix\n",word);
	return 0;		
}
void test()
{
	int re;
	int phySQ=phy_dim*phy_dim;
	double expect, Magnet;
	double exact_energy, TNS_energy;
	SUBLOUTINE_set_matrices();
	SUBLOUTINE_set_operators();
	for(g=g_initial;g<g_final;g+=g_gap)
	{
		SUBLOUTINE_set_table();
		SUBLOUTINE_initializing();
		SUBLOUTINE_TEBD(matrix_A,lambda);
		converge_count=1;	re=0;
		while(true)
		{
			if(ABS(ERROR(backup_s[1][0],backup_s[0][0]))<1e-18)
			{
				if(ABS(ERROR(matrix_A[0][0][0][0],matrix_A[1][0][0][0]))<1e-5)
					break;
				SUBLOUTINE_initializing();
				SUBLOUTINE_TEBD(matrix_A,lambda);
				converge_count=1;	re++;
			}
			SUBLOUTINE_TEBD(matrix_A,lambda);
			converge_count++;
			if(converge_count>1e5)
			{
				if(re>1e1)
					break;
				SUBLOUTINE_initializing();
				SUBLOUTINE_TEBD(matrix_A,lambda);
				converge_count=1;	re++;
			}
		}
		TNS_energy=TNS_energy(backup_s[0][0],epsilon);
		//TNS_energy=TNS_energy(lamRSS,epsilon);
		exact_energy=SUBLOUTINE_exact(1024);
		printf("L=%d\tg=%.4f\n",L,g);
		NORM=SUBLOUTINE_norm(Op_identity,L,matrix_A,lambda,0);
		Magnet=SUBLOUTINE_norm(Op_sigmaZ,L,matrix_A,lambda,0);
		printf("norm=%.8e Error(<m>)=%.8e <M_0>=%.8e Error(E)=%.8e count=%d, re=%d\n",NORM,ERROR(Magnet,SUM_norm),Magnet/NORM,ERROR(exact_energy,TNS_energy),converge_count,re);
		printf("A[0][0][0][0]=%.8e\tA[1][0][0][0]=%.8e\tlam[0][0]=%.8e\n",matrix_A[0][0][0][0],matrix_A[1][0][0][0],lambda[0][0]);
		printf("A[0][1][0][0]=%.8e\tA[1][1][0][0]=%.8e\tlam[1][0]=%.8e\n",matrix_A[0][1][0][0],matrix_A[1][1][0][0],lambda[1][0]);
		printf("A[0][0][0][1]=%.8e\tA[1][0][0][1]=%.8e\tlam[0][1]=%.8e\n",matrix_A[0][0][0][1],matrix_A[1][0][0][1],lambda[0][1]);
		printf("A[0][0][1][0]=%.8e\tA[1][0][1][0]=%.8e\tlam[1][1]=%.8e\n",matrix_A[0][0][1][0],matrix_A[1][0][1][0],lambda[1][1]);
		printf("A[0][1][0][1]=%.8e\tA[1][1][0][1]=%.8e\tlam[0][2]=%.8e\n",matrix_A[0][1][0][1],matrix_A[1][1][0][1],lambda[0][2]);
		printf("A[0][1][1][0]=%.8e\tA[1][1][1][0]=%.8e\tlam[1][2]=%.8e\n",matrix_A[0][1][1][0],matrix_A[1][1][1][0],lambda[1][2]);
		//exact_diagonalizaion();
		SUBLOUTINE_unset_table();
	}
	SUBLOUTINE_unset_operators();
	SUBLOUTINE_unset_matrices();
}
