all:
	nvc++ --std=c++17 -I./include  kernel.cu -o ./build/main -lcurand
