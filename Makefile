all:
	@nvcc --std=c++17 -I./include  ./src/kernel.cu -o ./build/main -lcurand

main:
	@nvcc --std=c++17 -I./include  ./src/main.cu -o ./build/test -lcurand

run:
	@./build/main

run_test:
	@./build/test

clean:
	@rm -rf ./build/*