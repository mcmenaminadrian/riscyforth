/** RISCYLIB                                            **/
/** Common code for Riscyforth and Riscyforth modules   **/
/** Copyright (C) Adrian McMenamin, 2022                **/
/** Licenced for reuse under the terms of v2 of GNU GPL **/

#include <string.h>

extern unsigned long INPUT_START;
extern unsigned long INPUT_END;
extern unsigned long dictionary;
extern unsigned long newdictionary;
extern unsigned long createwritepoint;
extern unsigned long INPUT_DISPLACE;
extern unsigned long SCRATCH_PAD;
extern unsigned long CURRENT_BASE;

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
