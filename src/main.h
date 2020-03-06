/*
 * main.h
 *
 *  Created on: Feb 7, 2020
 *      Author: YK
 */
#include<unordered_map>
#include<string>
#include <vector>
#include<random>
using std::default_random_engine;
using std::uniform_real_distribution;
using std::random_device;
using std::string;
using std::unordered_map;
#ifndef SRC_MAIN_H_
#define SRC_MAIN_H_
using std::vector;
namespace hhg{
	void cuda_calcS(float * col1, float * col2, float * results,int size);
	class Dataset{
	public:
		int nrow_;
		int ncol_;
		unordered_map<string, vector<float>> num_col_;
	};
	class Correlation{
	public:
		Correlation(string colname1, string colname2);
		string column_1_name_;
		string column_2_name_;
		float statistics_;
		float p_;
	};
	class Tool{
	private:
		static Tool *t;
		Tool();
		random_device rd;
		default_random_engine e{rd()};
		uniform_real_distribution<float> u;
		~Tool();
		void setRange(float range);
	public:
		static float iterTime_;
		float generateAFloat();
		static Tool* getInstance();
		unordered_map<string, vector<float>> randomlyPickColumns(unordered_map<string, vector<float>> &data,int n);
		float calcS( unordered_map<string, vector<float>> &data);
		unordered_map<string, vector<float>> reorderData(unordered_map<string, vector<float>> &data);
		unordered_map<string, vector<float>> dataGenerate(int size, int col, float range);
	};

}




#endif /* SRC_MAIN_H_ */
