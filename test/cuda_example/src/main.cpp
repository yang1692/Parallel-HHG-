#include "main.h"
#include "gtest/gtest.h"
#include <iostream>

using software_design::run;

int main(int argc, char* argv[])
{
  testing::InitGoogleTest(&argc, argv);

  int N = 1<<20;
  std::cout << "Max error: " << run(N) << std::endl; 

  return RUN_ALL_TESTS();
}


