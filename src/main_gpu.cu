#include"main.h"
#include<iostream>
#include<cmath>
#include<unordered_map>
#include<vector>
#include<cstdio>
#include <stdio.h>
#include <string.h>
#include <ctime>
using std::unordered_map;
using std::vector;
using hhg::Tool;
using std::string;
using std::cout;
using std::endl;
using std::ends;
__global__
void cuda_calcS(float * col1, float * col2, float * results,int size){
	int index = blockIdx.x * blockDim.x + threadIdx.x;
	int stride = blockDim.x * gridDim.x;
	for (int index1 = index; index1 < size; index1 += stride){
		for(int index2 = index1 + 1 ; index2 < size; index2++){
			float rx = abs(col1[index1] - col1[index2]);
			float ry = abs(col2[index1] - col2[index2]);
			float table[4] = {0,0,0,0};
			for(int index3 = 0; index3 < size; index3++){
				if(index3 != index1 && index3 != index2){
					float dy = abs(col2[index1] - col2[index3]);
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
			//cout<<a11<<ends<<a12<<endl<<a21<<ends<<a22<<endl;
			if( a1_==0 || a2_==0 || a_1==0 || a_2==0 ){
				//results[index]--;
				continue;			
			}
			//cout<<size<<endl;
			/*if(index == 1)
				printf("Hello from block %d, thread %d, The table is %lf %lf %lf %lf\n", blockIdx.x, threadIdx.x, a11,a12,a21,a22);*/
			results[index] += (size-2.0)*pow(a12*a21 - a11*a22 , 2) / (a_1*a_2*a1_*a2_);
			delete[] table;
		}
	}
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
	unordered_map<string, vector<float>> data = t->dataGenerate(numofRow, 5, 1.0);//{{"Australia",{0,1,2,2,3,6,7}},{"U.S.",{5,3,2,6,2,3,4}}};//,{"France",{99,1,2,6,9,2,4}}};
	start = std::clock();
	unordered_map<string, vector<float>> cols = t->randomlyPickColumns(data, 2);
	int size = numofRow;
	int blockSize = 256;
	int numBlocks = (size + blockSize - 1) / blockSize;
	float *col1, *col2, *results;
	cudaMallocManaged(&col1, size*sizeof(float));
	cudaMallocManaged(&col2, size*sizeof(float));
	cudaMallocManaged(&results, numBlocks*blockSize*sizeof(float));
	int counter = 0;
	float originS = 0;
	originS = t->calcS(cols);
	//cout<<"Original S: "<< originS << endl << "====================================="<<endl;

	float s;
	for(int num = 0; num < t->iterTime_; num ++){
		s = 0;
		unordered_map<string, vector<float>> newOrder = t->reorderData(cols);
		for(int i = 0 ; i < size ; i++){
			auto iter = newOrder.begin();
			col1[i] = iter->second[i];
			iter++;
			col2[i] = iter->second[i];
		}
		cudaMemset(results, 0, numBlocks*blockSize*sizeof(float));
		int device = -1;
		cudaGetDevice(&device);
		cudaMemPrefetchAsync(col1, size*sizeof(float), device, NULL);
		cudaMemPrefetchAsync(col2, size*sizeof(float), device, NULL);
		cudaMemPrefetchAsync(results, numBlocks*blockSize*sizeof(float), device, NULL);
		cudaMemPrefetchAsync(&size, sizeof(int), device, NULL);
		cuda_calcS<<<numBlocks, blockSize>>>(col1, col2, results,size);
		cudaDeviceSynchronize();
		for(int i = 0 ; i < numBlocks*blockSize; i++){
			s+= results[i];
		}
		if(s >= originS) counter++;
		//cout<<"S: "<<s<<endl<<"====================================="<<endl;
	}
	
	float p = counter / t->iterTime_;
	cout<<"There are "<<counter<<" S greater than the original S."<<endl;
	cout<<"P = "<<p<<endl;
	duration = ( std::clock() - start ) / (double) CLOCKS_PER_SEC;
	std::cout<< duration <<'\n';
	cudaFree(col1);
	cudaFree(col2);
	cudaFree(results);
}
