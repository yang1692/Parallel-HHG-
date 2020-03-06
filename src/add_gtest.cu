#include <math.h>
#include "main.h"
#include <iostream>

__global__
void add(int n, float *x, float *y)
{
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;
  for (int i = index; i < n; i += stride)
    y[i] = x[i] + y[i];
}

int software_design::run(int N){
  std::cout << "N is " << N << std::endl;
  if (N<=0) return -1;
  float *x, *y;

  // Allocate Unified Memory – accessible from CPU or GPU
  cudaMallocManaged(&x, N*sizeof(float));
  cudaMallocManaged(&y, N*sizeof(float));

  // initialize x and y arrays on the host
  for (int i = 0; i < N; i++) {
    x[i] = 1.0f;
    y[i] = 2.0f;
  }

  // Run kernel on 1M elements on the GPU
  int blockSize = 256;
  int numBlocks = (N + blockSize - 1) / blockSize; 

  int device = -1;

  cudaGetDevice(&device);

  cudaMemPrefetchAsync(x, N*sizeof(float), device, NULL);

  cudaMemPrefetchAsync(y, N*sizeof(float), device, NULL);

  add<<<numBlocks, blockSize>>>(N, x, y);

  // Wait for GPU to finish before accessing on host
  cudaDeviceSynchronize();

  // Check for errors (all values should be 3.0f)
  float maxError = 0.0f;
  for (int i = 0; i < N; i++)
    maxError = fmax(maxError, fabs(y[i]-3.0f));


  // Free memory
  cudaFree(x);
  cudaFree(y);

  return(maxError);
}
