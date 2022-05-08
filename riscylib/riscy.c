/** RISCYLIB                                            **/
/** Common code for Riscyforth and Riscyforth modules   **/
/** Copyright (C) Adrian McMenamin, 2022                **/
/** Licenced for reuse under the terms of v2 of GNU GPL **/

unsigned long nextAddress = 0;
unsigned long dictionaryAddress = 0;

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
