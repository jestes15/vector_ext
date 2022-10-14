all:
	nvc++ --std=c++17 -I./include  kernel.cu -o ./build/main -lcurand

main:
	nvc++ --std=c++17 -I./include  main.cu -o ./build/test -lcurand

run:
	./build/main

run_test:
	./build/test

clean:
	rm -rf ./build/*