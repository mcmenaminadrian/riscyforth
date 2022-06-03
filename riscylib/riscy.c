/** RISCYLIB                                            **/
/** Common code for Riscyforth and Riscyforth modules   **/
/** Copyright (C) Adrian McMenamin, 2022                **/
/** Licenced for reuse under the terms of v2 of GNU GPL **/

extern unsigned long INPUT_START;
extern unsigned long INPUT_END;

unsigned long nextAddress;
unsigned long dictionaryAddress;

unsigned long getNextAddress(void)
{
	return nextAddress;
}

void setNextAddress(unsigned long addressIn)
{
	nextAddress = addressIn;
}

unsigned long getDictionaryAddress(void)
{
	return dictionaryAddress;
}

void setDictionaryAddress(unsigned long addressIn)
{
	dictionaryAddress = addressIn;
}

unsigned long getInputStart(void)
{
	return INPUT_START;
}

unsigned long getInputEnd(void)
{
	return INPUT_END;
}