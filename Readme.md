This is the application of HHG algoritim written by Kui Yang.
There are three versions of HHG.
(1) CPU version
Related file: main_cpu.cu
The CPU version of HHG doesn't use muti-thread technology. 
To compile it:
nvcc src/main_cpu.cpp src/Tool.cpp src/Correlation.cpp --std=c++11 -Iinclude/ -Llib/gtest -lgtest -lgtest_main -lpthread -o bin/hhg_cpu

(2)GPU low-level version
Related file: main_low_level.cu
The GPU low-level version applies parallelism on low level, which is the three nested for loop. Every thread will get an I value based on its thread id. And it will get into a loop starting from I=index, J = I+1.
The problem of this version is that every thread will get different amount of job. Thus, the optimization is limited.
To compile it:
nvcc src/main_low_level.cpp src/Tool.cpp src/Correlation.cpp --std=c++11 -Iinclude/ -Llib/gtest -lgtest -lgtest_main -lpthread -o bin/hhg_low_level

(3)GPU mid-level version
Related file: main_cpu.cu
GPU mid-level version applies parallelism on mid level, which is to generate a new permutation and get into the three nested for loop. It will optimize the algorithm to an acceptable speed. But when the size of data grows, it still can't be very fast.

To compile it:
nvcc src/main_mid_level.cpp src/Tool.cpp src/Correlation.cpp --std=c++11 -Iinclude/ -Llib/gtest -lgtest -lgtest_main -lpthread -o bin/hhg_mid_level


And the main.cu is to test if the result of GPU version is the same as that of cpu version.