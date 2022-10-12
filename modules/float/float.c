#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

/** Floating point code that's just complex to reasonably render in assembly **/


/* return "nan" string */
char* fpStringNaNDouble(char* buffer)
{
	buffer[0] = 'n';
	buffer[1] = 'a';
	buffer[2] = 'n';
	buffer[3] = ' ';
	buffer[4] = '\0';
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
	buffer[index++] = ' ';
	buffer[index] = '\0';
	return buffer;
}

/* Put the characters at the end of the buffer at its start */
char* fpFinalProcess(char* buffer, uint64_t sign, uint64_t endIndex)
{
	/*Assume the buffer is 1024 characters long */
	uint64_t startIndex = 0;
	if (sign) {
		buffer[startIndex++] = '-';
	}
	do {
		buffer[startIndex++] = buffer[endIndex++];
	} while (endIndex < 1024);
	buffer[startIndex] = ' ';
	buffer[startIndex] = '\0';
	return buffer;
}

/* Process the integer part of the mantissa, returning the index into the buffer used for writing */
uint64_t fpStringProcessInteger(char* buffer, uint64_t mantissa, int64_t power, uint64_t sign, uint64_t radix, uint64_t endIndex)
{
	uint64_t bit = 1;
	uint64_t summation = 0;		/* working dividend then remainder */
	uint64_t numberCalculation = mantissa;
	int64_t index = 63;		/* initial value */
	uint64_t nextBit = 0;
	uint64_t nextNumber = 0;
	uint64_t shortenedBy = 0;
	bool foundNumber = false;
	int64_t powerLeft = power;
	uint64_t totalShifts = 0;
	/* flush mantissa left */
	uint64_t testBit = 0x8000000000000000;
	
	while (numberCalculation)
	{
		while ((testBit & numberCalculation) == 0) {
			numberCalculation = numberCalculation << 1;
		}
		do {
			summation = summation << 1;
			if (totalShifts++ < 64) {
				nextNumber = nextNumber << 1;
				nextBit = numberCalculation & (bit << index--);
				if (0 != nextBit) {
					summation = summation | 1;
				}
			}
			if (summation / radix == 1) {
				if (false == foundNumber) {
					foundNumber = true;
				}
				nextNumber = nextNumber | 1;
				summation = summation % radix;
			} else {
				if (false == foundNumber) {
					shortenedBy++;
				}
			}
		} while (--powerLeft >= 0);
		if (summation > 9) {
			summation += 55;
		} else {
			summation += 48;
		}
		char addIn = (char)summation;
		buffer[endIndex--] = addIn;
		powerLeft = power - shortenedBy;
		power = powerLeft;
		index = 63;
		summation = 0;
		numberCalculation = nextNumber;
		nextNumber = 0;
		totalShifts = 0;
		shortenedBy = 0;
		foundNumber = false;
	}
	return endIndex;
}

char fpStringGetDigit(double numberIn, uint64_t radix)
{
	int intFromDouble = (int) numberIn;
	if (intFromDouble == 0) {
		return 0;
	}
	int leftOver = intFromDouble % radix;
	return (char)leftOver;
}


uint64_t fpStringProcessFraction(char* buffer, uint64_t mantissa, int64_t power, uint64_t sign, uint64_t radix, uint64_t endIndex)
{
	/* find smallest digit */
	uint64_t bit = 1;
	uint64_t displacement = 0;
	while ((mantissa & (bit << displacement)) == 0) {
		displacement++;
	}
	if (power >= 0) {
		power = 1;
	} else {
		power = -1 * power;
	}
	double fraction = 0.0;
	for (uint i = 63; i >= displacement; i--) {
		if ((mantissa & (bit << i)) != 0) {
			fraction += 1 / pow(2.0, power);
		}
		power++;
	}
	bool startedOutput = false;
	uint64_t digitsLeft = 9;
	uint64_t totalOutput = 0;
	uint64_t powerUp = 1;
	while (digitsLeft) {
		double bigResult = fraction * pow(radix, powerUp++);
		char digit = fpStringGetDigit(bigResult, radix);
		if (!startedOutput && digit != 0) {
			startedOutput = true;
		}
		if (digit > 9) {
			digit += 55;
		} else {
			digit += 48;
		}
		buffer[endIndex--] = digit;
		if (startedOutput) {
			digitsLeft--;
		}
	}
	/* Now reverse the digits */
	uint64_t rightSide = 1023;
	uint64_t leftSide = endIndex + 1;
	while (leftSide < rightSide) {
		char rChar = buffer[rightSide];
		char lChar = buffer[leftSide];
		buffer[leftSide++] = rChar;
		buffer[rightSide--] = lChar;
	}
	/* check for shift left */
	int shiftLeft = 0;
	uint64_t shiftLeftIndex = 1023;
	while (buffer[shiftLeftIndex--] == '0') {
		shiftLeft++;
	}
	if (shiftLeft != 0) {
		shiftLeftIndex = 1023;
		uint64_t mvCharIndex = shiftLeftIndex - shiftLeft;
		while (mvCharIndex > endIndex) {
			buffer[shiftLeftIndex--] = buffer[mvCharIndex--];
		}
		endIndex += shiftLeft;
	}
	return endIndex;
}

/* Partition the mantissa and call processing functions */
char* fpStringProcessDouble(char* buffer, int64_t power, uint64_t mantissa, uint64_t sign, uint64_t radix)
{
	uint64_t fractionalMantissa = 0;
	uint64_t integerMantissa = 0;
	uint64_t bit = 1;
	if (power >= 0 ) {
		/* part that's right of . */
		fractionalMantissa = mantissa << (power + 1);
		/* and to the left */
		integerMantissa = mantissa >> (63 - power);
	} else {
		fractionalMantissa = mantissa;
	}
	/* Track the write point at the end of the buffer */
	uint64_t endIndex = 1023;
	if (fractionalMantissa > 0) {
		endIndex = fpStringProcessFraction(buffer, fractionalMantissa, power, sign, radix, endIndex);
	} else {
		buffer[endIndex--] = '0';
	}
	buffer[endIndex--] = '.';
	if (integerMantissa > 0) {
		endIndex = fpStringProcessInteger(buffer, integerMantissa, power, sign, radix, endIndex);
	} else {
		buffer[endIndex--] = '0';
	}
	buffer[endIndex] = '\n';
	return fpFinalProcess(buffer, sign, endIndex);
}

//Returns a pointer to a string allocated on the heap
//Caller must free memory
//Inputs: 
//uint64_t for floating point input (IEEE754 double number)
//usnigned long for conversion radix
char* getFloatingPointStringDouble(uint64_t fpInput, uint64_t radix)
{
	const uint64_t powerMask = 0x7FF0000000000000;
	const uint64_t signMask = 0x8000000000000000;
	char* answerString = (char*)malloc(1024);
	if (NULL != answerString) {
		const uint64_t power = (fpInput & powerMask) >> 52;
		uint64_t mantissa = fpInput << 12;
		mantissa = 0x8000000000000000 | (mantissa >> 1);
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
		const int64_t normPower = power - 1023;
		/* And pass on to where the work is done */
		return fpStringProcessDouble(answerString, normPower, mantissa, sign, radix);
	}
	return answerString;
}
