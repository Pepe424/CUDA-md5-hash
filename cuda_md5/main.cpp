// make && time ./main 9
// watch -d -n 0.5 nvidia-smi

#include <stdio.h>
#include <math.h>

void run_mult(int l);

int main(int argc, char *argv[])
{
	int l = atoi(argv[1]);
	run_mult(l);
	return 0;
}
