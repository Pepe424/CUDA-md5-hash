#include "cuda_md5.h"
#include <cuda_runtime.h>
#include <stdio.h>
#include <math.h>

#define THREADS 512
#define GPU 4

__global__ void kernel_mult(int grid, unsigned long long block_length, int gpu, int len)
{
	uint8_t result[16];
	char msg[12] = {0};
	
	unsigned long long iter = (THREADS * blockIdx.x + threadIdx.x) + (grid * block_length) + (((block_length + gpu - 1)/ 4) * gpu); // 1. číslo iterace| 2. posun o grid| 3. posun o čtvrtinu(rozdělení mezi 4 gpu)

	for (size_t i = 0; i < len; i++)
	{
		msg[i] = iter % 26 + 97;
		iter = iter / 26;
	}

	cuda_md5((uint8_t *)msg, len, result);
}

void run_mult(int l)
{
	unsigned long long total = pow(26, l);
	unsigned long blocks = (total + THREADS - 1) / THREADS;
	unsigned long _blocks = blocks;
	printf("String length [%d] - Threads [%d] - Blocks limitations [%.0f]\n", l, THREADS, (pow(2, 31) - 1));
	printf("%lu <- Teoretical Blocks\n", blocks);

	int divide = (blocks + (pow(2, 31) - 1) - 1) / (pow(2, 31) - 1);
	blocks = (blocks + divide - 1) / divide;

	printf("%lu <- Actual Blocks\n", blocks * divide);
	printf("%lu <- Waster Blocks\n", blocks * divide - _blocks);
	printf("%llu <- Teoretical Operations\n", total);
	printf("%lu <- Actual Operations\n", blocks * THREADS * divide);
	printf("%llu <- Waste Operatins\n", blocks * THREADS * divide - total);
	printf("%d <- Divisor\n", divide);

	for (size_t i = 0; i < divide; i++)
	{
		for (size_t j = 0; j < GPU; j++)
		{
			cudaSetDevice(j);
			kernel_mult<<<(blocks + GPU - 1)/GPU, THREADS>>>(i, blocks, j, l);
		}
		cudaDeviceSynchronize();
	}
}