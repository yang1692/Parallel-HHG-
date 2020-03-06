#include"main.h"
#include<iostream>
#include<cmath>
#include<unordered_map>
#include<vector>
#include<cstdio>
#include <stdio.h>
#include <string.h>
#include <ctime>
#include <curand_kernel.h>
using std::unordered_map;
using std::vector;
using hhg::Tool;
using std::string;
using std::cout;
using std::endl;
using std::ends;
__global__
void cuda_calcS(float * col1, float * col2, int * results,int size,float originS){
	int index = blockIdx.x * blockDim.x + threadIdx.x;
	int stride = blockDim.x * gridDim.x;
	float *newOrder;
	newOrder = (float*) malloc (size*sizeof(float));
	float table[4] = {0,0,0,0};
	//random number generator initialize
	curandState state;
	unsigned int seed = index;
	curand_init(seed, 0, 0, &state);	
	for(int iterationTime = index; iterationTime <1000; iterationTime+=stride){
		for(int i = 0; i < size; i++){
			newOrder[i] = col2[i];
		}
		float tmp; 
                int randomIndex;
		for(int i = size-1; i > 0; i--){
			randomIndex = curand(&state)%(i+1);
			tmp = newOrder[randomIndex];
			newOrder[randomIndex] = newOrder[i];
			newOrder[i] = tmp;
		}
		float s = 0;
		for (int index1 = 0; index1 < size; index1 ++){
			for(int index2 = index1 + 1 ; index2 < size; index2++){
				float rx = abs(col1[index1] - col1[index2]);
				float ry = abs(newOrder[index1] - newOrder[index2]);
				table[0] = 0;table[1] = 0;table[2] = 0;table[3] = 0;
				for(int index3 = 0; index3 < size; index3++){
					if(index3 != index1 && index3 != index2){
						float dy = abs(newOrder[index1] - newOrder[index3]);
						float dx = abs(col1[index1] - col1[index3]);
						if(dx <= rx){
							if(dy <= ry) table[0]++;
							else table[2]++;
						}
						else{
							if(dy <= ry) table[1]++;
							else table[3]++;
						}
					}
				}
				float a12 = table[1], a21 = table[2], a11 = table[0], a22 = table[3];
				float a1_ = a11 + a12, a2_ = a21 + a22, a_1 = a11 + a21, a_2 = a22 + a12;
				if( a1_==0 || a2_==0 || a_1==0 || a_2==0 ){
					continue;			
				}
				s += (size-2.0)*pow(a12*a21 - a11*a22 , 2) / (a_1*a_2*a1_*a2_);
			}
		}
		if(s >= originS) results[index] ++;
	}
	delete[] table;
	delete[] newOrder;
}
int main(int argc,char *argv[]){
	Tool *t = t->getInstance();
	std::clock_t start;
	if(argc != 2){
		cout<<"Invalid number of Parameters"<<endl;
		return 0;
	}
	int numofRow = atoi(argv[1]);
	double duration;
	unordered_map<string, vector<float>> data = t->dataGenerate(numofRow, 5, 1.0);
	start = std::clock();
	unordered_map<string, vector<float>> cols = t->randomlyPickColumns(data, 2);
	int size = numofRow;
	int blockSize = 256;
	int numBlocks = (1000 + blockSize - 1) / blockSize;
	float *col1, *col2;
	int *results;
	cudaMallocManaged(&col1, size*sizeof(float));
	cudaMallocManaged(&col2, size*sizeof(float));
	cudaMallocManaged(&results, numBlocks*blockSize*sizeof(int));
	cudaMemset(results, 0, numBlocks*blockSize*sizeof(int));
	int counter = 0;
	float originS = 0;
	originS = t->calcS(cols);
	//cout<<"Original S: "<< originS << endl << "====================================="<<endl;
	for(int i = 0 ; i < size ; i++){
		auto iter = data.begin();
		col1[i] = iter->second[i];
		iter++;
		col2[i] = iter->second[i];
	}
	int device = -1;
	cudaGetDevice(&device);
	cudaMemPrefetchAsync(col1, size*sizeof(float), device, NULL);
	cudaMemPrefetchAsync(col2, size*sizeof(float), device, NULL);
	cudaMemPrefetchAsync(results, numBlocks*blockSize*sizeof(int), device, NULL);
	cudaMemPrefetchAsync(&size, sizeof(int), device, NULL);
	cuda_calcS<<<numBlocks, blockSize>>>(col1, col2, results, size, originS);
	cudaDeviceSynchronize();
	for(int i = 0 ; i < numBlocks*blockSize; i++){
		counter+= results[i];
	}

	float p = counter / t->iterTime_;
	cout<<"There are "<<counter<<" S greater than the original S."<<endl;
	cout<<"P = "<<p<<endl;
	duration = ( std::clock() - start ) / (double) CLOCKS_PER_SEC;
	std::cout<< "duration: "<<duration <<"seconds\n";
	cudaFree(col1);
	cudaFree(col2);
	cudaFree(results);
}
