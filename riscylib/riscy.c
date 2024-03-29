/** RISCYLIB                                            **/
/** Common code for Riscyforth and Riscyforth modules   **/
/** Copyright (C) Adrian McMenamin, 2022                **/
/** Licensed for reuse under the terms of v2 of GNU GPL **/

#include <stdlib.h>

extern unsigned long INPUT_START;
extern unsigned long INPUT_END;
extern unsigned long dictionary;
extern unsigned long newdictionary;
extern unsigned long createwritepoint;
extern unsigned long INPUT_DISPLACE;
extern unsigned long SCRATCH_PAD;
extern unsigned long CURRENT_BASE;
extern unsigned long CREATEFLAG;
extern unsigned long outerLoopTokenizeAddress;
extern unsigned long dataspaceptr;
extern unsigned long FP_AVAILABLE;
extern unsigned long STACKTOP;

static unsigned long EXTENDERS[512];
static unsigned long EXTENDERSINDEX = 0;
//FPSTACK only created if we load FP module
static unsigned long *FPSTACK = NULL;
static unsigned long FPSTACKCOUNT = 0;

unsigned long nextAddress;

unsigned long getNextAddress(void)
{
	return nextAddress;
}

void setNextAddress(unsigned long addressIn)
{
	nextAddress = addressIn;
}

unsigned long getInputStart(void)
{
	return INPUT_START;
}

unsigned long getInputEnd(void)
{
	return INPUT_END;
}

void setInputStart(unsigned long addressIn)
{
	INPUT_START = addressIn;
}

void setInputStartIncrement(unsigned long addressIn)
{
	unsigned long increment = addressIn - INPUT_START;
	INPUT_START = addressIn;
	INPUT_DISPLACE += increment;
}

unsigned long getDictionary(void)
{
	return dictionary;
}

unsigned long getNewDictionary(void)
{
	return newdictionary;
}

unsigned long getCreateWritePoint(void)
{
	return createwritepoint;
}

void setDictionary(unsigned long addressIn)
{
	dictionary = addressIn;
}

void setNewDictionary(unsigned long addressIn)
{
	newdictionary = addressIn;
}

void setCreateWritePoint(unsigned long addressIn)
{
	createwritepoint = addressIn;
}

void incrementInputDisplace(unsigned long increment)
{
	INPUT_DISPLACE += increment;
}

unsigned long *getScratchPad(void)
{
	return &SCRATCH_PAD;
}

unsigned long getCurrentBase(void)
{
	return CURRENT_BASE;
}

unsigned long getCreateFlag(void)
{
	return CREATEFLAG;
}

void setCreateFlag(unsigned long flagValue)
{
	CREATEFLAG = flagValue;
}

unsigned long getOuterLoopTokenize(void)
{
	return outerLoopTokenizeAddress;
}

unsigned long setExtenders(unsigned long extendThis, unsigned long extendFunc)
{
	unsigned long success = 0;
	if (EXTENDERSINDEX < 255) {
		EXTENDERS[EXTENDERSINDEX * 2] = extendThis;
		EXTENDERS[(EXTENDERSINDEX * 2) + 1] = extendFunc;
		++EXTENDERSINDEX;
		success = 1;
	}
	return success;
}

unsigned long getExtenders(unsigned long extendThis)
{
	unsigned long returnFn = 0;
	for (unsigned long i = 0; i < EXTENDERSINDEX; i++)
	{
		if (EXTENDERS[i * 2] == extendThis) {
			returnFn = EXTENDERS[(i * 2) + 1];
			break;
		}
	}
	
	return returnFn;
}

unsigned long getDataspacePtr(void)
{
	return dataspaceptr;
}

void setDataspacePtr(unsigned long dataPtrIn)
{
	dataspaceptr = dataPtrIn;
}

void setFPAvailable(void)
{
	FP_AVAILABLE = 1;
	FPSTACK = (unsigned long*) malloc(4096);
}

unsigned long *getFPStack(void)
{
	return FPSTACK;
}

unsigned long pushFPStack(unsigned long fpToStack)
{
	unsigned long retVal = 1;
	if (FPSTACKCOUNT < 511) {
		*(FPSTACK + FPSTACKCOUNT * 8) = fpToStack;
		FPSTACKCOUNT++;
		retVal = 0;
	}
	//do nothing if stack is bust
	return retVal;
}

unsigned long popFPStack(void)
{
	unsigned long retVal = 0;
	if (FPSTACKCOUNT > 0) {
		retVal = *(FPSTACK + FPSTACKCOUNT * 8);
		FPSTACKCOUNT--;
	}
	return retVal;
}		
