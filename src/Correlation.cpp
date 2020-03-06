#include"main.h"
using hhg::Correlation;
Correlation::Correlation(string colname1, string colname2){
	this->column_1_name_ = colname1;
	this->column_2_name_ = colname2;
	this->p_ = -1;
	this->statistics_ = -1;
}
