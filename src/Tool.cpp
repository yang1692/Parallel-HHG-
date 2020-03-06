#include"main.h"
#include <stdlib.h>     /* srand, rand */
#include <time.h>       /* time */
#include <algorithm>
#include <cmath>
#include <iostream>
#include <fstream>
using hhg::Tool;
using std::cout;
using std::endl;
using std::srand;
using std::find;
using std::ends;
using std::ofstream;
Tool * Tool::t = 0;
float Tool::iterTime_ = 1000;
float Tool::generateAFloat(){
	return this->u(e);
}
void Tool::setRange(float range){
	uniform_real_distribution<float> newu(0.0, range);
	this->u = newu;
}
unordered_map<string, vector<float>> Tool::randomlyPickColumns(unordered_map<string, vector<float>> &data, int n){
	 vector<string> col_name;
	 unordered_map<string, vector<float>> result;
	 int size = 0;
	 vector<int> picked_num;
	 for ( auto it = data.begin(); it != data.end(); it++ ){
		 col_name.push_back(it->first);
		 size++;
	 }



	 if(n >= size) return data;
	 /* initialize random seed: */
	  srand (time(NULL));

	  /* generate secret number between 1 and 10: */
	  while(n){
		  int index = rand() % size;
		  if(find(picked_num.begin(), picked_num.end(), index) == picked_num.end()){
			  picked_num.push_back(index);
			  n--;
		  }

	  }
	  for(auto it = picked_num.begin(); it != picked_num.end(); it++){
		  ofstream myfile;
		  myfile.open ("data_"+col_name[*it]+".txt");
		  for(auto it2 = data.begin(); it2 != data.end(); it2++){
			  if(it2->first == col_name[*it]){
				  int datasize = it2->second.size();
				  for(int i = 0; i < datasize; i++)
					  myfile<<it2->second[i]<<',';
				  result.emplace (it2->first, it2->second);
			  }
		  }
		  myfile.close();
	  }
	  return result;
}

float Tool::calcS( unordered_map<string, vector<float>> &data){
	int size = data.begin()->second.size();
	float result = 0;
	for(int index1 = 0; index1 < size; index1++){
		for(int index2 = index1 + 1 ; index2 < size; index2++){
			auto it = data.begin();
			float rx = abs(it->second[index1] - it->second[index2]);
			it++;
			float ry = abs(it->second[index1] - it->second[index2]);

			//row first
			vector<float> table = {0,0,0,0};

			for(int index3 = 0; index3 < size; index3++){
				it = data.begin();
				if(index3 != index1 && index3 != index2){
					float dx = abs(it->second[index1] - it->second[index3]);
					it++;
					float dy = abs(it->second[index1] - it->second[index3]);
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
			if( !a1_ || !a2_ || !a_1 || !a_2 )
				continue;
			//cout<<size<<endl;
			result += (size-2.0)*pow(a12*a21 - a11*a22 , 2) / (a_1*a_2*a1_*a2_);
		}
	}

	//cout<<table[0]<<std::ends<<table[1]<<endl<<table[2]<<std::ends<<table[3]<<endl;

	// a_1 means first row
	return result;
}
unordered_map<string, vector<float>> Tool::reorderData(unordered_map<string, vector<float>> &data){
	unordered_map<string, vector<float>> result = data;
	auto it = result.begin();
	it++;
	std::random_shuffle ( it->second.begin(), it->second.end() );
	/*for ( auto it = result.begin(); it != result.end(); it++ )
		{
			cout<<it->first<<std::ends;
			int size = it->second.size();
			for(int i = 0; i < size; i++)
				cout<<it->second[i]<<std::ends;
			cout<<endl;
		}
*/
	return result;
}
unordered_map<string, vector<float>> Tool::dataGenerate(int size, int col, float range){
	string col_name = "a";

	unordered_map<string, vector<float>> result;
	this->setRange(range);
	for(int i = 0 ; i < col; i++){
		vector<float> data;
		for (int i=0;i<size;i++){
			float tmp = this->generateAFloat();
			data.push_back(tmp);
		}
		result.emplace(col_name, data);
		col_name += "a";
	}
	return result;
}
Tool::Tool(){};

Tool* Tool::getInstance(){
	if(!t) t = new Tool();
	return t;
}
