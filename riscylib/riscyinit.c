#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>

extern unsigned long CMDLINE;
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
    int argsLeft = argc - 1;
    char* targetAddr = 0u;
    opterr = 0;
	// malloc space for an array of pointers
	uint64_t* argPtrs = malloc(sizeof(uint64_t) * argc);
	INITFILE = 0u;
    CMDLINE = 0u;

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
			// allow for up to 4 paths
			strcpy((char *)((char*)&INITFILEPATH + (INITFILE * 128u)), optarg);
			INITFILE++;
            argsLeft -= 2;
            CMDLINE = 1u;
			break;
		case 'v':
			VERBOSE = 1;
            argsLeft -= 1;
			break;
		case 'h':
		case 'u':
			printf("\n\n===Riscyforth is a FORTH implementation for RISC-V systems running Linux.===\n");
			printf("============================================================================\n");
			printf("Usage:\n");
			printf("riscyforth [options] [words]\n");
			printf("-u                  print this usage message and exit.\n");
            printf("-h                  print usage message and exit.\n");
			printf("-v                  verbose output.\n");
			printf("-i [filepath]       specify a FORTH file to be loaded on Riscyforth start-up. Paths may be up to 127 characters long.\n");
            printf("The total length of the options and words should not exceed 1024 bytes. Each path will be assumed to be 128 bytes long.\n");
			printf("\nRiscyforth is licenced for use and distribution under the terms of version 2 of the GNU General Public License ");
			printf("or any later version at your discretion.\nAs per the terms of the licence, no warranties are offered.\nCopyright Adrian McMenamin, 2020 - 2024.\n");
			free(argPtrs);
			exit(1);
		default:
			break;	
		}
	}
    if (argsLeft >= 1) {
        CMDLINE = 2u;
        targetAddr = (char *)((char*)&INITFILEPATH + (INITFILE * 128u));
        for (int i = 0; i < argsLeft; i++)
        {
            char* srcAddr = (char *)(argPtrs[argc + i - argsLeft]);
            while ((char)*srcAddr != '\0') {
                *targetAddr = *srcAddr;
                targetAddr++;
                srcAddr++;
            }
            *targetAddr = 0x20;
            targetAddr++;
        }
        *targetAddr = 0;
    }
	free(argPtrs);
}

