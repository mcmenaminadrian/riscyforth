#include <stdlib.h>
#include <stdint.h>
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
char* fpStringInfinityDouble(char* buffer, uint64_t sign)
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

/* Put the characters at the end of the buffer at its start */
char* fpReverseBuffer(char* buffer)
{
	/*Assume the buffer is 1024 characters long */
	uint64_t indexEnd = 1023;
	uint64_t indexStart = 0;
	while (buffer[indexEnd] != '\n') {
		buffer[indexStart++] = buffer[indexEnd--];
	}
	buffer[indexStart] = '\n';
	return buffer;
}

char* fpStringProcessFraction(char* buffer, uint64_t fraction, uint64_t bufferIndex, uint64_t radix)
{
	return buffer;
}


char* fpStringFractionDouble(char* buffer, uint64_t normPower, uint64_t mantissa, uint64_t sign, uint64_t radix)
{
	return buffer;
}

/* Process a number > 1 */
char* fpStringNumberDouble(char* buffer, uint64_t normPower, uint64_t mantissa, uint64_t sign, uint64_t radix)
{
	/* Find the size of the mantissa */
	uint64_t bitCheck = 1;
	uint64_t lengthCheck = 0;
	while (bitCheck & mantissa == 0 && lengthCheck++ < 52) {
		bitCheck = bitCheck << 1;
	}
	/* fix up mantissa */
	uint64_t addOne = 1;
	mantissa = mantissa | (addOne << 52);
	/* index to scratch pad part of buffer */
	uint64_t scratchPadIndex = 1023;
	uint64_t leftNumber = (mantissa >> lengthCheck);
	uint64_t rightNumber = 0;
	uint64_t adjustedPower = normPower;
	if (normPower < (53 - lengthCheck)) {
		rightNumber = leftNumber << ((64 - lengthCheck) - 
			((53 - lengthCheck) - normPower));
		rightNumber = rightNumber >> (63 - (53 - lengthCheck) - normPower);
		leftNumber = leftNumber >> (lengthCheck - normPower);
		adjustedPower = normPower - (53 - lengthCheck);
	}
	/* process number */
	uint64_t summation = 0;
	uint64_t number_calculation = leftNumber;
	int64_t index = 52;		/* initial value */
	uint64_t nextBit = 0;
	uint64_t nextNumber = 0;
	uint64_t shortenedBy = 0;
	bool foundNumer = false;
	int64_t currentIndex = index;
	uint64_t powerLeft = normPower;
	while (index > 0)
	{
		uint64_t totalShifts = 0;
		do {
			summation = summation << 1;
			if (totalShifts++ < 64) {
				nextNumber = nextNumber << 1;
			}
			if (currentIndex >= 0) {
				nextBit = number_calculation & (bitCheck << currentIndex);
			}
			currentIndex--;
			summation = summation | nextBit;
			if (summation / radix == 1) {			/* can only be 1 or 0 */
				if (!foundNumber) {
					foundNumber = true;
				}
				summation = summation % radix;
				if (totalShifts < 64)
					nextNumber = nextNumber | 1;
				}
			} else if (!foundNumber) {
				shortenedBy++;
			}
		} while (--powerLeft)
		if (summation > 9) {
			summation += 55;
		} else {
			summation += 48;
		}
		char addIn = (char)summation;
		buffer[scratchPadIndex--] = addIn;
		powerLeft = normPower - shortenedBy;
		index -= shortenedBy;
		currentIndex = index;
	}		
		
}


//Returns a pointer to a string allocated on the heap
//Caller must free memory
//Inputs: 
//uint64_t for floating point input (IEEE754 double number)
//usnigned long for conversion radix
char* getFloatingPointStringDouble(uint64_t fpInput, uint64_t radix)
{
	/* set the answer to NULL by fault */
	char* answerString = NULL;
	const uint64_t powerMask = 0x7FF0000000000000;
	const uint64_t mantissaMask = 0xFFFFFFFFFFFFF;
	const uint64_t signMask = 0x8000000000000000;

	answerString = (char*)malloc(1024);
	if (NULL != answerString) {
		const uint64_t power = (fpInput & powerMask) >> 52;
		const uint64_t mantissa = fpInput & mantissaMask;
		const uint64_t sign = (fpInput&signMask) >> 63;
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
		const uint64_t normPower = power - 1023;
		/* And pass on to where the work is done */
		if (normPower < 0) {
			return fpStringFractionDouble(answerString, normPower, mantissa, sign, radix);
		} else {
			return fpStringNumberDouble(answerString, normPower, mantissa, sign, radix);
		}
	}
	return answerString;
}
