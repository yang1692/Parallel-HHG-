#include "./../src/main.h"
#include "gtest/gtest.h"
#include <chrono>
#include <iostream>

using software_design::run;


TEST(main, non_positive){
	int numofRow = 10;
	int numfoCol = 2;
	
   ASSERT_EQ(main(numofCol, numofRow), -1);
}







































