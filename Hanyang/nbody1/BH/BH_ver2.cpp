#include <iostream>
#include <cstdio>
#include <ctime>
#include <cmath>
#include "utils.h"
#include "mt19937ar.h"
using namespace std;

#define DIV(a,b)	((ABS(a)<=1.e-16 || ABS(b)<=1.e-16) ? (0.):(a/b))
#define TNS_ENERGY(lam_0,ep) ((lam_0 > 1.e-10) ? (-log(lam_0)/ep) : 1.e2)
#define ERROR(a,b)	((a==b) ? (0.):((b-a)/ABS(MIN(a,b))))

#define File_Gamma "_A.dat"
#define File_lambda "_lam.dat"
#define File_magnetization "_g-m.dat"	//g,epsilon,chi_X-Y axis.dat
#define File_printf "_g-dE.dat"		//g,epsilon,chi_X-Y axis.dat
#define File_correlator "_r-C(r).dat"
//#define def_L 128	//a size of the lattice(must be even #)
#define def_l 2		//a size of an unit cell of the lattice
#define n_max 6		//maximum occupation-number
#define def_n (n_max+1)	//physical dimension(spin up/down)
#define def_chi 13	//bond dimension chi
int def_L;
double ini_ep=0.005, fin_ep=0.005;
double U=1., t=0.26, mu=0.1586, epsilon=0.005, twist=0.;
doublecomplex ****Gamma, ****Table;
double **lambda, **backup_s;
doublecomplex *TEBD_a, *TEBD_u, *TEBD_vt;
double *TEBD_s, **backup_s;
double **Op_identity, **Op_occupation;	//Operator matrices
int count_converge, count_nonconverge;
int thetadim=def_n*def_chi;
double E_NoTwist, entropy_S;
double NORM, SUM_norm, lamRSS;

