#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>

extern unsigned long VERBOSE;
extern unsigned long INITFILE;
extern unsigned long INITFILEPATH;

/*
 * Code to handle initialisation with running files
 */

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
	while ((opt = getopt(argc, (char**)argPtrs, "i:vhu")) != -1)
	{
		switch(opt)
		{
		case 'i':
			INITFILE = 1;
			strcpy((char *)&INITFILEPATH, optarg);
			break;
		case 'v':
			VERBOSE = 1;
			break;
		case 'h':
		case 'u':
			printf("\n\n===Riscyforth is a FORTH implementation for RISC-V systems running Linux.===\n");
			printf("============================================================================\n");
			printf("Usage:\n");
			printf("riscyforth [options]\n");
			printf("-h -u: print this usage message and exit.\n");
			printf("-v: verbose output.\n");
			printf("-i [filepath]: specify a FORTH file to be run on Riscyforth start-up.\n");
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

