#include <stdlib.h>
/** Floating point code that's just complex to reasonably render in assembly **/


/* return "nan" string */
char* fpStringNaNDouble(char* buffer)
{
	buffer[0] = 'n';
	buffer[1] = 'a';
	buffer[2] = 'n';
	buffer[3] = '\n';
	return buffer;
}

/* return "inf" string */
char* fpStringInfinityDouble(char* buffer, unsigned long sign)
{
	int index = 0;
	if (0 != sign) {
		buffer[index++] = '-';
	}
	buffer[index++] = 'i';
	buffer[index++] = 'n';
	buffer[index++] = 'f';
	buffer[index] = '\n';
	return buffer;
}

char* fpStringNumberDouble(char* buffer, unsigned long normPower, unsigned long mantissa, unsigned long sign, unsigned long radix)
{
	


//Returns a pointer to a string allocated on the heap
//Caller must free memory
//Inputs: 
//unsigned long for floating point input (IEEE754 double number)
//usnigned long for conversion radix
char* getFloatingPointStringDouble(unsigned long fpInput, unsigned long radix)
{
	/* set the answer to NULL by fault */
	char* answerString = NULL;
	const unsigned long powerMask = 0x7FF0000000000000;
	const unsigned long mantissaMask = 0xFFFFFFFFFFFFF;
	const unsigned long signMask = 0x8000000000000000;

	answerString = (char*)malloc(1024);
	if (NULL != answerString) {
		const unsigned long power = (fpInput & powerMask) >> 52;
		const unsigned long mantissa = fpInput & mantissaMask;
		const unsigned long sign = (fpInput&signMask) >> 63;
		/* Handle special cases */
		if (power == 0x7FF) {
			/* infinity */
			if (mantissa == 0) {
				return fpStringInfinityDouble(answerString, sign);
			} else {
				/* NaN */
				return fpStringNaNDouble(answerString);
			}
		}
		/* normalise power */
		const unsigned long normPower = power - 1023;
		/* And pass on to where the work is done */
		if (normPower < 0) {
			return fpStringFractionDouble(char* buffer, normPower, mantissa, sign, radix);
		} else {
			return fpStringNumberDouble(char* buffer, normPower, mantissa, sign, radix);
		}
	}
	return answerString;
}
