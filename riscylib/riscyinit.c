#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>

/*
 * Code to handle initialisation with running files
 */

const int MAX_OPT = 16;

void initriscyforth(int argc, char *arg0)
{
	int opt;
	int counter = 0;
	opterr = 0;
	
	// malloc space for an array of pointers
	uint64_t* argPtrs = malloc(sizeof(uint64_t) * argc);;

	for (int i = 0; i < argc; i++)
	{
		argPtrs[i] = (uint64_t)(arg0 + counter);
		while ((char)*(arg0 + counter) != '\0') {
			counter++;
		}
		counter++;
	}
	// process options
	while ((opt = getopt(argc, (char**)argPtrs, "i:sh")) != -1)
	{
		switch(opt)
		{
		case 'i':
			//include a file
			printf("Including file: %s\n", optarg);
			break;
		case 's':
			//suppress messages
			printf("Suppress initial messages\n");
			break;
		case 'h':
		case 'u':
			printf("\n\n===Riscyforth is a FORTH implementation for RISC-V systems running Linux.===\n");
			printf("============================================================================\n");
			printf("Usage:\n");
			printf("riscyforth [options]\n");
			printf("-h -u: print this usage message and exit.\n");
			printf("-s: suppress initial output messages.\n");
			printf("-i [filepath]: load and execute the FORTH file on filepath.\n");
			printf("\nRiscyforth is licenced for use and distribution under the terms of version 2 of the GNU General Public License ");
			printf("or any later version at your discretion.\nNo warranty is offered. Copyright Adrian McMenamin, 2020 - 2023.\n");
			free(argPtrs);
			exit(1);
		default:
			break;	
		}
	}
	free(argPtrs);
}

