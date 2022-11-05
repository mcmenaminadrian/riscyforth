#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <string.h>

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
	buffer[startIndex++] = ' ';
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

char fpStringGetDigit(int numberIn, uint64_t radix)
{
	uint64_t intFromDouble = (uint64_t) numberIn;
	if (intFromDouble == 0) {
		return 0;
	}
	uint64_t leftOver = intFromDouble % radix;
	return (char)leftOver;
}


uint64_t fpStringProcessFraction(char* buffer, uint64_t mantissa, int64_t power,
	uint64_t sign, uint64_t radix, uint64_t endIndex, int precision)
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
			fraction += 1.0 / pow(2.0, power);
		}
		power++;
	}
	bool startedOutput = false;
	uint64_t digitsLeft = precision;
	uint64_t totalOutput = 0;
	uint64_t powerUp = 1;
	while (digitsLeft) {
		double pInt;
		double bigResult = fraction * pow(radix, powerUp);
		fraction = modf(bigResult, &pInt);
		char digit = fpStringGetDigit(pInt, radix);
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
char* fpStringProcessDouble(char* buffer, int64_t power, uint64_t mantissa,
	uint64_t sign, uint64_t radix, int precision)
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
		endIndex = fpStringProcessFraction(buffer, fractionalMantissa, power, sign, radix, endIndex, precision);
	} else {
		buffer[endIndex--] = '0';
	}
	buffer[endIndex--] = '.';
	if (integerMantissa > 0) {
		endIndex = fpStringProcessInteger(buffer, integerMantissa, power, sign, radix, endIndex);
	} else {
		buffer[endIndex--] = '0';
	}
	buffer[endIndex] = '\2';
	return fpFinalProcess(buffer, sign, endIndex);
}

char* fpZeroCase(bool neg)
{
	/* special case of zero or negative zero */
	char* answerString = (char*)malloc(8);
	int index = 0;
	if (neg) {
		answerString[index++] = '-';
	}
	answerString[index++] = '0';
	answerString[index++] = '.';
	answerString[index++] = '0';
	answerString[index++] = ' ';
	answerString[index++] = '\0';
	return answerString;
}

//Returns a pointer to a string allocated on the heap
//Caller must free memory
//Inputs: 
//uint64_t for floating point input (IEEE754 double number)
//usnigned long for conversion radix
char* getFloatingPointStringDouble(uint64_t fpInput, uint64_t radix, int precision)
{
	if (fpInput == 0 || fpInput == 0x8000000000000000) {
		return fpZeroCase(fpInput == 0x8000000000000000);
	}
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
			if (mantissa == 0x8000000000000000) {
				/* infinity */
				return fpStringInfinityDouble(answerString, sign);
			} else {
				/* NaN */
				return fpStringNaNDouble(answerString);
			}
		}
		/* normalise power */
		const int64_t normPower = power - 1023;
		/* And pass on to where the work is done */
		return fpStringProcessDouble(answerString, normPower, mantissa,
			sign, radix, precision);
	}
	return answerString;
}

long* convertDoubleToLongLong(double input)
{
	long* answerArray = (long *)malloc(sizeof(long[2]));
	if (answerArray)
	{
		long signRect = signbit(input)? -1 : 1;
		double absInput = fabs(input);
		double maxIntAsDouble = pow(2, 64) + 1.0;
		double bigPart = absInput / maxIntAsDouble;
		uint64_t bigAnswer = (uint64_t)bigPart;
		double smallPart = absInput - (bigAnswer * maxIntAsDouble);
		uint64_t smallAnswer = (uint64_t) smallPart;
		if (signRect == -1) {
			answerArray[1] = ~bigAnswer;
			answerArray[0] = ~smallAnswer + 1;
			if (answerArray[0] == 0) {
				answerArray[1] = answerArray[1] + 1;
			}
		} else {
			answerArray[1] = bigAnswer;
			answerArray[0] = smallAnswer;
		}
	}
	return answerArray;
}

