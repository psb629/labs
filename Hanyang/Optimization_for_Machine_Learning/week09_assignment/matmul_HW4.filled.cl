// HW_4
__kernel void matmul_HW4( 
		const int M,
		const int N,
		const int K,
		const __global float *A, 
		const __global float *B, 
		__global float *C)
{
	int tidx = get_global_id(0); // i
	int tidy = get_global_id(1); // j

	if (tidx < M && tidy < N)
	{
		float Csub = 0.0f;

		for(int k = 0; k < K; k += 8) // k
		{
			if (k < K)
			{
				Csub += A[tidx*K+k] * B[k*N+tidy];
				Csub += A[tidx*K+(k+1)] * B[(k+1)*N+tidy];
				Csub += A[tidx*K+(k+2)] * B[(k+2)*N+tidy];
				Csub += A[tidx*K+(k+3)] * B[(k+3)*N+tidy];
				Csub += A[tidx*K+(k+4)] * B[(k+4)*N+tidy];
				Csub += A[tidx*K+(k+5)] * B[(k+5)*N+tidy];
				Csub += A[tidx*K+(k+6)] * B[(k+6)*N+tidy];
				Csub += A[tidx*K+(k+7)] * B[(k+7)*N+tidy];

			}
		}

		C[tidx * N + tidy] = Csub;
	}
}

