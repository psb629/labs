int nz_findroot(int *ptr, int i);	//ptr[N]: Array of pointers
void nz_boudnaries(int **nn, int L, int N);	//nn[N][4], L: Linear dimension, N: Number of sites(=L*L)
void nz_permutation(int *order, int N);	//order[N]: Occupation order
void nz_percolate(int **nn, int *order, int *ptr, int N, double p);