/////////////////// prototypes ///////////////////
void set_tensors();
void unset_tensors();
void initializing_tensors();	//initializing tensor Gamma & lambda
void set_operators();
void unset_operators();
void set_table();	//<m1 m2|exp{-tau*H}|n1 n2>
void unset_table();
void TEBD(double ****Gam, double **lam);
double normalizing_lambda(double div, double *w, int i);
double expectation_value(double **Operator, double ****Gam, double **lam, int rank, int r);
int check_matrix_symmetry(char *word, double **matrix, int M);
void backup_main();
//////////////////////////////////////////////////
////////////////////// main //////////////////////
int main()
{
	return 0;
}
//////////////////////////////////////////////////
void set_tensors()
{
	Gamma=new doublecomplex ***[def_l];
	lambda=new double *[def_l];
	backup_s=new double *[def_l];
	TEBD_a=new doublecomplex [thetadim*thetadim];
	TEBD_u=new doublecomplex [thetadim*thetadim];
	TEBD_s=new double [thetadim*thetadim];
	TEBD_vt=new doublecomplex [thetadim*thetadim];
	for(int site=0;site<def_l;site++)
	{
		Gamma[site]=new doublecomplex **[def_n];
		lambda[site]=new double [def_chi];
		backup_s[site]=new double [def_chi];
		for(int n=0;n<def_n;n++)
		{
			Gamma[site][n]=new doublecomplex *[def_chi];
			for(int a=0;a<def_chi;a++)
				Gamma[site][n][a]=new doublecomplex [def_chi];
		}
	}
}
void unset_tensors()
{
	for(int site=0;site<def_l;site++)
	{
		for(int n=0;n<def_n;n++)
		{
			for(int a=0;a<def_chi;a++)
				delete [] Gamma[site][n][a];
			delete [] Gamma[site][n];
		}
		delete [] Gamma[site];
		delete [] lambda[site];
		delete [] backup_s[site];
	}
	delete [] TEBD_a;
	delete [] TEBD_u;
	delete [] TEBD_s;
	delete [] TEBD_vt;
	delete [] Gamma;
	delete [] lambda;
	delete [] backup_s;
}
void initializing_tensors()
{
	init_genrand((unsigned)time(NULL));
	for(int site=0;site<def_l;site++)
	for(int a2=0;a2<def_chi;a2++)
	{
		for(int n=0;n<def_n;n++)
		for(int a1=0;a1<def_chi;a1++)
		{
			Gamma[site][n][a1][a2].r=genrand_real3()-0.5;
			Gamma[site][n][a1][a2].i=genrand_real3()-0.5;
		}
		lambda[site][a2]=genrand_real3()-0.5;
	}
}
void set_operators()
{
	Op_identity=new double *[def_n];
	Op_occupation=new double *[def_n];

	for(int n=0;n<def_n;n++)
	{
		Op_identity[n]=new double [def_n];
		Op_occupation[n]=new double [def_n];
		for(int m=0;m<def_n;m++)
		{
			Op_identity[n][m]=((n==m)?(1.):(0.));
			Op_occupation[n][m]=((n==m)?(m):(0.));
		}
	}
}
void unset_operators()
{
	for(int i=0;i<def_n;i++)
	{
		delete [] Op_identity[i];
		delete [] Op_occupation[i];
	}
	delete [] Op_identity;
	delete [] Op_occupation;
}
void set_table()
{
	doublecomplex ****h_ij, ****h_prime, ****dummy;

	Table=new doublecomplex ***[def_n];
	h_ij=new doublecomplex ***[def_n];
	h_prime=new doublecomplex ***[def_n];
	dummy=new doublecomplex ***[def_n];
	for(int i=0;i<def_n;i++)
	{
		Table[i]=new doublecomplex **[def_n];
		h_ij[i]=new doublecomplex **[def_n];
		h_prime[i]=new doublecomplex **[def_n];
		dummy[i]=new doublecomplex **[def_n];
		for(int j=0;j<def_n;j++)
		{
			Table[i][j]=new doublecomplex *[def_n];
			h_ij[i][j]=new doublecomplex *[def_n];
			h_prime[i][j]=new doublecomplex *[def_n];
			dummy[i][j]=new doublecomplex *[def_n];
			for(int k=0;k<def_n;k++)
			{
				Table[i][j][k]=new doublecomplex [def_n];
				h_ij[i][j][k]=new doublecomplex [def_n];
				h_prime[i][j][k]=new doublecomplex [def_n];
				dummy[i][j][k]=new doublecomplex [def_n];
			}
		}
	}
	for(int m1=0;m1<def_n;m1++)
	for(int m2=0;m2<def_n;m2++)
	for(int n1=0;n1<def_n;n1++)
	for(int n2=0;n2<def_n;n2++)
	{
		double a=0., b1=0., b2=0., c1=0., c2=0.;
		if(m1==n1 && m2==n2)
			a=U*0.25*(n1*n1+n2*n2)-0.5*(U*0.5+mu)*(n1+n2);
		if(m1==n1+1 && m2==n2-1)
		{
			b1=-t*pow((double)(n1+1)*n2,0.5)*cos(twist);
			b2=-t*pow((double)(n1+1)*n2,0.5)*(-sin(twist));
		}
		if(m1==n1-1 && m2==n2+1)
		{
			c1=-t*pow((double)n1*(n2+1),0.5)*cos(twist);
			c2=-t*pow((double)n1*(n2+1),0.5)*sin(twist);
		}
		h_ij[m1][m2][n1][n2].r=a+b1+c1;
		h_ij[m1][m2][n1][n2].i=b2+c2;
		h_prime[m1][m2][n1][n2].r=((m1==n1&&m2==n2)?(1.):(0.));
		h_prime[m1][m2][n1][n2].i=0.;
		Table[m1][m2][n1][n2].r=((m1==n1&&m2==n2)?(1.):(0.));
		Table[m1][m2][n1][n2].i=0.;
	}
	for(int count=1;count<20;count++)
	{
		for(int m1=0;m1<def_n;m1++)
		for(int m2=0;m2<def_n;m2++)
		for(int n1=0;n1<def_n;n1++)
		for(int n2=0;n2<def_n;n2++)
		{
			dummy[m1][m2][n1][n2].r=0.;
			dummy[m1][m2][n1][n2].i=0.;
			for(int k1=0;k1<def_n;k1++)
			for(int k2=0;k2<def_n;k2++)
			{
				dummy[m1][m2][n1][n2].r+=h_prime[i][k].r*h_ij[k][j].r-h_prime[i][k].i*h_ij[k][j].i;
				dummy[m1][m2][n1][n2].i+=h_prime[i][k].r*h_ij[k][j].i+h_prime[i][k].i*h_ij[k][j].r;
			}
		}
		for(int m1=0;m1<def_n;m1++)
		for(int m2=0;m2<def_n;m2++)
		for(int n1=0;n1<def_n;n1++)
		for(int n2=0;n2<def_n;n2++)
		{
			Table[m1][m2][n1][n2].r+=h_prime[m1][m2][n1][n2].r=dummy[m1][m2][n1][n2].r*DIV(-epsilon,(double)count);
			Table[m1][m2][n1][n2].i+=h_prime[m1][m2][n1][n2].i=dummy[m1][m2][n1][n2].i*DIV(-epsilon,(double)count);
		}
	}
	for(int i=0;i<def_n;i++)
	{
		for(int j=0;j<def_n;j++)
		{
			for(int k=0;k<def_n;k++)
			{
				delete [] h_ij[i][j][k];
				delete [] h_prime[i][j][k];
				delete [] dummy[i][j][k];
			}
			delete [] h_ij[i][j];
			delete [] h_prime[i][j];
			delete [] dummy[i][j];
		}
		delete [] h_ij[i];
		delete [] h_prime[i];
		delete [] dummy[i];
	}
	delete [] h_ij;
	delete [] h_prime;
	delete [] dummy;
}
void unset_table()
{
	for(int i=0;i<def_n;i++)
	{
		for(int j=0;j<def_n;j++)
		{
			for(int k=0;k<def_n;k++)
				delete [] Table[i][j][k];
			delete [] Table[i][j];
		}
		delete [] Table[i];
	}
	delete [] Table;
}
void TEBD(double ****Gam, double **lam)
{
	int lda=thetadim, ldu=thetadim, ldvt=thetadim;

	for(int site=0;site<def_l;site+=2)
	{
		int L_left=(site-1+def_l)%def_l, L_right=(site+1)%def_l;
		for(int m1=0;m1<def_n;m1++)
		for(int m2=0;m2<def_n;m2++)
		for(int aL=0;aL<def_chi;aL++)
		for(int a2=0;a2<def_chi;a2++)
		{
			TEBD_a[(m1+aL*def_n)+(m2+a2*def_n)*lda].r=0.;
			TEBD_a[(m1+aL*def_n)+(m2+a2*def_n)*lda].i=0.;
			for(int n1=0;n1<def_n;n1++)
			for(int n2=0;n2<def_n;n2++)
			for(int a1=0;a1<def_chi;a1++)
			{
				TEBD_a[(m1+aL*def_n)+lda*(m2+a2*def_n)].r += lam[L_left][aL]*lam[site][a1]*lam[L_right][a2] * ( Table[m1][m2][n1][n2].r*(Gam[site][n1][aL][a1].r*Gam[L_right][n2][a1][a2].r-Gam[site][n1][aL][a1].i*Gam[L_right][n2][a1][a2].i) - Table[m1][m2][n1][n2].i*(Gam[site][n1][aL][a1].i*Gam[L_right][n2][a1][a2].r+Gam[site][n1][aL][a1].r*Gam[L_right][n2][a1][a2].i) );
				TEBD_a[(m1+aL*def_n)+lda*(m2+a2*def_n)].i += lam[L_left][aL]*lam[site][a1]*lam[L_right][a2] * ( Table[m1][m2][n1][n2].r*(Gam[site][n1][aL][a1].i*Gam[L_right][n2][a1][a2].r+Gam[site][n1][aL][a1].r*Gam[L_right][n2][a1][a2].i) + Table[m1][m2][n1][n2].i*(Gam[site][n1][aL][a1].r*Gam[L_right][n2][a1][a2].r-Gam[site][n1][aL][a1].i*Gam[L_right][n2][a1][a2].i) );
			}
		}
		SUBLOUTINE_ZGESVD(TEBD_a,TEBD_u,TEBD_s,TEBD_vt,thetadim,thetadim);
		for(int p=0;p<def_n;p++)
		for(int b0=0;b0<def_chi;b0++)
		for(int b1=0;b1<def_chi;b1++)
		{
			Gam[site][p][b0][b1].r=DIV(TEBD_u[(p+b0*def_n)+ldu*(b1)].r,lam[L_left][b0]);
			Gam[site][p][b0][b1].i=DIV(TEBD_u[(p+b0*def_n)+ldu*(b1)].i,lam[L_left][b0]);
			Gam[L_right][p][b0][b1].r=DIV(TEBD_vt[(b0)+ldvt*(p+b1*def_n)].r,lam[L_right][b1]);
			Gam[L_right][p][b0][b1].i=DIV(TEBD_vt[(b0)+ldvt*(p+b1*def_n)].i,lam[L_right][b1]);
		}
		lamRSS=0.;
		for(int i=0;i<def_chi;i++)
			lamRSS+=TEBD_s[i]*TEBD_s[i];
		lamRSS=pow(lamRSS,0.5);
		for(int i=0;i<def_chi;i++)
		{
			backup_s[site][i]=TEBD_s[i];
			lam[site][i]=normalizing_lambda(TEBD_s[0],TEBD_s,i);
			//lam[site][i]=normalizing_lambda(lamRSS,TEBD_s,i);
		}
		if(site+2==def_l)
			site=-1;
	}
}
double normalizing_lambda(double div, double *w, int i)
{
	return (div <= 0. || w[i] <= 0.) ? (0.) : (w[i]/div);
}
double expectation_value(double **Operator, double ****Gam, double **lam, int rank, int r)
{
	double **Bp1, **Bp2, **B1, **B2, **B12, **B21, **Bp12;
	double *svd_A, *svd_U, *svd_Vt, *S_B1, *S_B2, *S_Bp1, *S_Bp2, *S_B12, *S_B21, *S_Bp12;
	double **B_tot, **dummy;
	int chiSQ=def_chi*def_chi;
	
	Bp1=new double *[chiSQ];
	Bp2=new double *[chiSQ];
	B1=new double *[chiSQ];
	B2=new double *[chiSQ];
	B12=new double *[chiSQ];
	B21=new double *[chiSQ];
	Bp12=new double *[chiSQ];
	svd_A=new double [chiSQ*chiSQ]; svd_U=new double [chiSQ*chiSQ]; svd_Vt=new double [chiSQ*chiSQ];
	B_tot=new double *[chiSQ]; dummy=new double *[chiSQ];
	S_B1=new double [chiSQ]; S_B2=new double [chiSQ];
	S_Bp1=new double [chiSQ]; S_Bp2=new double [chiSQ];
	S_B12=new double [chiSQ]; S_B21=new double [chiSQ]; S_Bp12=new double [chiSQ];

	for(int k=0;k<chiSQ;k++)
	{
		Bp1[k]=new double [chiSQ];
		Bp2[k]=new double [chiSQ];
		B1[k]=new double [chiSQ];
		B2[k]=new double [chiSQ];
		B12[k]=new double [chiSQ];
		B21[k]=new double [chiSQ];
		Bp12[k]=new double [chiSQ];
		B_tot[k]=new double [chiSQ];
		dummy[k]=new double [chiSQ];
	}
	for(int i=0;i<chiSQ;i++)
	for(int j=0;j<chiSQ;j++)
	{
		Bp1[i][j]=0.;
		Bp2[i][j]=0.;
		B1[i][j]=0.;
		B2[i][j]=0.;
		B12[i][j]=0.;
		B21[i][j]=0.;
		Bp12[i][j]=0.;
		B_tot[i][j]=((i==j) ? (1.):(0.));
		dummy[i][j]=0.;
	}
	for(int ap1=0;ap1<def_chi;ap1++)
	for(int a1=0;a1<def_chi;a1++)
	for(int ap2=0;ap2<def_chi;ap2++)
	for(int a2=0;a2<def_chi;a2++)
	{
		for(int n=0;n<def_n;n++)
		for(int m=0;m<def_n;m++)
		{
			//B1[ap1+def_chi*a1][ap2+def_chi*a2]+=Op_identity[n][m]*pow(lam[1][ap1]*lam[0][ap2]*lam[1][a1]*lam[0][a2],0.5)*Gam[0][n][ap1][ap2]*Gam[0][m][a1][a2];
			//B2[ap1+def_chi*a1][ap2+def_chi*a2]+=Op_identity[n][m]*pow(lam[0][ap1]*lam[1][ap2]*lam[0][a1]*lam[1][a2],0.5)*Gam[1][n][ap1][ap2]*Gam[1][m][a1][a2];
			//Bp1[ap1+def_chi*a1][ap2+def_chi*a2]+=Operator[n][m]*pow(lam[1][ap1]*lam[0][ap2]*lam[1][a1]*lam[0][a2],0.5)*Gam[0][n][ap1][ap2]*Gam[0][m][a1][a2];
			//Bp2[ap1+def_chi*a1][ap2+def_chi*a2]+=Operator[n][m]*pow(lam[0][ap1]*lam[1][ap2]*lam[0][a1]*lam[1][a2],0.5)*Gam[1][n][ap1][ap2]*Gam[1][m][a1][a2];
			B1[ap1+def_chi*a1][ap2+def_chi*a2]+=Op_identity[n][m]*pow(lam[1][ap1]*lam[0][ap2]*lam[1][a1]*lam[0][a2],0.5)*Gam[0][n][ap2][ap1]*Gam[0][m][a1][a2];
			B2[ap1+def_chi*a1][ap2+def_chi*a2]+=Op_identity[n][m]*pow(lam[0][ap1]*lam[1][ap2]*lam[0][a1]*lam[1][a2],0.5)*Gam[1][n][ap2][ap1]*Gam[1][m][a1][a2];
			Bp1[ap1+def_chi*a1][ap2+def_chi*a2]+=Operator[n][m]*pow(lam[1][ap1]*lam[0][ap2]*lam[1][a1]*lam[0][a2],0.5)*Gam[0][n][ap2][ap1]*Gam[0][m][a1][a2];
			Bp2[ap1+def_chi*a1][ap2+def_chi*a2]+=Operator[n][m]*pow(lam[0][ap1]*lam[1][ap2]*lam[0][a1]*lam[1][a2],0.5)*Gam[1][n][ap2][ap1]*Gam[1][m][a1][a2];
		}
	}
	for(int i=0;i<chiSQ;i++)
	for(int j=0;j<chiSQ;j++)
	for(int k=0;k<chiSQ;k++)
	{
		B12[i][j]+=B1[i][k]*B2[k][j];
		B21[i][j]+=B2[i][k]*B1[k][j];
		Bp12[i][j]+=Bp1[i][k]*Bp2[k][j];
	}
	//// get a singular value(=eigenvalue) of each B matrix ////
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
		svd_A[i+j*chiSQ]=B21[i][j];
	SUBLOUTINE_DGESVD(svd_A,svd_U,S_B21,svd_Vt,chiSQ,chiSQ);
	for(int i=0;i<chiSQ;i++)
	for(int j=0;j<chiSQ;j++)
		svd_A[i+j*chiSQ]=Bp12[i][j];
	SUBLOUTINE_DGESVD(svd_A,svd_U,S_Bp12,svd_Vt,chiSQ,chiSQ);
	for(int i=0;i<chiSQ;i++)
	for(int j=0;j<chiSQ;j++)
	for(int k=0;k<chiSQ;k++)
		dummy[i][j]+=svd_U[i+k*chiSQ]*svd_Vt[k+j*chiSQ];
	////////////////////////////////////////////////////////////
	double norm=0.;
	/////////// <psi|O|psi> //////////
	if(rank==1 && r<def_L)
	{
		for(int site=0;site<def_L;site+=2)
		{
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
			{
				dummy[i][j]=0.;
				for(int k=0;k<chiSQ;k++)
				{
					if(site!=r && site!=r+1)
						dummy[i][j]+=B_tot[i][k]*B12[k][j];
					else if(site==r)
					for(int l=0;l<chiSQ;l++)
						dummy[i][j]+=B_tot[i][k]*Bp1[k][l]*B2[l][j];
					else if(site==r+1)
					for(int l=0;l<chiSQ;l++)
						dummy[i][j]+=B_tot[i][k]*B1[k][l]*Bp2[l][j];
				}
			}
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
				B_tot[i][j]=dummy[i][j];
		}
		for(int i=0;i<chiSQ;i++)
			norm+=B_tot[i][i];
	}
	else if(rank==1)
	{
		check_matrix_symmetry("Bp12",Bp12,chiSQ);
		printf("S_Bp12[0]-1.=%.8e\n",S_Bp12[0]-1.);
		for(int site=0;site<def_L;site+=2)
		{
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
			{
				dummy[i][j]=0.;
				for(int k=0;k<chiSQ;k++)
					dummy[i][j]+=B_tot[i][k]*Bp12[k][j];
			}
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
				B_tot[i][j]=dummy[i][j];
		}
		for(int i=0;i<chiSQ;i++)
			norm+=B_tot[i][i];
		//for(int i=0;i<chiSQ;i++)
		//	norm+=pow(S_Bp12[i],def_L*0.5);
	}
	///////////////////////////////////
	/////// <psi|O(0)O(r-1)|psi> //////
	else if(rank==2)
	{
		if(r%2==1)
		{
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
				B_tot[i][j]=Bp1[i][j];
			for(int z=0;z<(int)((r-1)*0.5);z++)
			{
				for(int i=0;i<chiSQ;i++)
				for(int j=0;j<chiSQ;j++)
				{
					dummy[i][j]=0.;
					for(int k=0;k<chiSQ;k++)
						dummy[i][j]+=B_tot[i][k]*B21[k][j];
				}
				for(int i=0;i<chiSQ;i++)
				for(int j=0;j<chiSQ;j++)
					B_tot[i][j]=dummy[i][j];
			}
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
			{
				dummy[i][j]=0.;
				for(int k=0;k<chiSQ;k++)
					dummy[i][j]+=B_tot[i][k]*Bp2[k][j];
			}
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
				B_tot[i][j]=dummy[i][j];
			for(int z=0;z<(int)((def_L-r-1)*0.5);z++)
			{
				for(int i=0;i<chiSQ;i++)
				for(int j=0;j<chiSQ;j++)
				{
					dummy[i][j]=0.;
					for(int k=0;k<chiSQ;k++)
						dummy[i][j]+=B_tot[i][k]*B12[k][j];
				}
				for(int i=0;i<chiSQ;i++)
				for(int j=0;j<chiSQ;j++)
					B_tot[i][j]=dummy[i][j];
			}
		}
		else
		{
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
			{
				dummy[i][j]=0.;
				for(int k=0;k<chiSQ;k++)
					dummy[i][j]+=B2[i][k]*Bp1[k][j];
			}
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
				B_tot[i][j]=dummy[i][j];
			for(int z=0;z<(int)((r-2)*0.5);z++)
			{
				for(int i=0;i<chiSQ;i++)
				for(int j=0;j<chiSQ;j++)
				{
					dummy[i][j]=0.;
					for(int k=0;k<chiSQ;k++)
						dummy[i][j]+=B_tot[i][k]*B21[k][j];
				}
				for(int i=0;i<chiSQ;i++)
				for(int j=0;j<chiSQ;j++)
					B_tot[i][j]=dummy[i][j];
			}
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
			{
				dummy[i][j]=0.;
				for(int k=0;k<chiSQ;k++)
					dummy[i][j]+=B_tot[i][k]*B2[k][j];
			}
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
				B_tot[i][j]=dummy[i][j];
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
			{
				dummy[i][j]=0.;
				for(int k=0;k<chiSQ;k++)
					dummy[i][j]+=B_tot[i][k]*Bp1[k][j];
			}
			for(int i=0;i<chiSQ;i++)
			for(int j=0;j<chiSQ;j++)
				B_tot[i][j]=dummy[i][j];
			for(int z=0;z<(int)((def_L-r-2)*0.5);z++)
			{
				for(int i=0;i<chiSQ;i++)
				for(int j=0;j<chiSQ;j++)
				{
					dummy[i][j]=0.;
					for(int k=0;k<chiSQ;k++)
						dummy[i][j]+=B_tot[i][k]*B21[k][j];
				}
				for(int i=0;i<chiSQ;i++)
				for(int j=0;j<chiSQ;j++)
					B_tot[i][j]=dummy[i][j];
			}
		}
		for(int i=0;i<chiSQ;i++)
			norm+=B_tot[i][i];
	}
	///////////////////////////////////
	for(int k=0;k<chiSQ;k++)
	{
		delete [] Bp1[k];
		delete [] Bp2[k];
		delete [] B1[k];
		delete [] B2[k];
		delete [] B12[k];
		delete [] B21[k];
		delete [] Bp12[k];
		delete [] B_tot[k];
		delete [] dummy[k];
	}
	delete [] Bp1;
	delete [] Bp2;
	delete [] B1;
	delete [] B2;
	delete [] B12;
	delete [] B21;
	delete [] Bp12;
	delete [] svd_A; delete [] svd_U; delete [] svd_Vt;
	delete [] B_tot; delete [] dummy;
	delete [] S_B1; delete [] S_B2;
	delete [] S_Bp1; delete [] S_Bp2;
	delete [] S_B12; delete [] S_B21; delete [] S_Bp12;
	return norm;
}
int check_matrix_symmetry(char *word, double **matrix, int M)
{
	double error;
	for(int i=0;i<M;i++)
	for(int j=i+1;j<M;j++)
	{
		error=ABS(matrix[i][j]-matrix[j][i]);
		if(error>1e-10)
		{
			printf(" %s isn't symmetric came out at (%d,%d)-th, and the error is %.8e\n",word,i+1,j+1,error);
			return 0;
		}
	}
	printf(" %s is a symmetric matrix\n",word);
	return 1;		
}
void backup_main()
{
	set_tensors();
	set_operators();
	for(g=g_initial;g<g_final;g+=g_gap)
	{
		set_table();
		initializing_tensors();
		TEBD(Gamma,lambda);
		count_converge=1; count_nonconverge=0;
		while(true)
		{
			if(ABS(ERROR(backup_s[1][0],backup_s[0][0]))<1.e-10)
			//if(count_converge>4e4)
			{
				if(ABS(ERROR(ABS(Gamma[0][0][0][0]),ABS(Gamma[1][0][0][0])))<1e-10)
				{
					for(int i=0;i<1e4;i++)
					{
						TEBD(Gamma,lambda);
						count_converge++;
					}
					break;
				}
				initializing_tensors();
				count_converge=0;
				count_nonconverge++;
			}
			if(count_converge>1e5)
			{
				if(count_nonconverge>1e1)
					break;
				initializing_tensors();
				count_converge=0;
				count_nonconverge++;
			}
			TEBD(Gamma,lambda);
			count_converge++;
		}
		double energy_TNS=TNS_ENERGY(backup_s[0][0],epsilon);
		double energy_exact=exact_energy(1024);
		unset_table();
	}
	unset_operators();
	unset_tensors();
}
