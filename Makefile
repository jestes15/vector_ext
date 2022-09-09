all:
	nvcc -arch=sm_72 --std=c++17 -I./include  kernel.cu -o ./build/main -lcurand