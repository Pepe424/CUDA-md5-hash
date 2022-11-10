#include "cuda_md5.h"
#include <cuda_runtime.h>
#include <stdio.h>
#include <math.h>

#define THREADS 512

__global__ void kernel_mult(int grid, unsigned long long block_length, int gpu, int len)
{
	uint8_t result[16];
	password pwd;

	pwd.length = len;
	unsigned long long iter = (BLOCK_SIZE * blockIdx.x + threadIdx.x) + (grid * block_length) + ((block_length/4) * gpu); //1. číslo iterace| 2. posun o grid| 3. posun o čtvrtinu(rozdělení mezi 4 gpu)
	for (size_t i = 0; i < len; i++)
	{
		pwd.word[i] = iter % 26 + 97;
		iter = iter / 26;
	}
	cuda_md5(&pwd, result);
}

void run_mult(int l)
{
	unsigned long long total = pow(26, l);
	unsigned long blocks = (total + THREADS - 1) / THREADS;
	printf("String length [%d] Threads [%d]\n", l, THREADS);
	printf("%lu - Original calculated Blocks\n", blocks);

	int divide = (blocks + (pow(2, 31) - 1) - 1) / (pow(2, 31) - 1);
	blocks = (blocks + divide - 1) / divide;

	printf("%.0f <– Blocks limitation\n", (pow(2, 31) - 1));
	printf("%lu <- Blocks after correction\n", blocks);
	printf("%d <- Divisor\n", divide);
	printf("%lu <- Multiply check\n", divide * blocks);
	printf("%llu <- Total operations\n%lu <- Blocks per grid(s)\n", total, blocks);

	for (size_t i = 0; i < divide; i++)
	{
		for (size_t j = 0; j < 4; j++)
		{
			cudaSetDevice(j);
			kernel_mult<<<blocks/4, THREADS>>>(i, blocks, j, l);
		}
		cudaDeviceSynchronize();
	}
}