CC:=/usr/local/cuda-11.2/bin/nvcc
#OPT:=-arch=sm_21

main: cuda_md5.o main.o
	${CC} ${OPT} $^ -o $@
#	export LD_LIBRARY_PATH=/home/edu/cuda2/lib

cuda2.o: cuda_md5.cu
	${CC} ${OPT} -c $^  -o $@

main2.o: main.cpp
	${CC} ${OPT} -c $^  -o $@

clean:
	rm *.o main
