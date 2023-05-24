#ifndef __HW3_H
#define __HW3_H

#include <stdio.h>
#include <stdbool.h>

typedef enum {INT, REAL, STRING} LiteralType;

typedef struct LiteralValue {
	LiteralType returnType;
	union
	{
		int integerValue;
		double realValue;
		char * stringValue;
	};
} LiteralValue;

typedef struct AttributeSet {
        int lineNumber;
        bool isConstant;
        bool typeMismatch;
	bool hasOnlyLiteral;
        LiteralType returnType;
	LiteralValue value;
} AttributeSet;

#endif
