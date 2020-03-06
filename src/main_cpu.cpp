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
	int size = data.begin()->second.size();
	int counter_cpu = 0;
	float originS = 0;
	originS = t->calcS(cols);
	//cout<<"Original S: "<< originS << endl << "====================================="<<endl;


	float s_cpu;
	for(int num = 0; num < t->iterTime_; num ++){
		unordered_map<string, vector<float>> newOrder = t->reorderData(cols);
		s_cpu = t->calcS(newOrder);
		if(s_cpu >= originS) counter_cpu++;
		//cout<<"S_CPU: "<<s_cpu<<endl<<"====================================="<<endl;
	}
	
	float p_cpu = counter_cpu / t->iterTime_;
	cout<<"There are "<<counter_cpu<<" S greater than the original S."<<endl;
	cout<<"P_CPU: "<<p_cpu<<endl;
	duration = ( std::clock() - start ) / (double) CLOCKS_PER_SEC;
	std::cout<< duration <<'\n';

}