double convert128BitsToDouble(int64_t hiPart, uint64_t loPart)
{
	double loDouble = (double)loPart;
	double maxIntAsDouble = pow(2, 64) + 1.0;
	double hiDouble = ((double)hiPart) * maxIntAsDouble;
	return hiDouble + loDouble;
}

char* engineerNumber(int counter, int sign, char* copyString, char* answerString)
{
	int newExp;
	char newStrExp[3] = "   ";
	int revIndex;
	int ext = counter%3;
	if (sign == 0) {
		newExp = counter - ext;
	} else {
		newExp = counter + (3 - ext);
		ext = 3 - ext;
	}
	revIndex = 0;
	while (newExp) {
		char digit = newExp%10 + 48;
		newExp = newExp / 10;
		newStrExp[revIndex++] = digit;
	}
	int writePoint = 0;
	int foundDot = -1;
	int foundE = 0;
	for (int i = 0; i < strnlen(copyString, 1024); i++) {
		char x = copyString[i];
		if (x == '.') {
			foundDot = ext;
		} else if (foundDot > 0) {
			if (copyString[i] == 'e') {
				for (int j = foundDot; j > 0; j--) {
					answerString[writePoint++] = '0';
				}
				answerString[writePoint++] = '.';
				answerString[writePoint++] = '0';
				answerString[writePoint++] = 'e';
				break;
			} else {
				answerString[writePoint++] = copyString[i];
			}
			if (--foundDot == 0) {
				answerString[writePoint++] = '.';
			}
		} else {
			if (copyString[i] == 'e') {
				if (foundDot == -1) {
					for (int j = ext; j > 0; j--) {
						answerString[writePoint++] = '0';
					}
					answerString[writePoint++] = '.';
					answerString[writePoint++] = '0';
				} else {
					if (answerString[writePoint - 1] == '.') {
						answerString[writePoint++] = '0';
					}
				}
				answerString[writePoint++] = 'e';
				break;
			} else {
				answerString[writePoint++] = copyString[i];
			}
		}
	}
	if (sign) {
		answerString[writePoint++] = '-';
	} else {
		answerString[writePoint++] = '+';
	}
	if (newStrExp[2] != ' ') {
		answerString[writePoint++] = newStrExp[2];
	}
	if (newStrExp[1] != ' ') {
		answerString[writePoint++] = newStrExp[1];
	}
	answerString[writePoint++] = newStrExp[0];
	answerString[writePoint++] = ' ';
	answerString[writePoint] = '\0';
	return answerString;
}		


char* unEngineerNumber(char* copyString, char* answerString)
{
	int index = 0;
	while (copyString[index] != '\0') {
		answerString[index] = copyString[index];
		index++;
	}
	answerString[index++] = ' ';
	answerString[index] = '\0';
	return answerString;
}

char* getFloatingPointEngineeringString(double input, int precision)
{
	int sign = 0;
	char* answerString = (char *)malloc(1024);
	char* copyString = (char *)malloc(1024);
	if (answerString && copyString) {
		gcvt(input, precision, copyString);
		size_t strLen = strnlen(copyString, 1024);
		if (strLen < 1024) { //have to have at least one char to avoid buffer overflow
			void* ePointer = memchr(copyString, 'e', strLen);
			if (ePointer) {
				int index = ePointer - (void*)copyString;
				index++;
				int counter = 0;
				if (copyString[index] == '-') {
					index++;
					sign = 1;
				} else if (copyString[index] == '+') {
					index++;
				}
				while (copyString[index] != '\0' && copyString[index] != ' ') {
					counter = (counter * 10) + copyString[index++] - 48;
				}
				if (counter%3 != 0) {
					engineerNumber(counter, sign, copyString, answerString);
				} else {
					unEngineerNumber(copyString, answerString);
				}
			} else {
				unEngineerNumber(copyString, answerString);
			}
		}
	}
	free(copyString);
	return answerString;
}
  
