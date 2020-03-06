#include "./../src/main.h"
#include "gtest/gtest.h"
#include <chrono>
#include <iostream>

using software_design::run;


TEST(run, base_case){
  int N = 1<<20;
  ASSERT_EQ(run(N), 0);
}

TEST(run, non_positive){
   int N = 0;
   ASSERT_EQ(run(N), -1);
}
/*
TEST(run, big_input){
   int N = 1e9;
   ASSERT_EQ(run(N), 0);
}*/

TEST(run, performance){
   int N = 1<<20;
   auto start_time = std::chrono::high_resolution_clock::now();
   run(N);
   auto end_time = std::chrono::high_resolution_clock::now();
   auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time).count();
   std::cout << "Duration: " << duration << " milliseconds." << std::endl;
   ASSERT_LT(duration, 1000);
   
}

