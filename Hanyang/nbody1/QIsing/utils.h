#ifndef _UTILS_H_
#define _UTILS_H_

#include <cmath>
#include <cstdio>
#include <iostream>
#include "/Users/park/project/CLAPACK-3.2.1/INCLUDE/blaswrap.h"
#include "/Users/park/project/CLAPACK-3.2.1/INCLUDE/f2c.h"
#include "/Users/park/project/CLAPACK-3.2.1/INCLUDE/clapack.h"

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#ifndef CONST_pi
#define CONST_pi 3.141592653590
#endif
#ifndef CONST_e
#define CONST_e 2.718281828459
#endif
#ifndef Tolerance
#define Tolerance 1.e-10
#endif
#ifndef ABS
#define ABS(x) (((x) < 0) ? -(x) : (x))
#endif
#ifndef MAX
#define MAX(x,y) (((x) > (y)) ? (x) : (y))
#endif
#ifndef MIN
#define MIN(x,y) (((x) < (y)) ? (x) : (y))
#endif
#ifndef MAX3
#define MAX3(x,y,z) (((x) > MAX(y,z)) ? (x) : MAX(y,z))
#endif
#ifndef MIN3
#define MIN3(x,y,z) (((x) < MIN(y,z)) ? (x) : MIN(y,z))
#endif
#ifndef SQR
#define SQR(a) ((a) == 0.0 ? 0.0 : a*a)
#endif
#ifndef SIGN
#define SIGN(a,b) ((b) >= 0.0 ? fabs(a) : -fabs(a))
#endif

void SUBLOUTINE_DGESVD(double *A, double *U, double *S, double *Vt, int M, int N);
double pythag(double a, double b);
void reorder(double **u, double *w, double **v, int m, int n);
void print_carray( char* desc, int m, int n, doublecomplex *a);
void print_array( char* desc, int m, int n, double *a);
void print_cmatrix( char* desc, int m, int n, doublecomplex **a);
void print_matrix( char* desc, int m, int n, double **a);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif  /* _UTILS_H_ */
