%{
	#include <stdio.h>
	#include <stdbool.h>
	#include <string.h>
	#include "sudekipri-hw3.h"

	void yyerror (const char *s) 
	{
	}

	extern int numLines;

	void printResults (AttributeSet *);
	int  myRound(double);
	void insertNode(AttributeSet *);

	struct Node {
		AttributeSet * AttributeSetPtr;
		struct Node * next;
};

	struct Node * head = NULL;
%}

%union {
	int 		lineNumber;
	LiteralValue  *	literalValuePtr;	
	AttributeSet *	AttributeSetPtr;
}

%token tPRINT tGET tSET tFUNCTION tRETURN tIDENT tEQUALITY tIF tGT tLT tGEQ tLEQ tINC tDEC
%token <literalValuePtr>		 	tNUM
%token <literalValuePtr> 			tSTRING
%token <lineNumber>					tADD
%token <lineNumber>	                                tSUB
%token <lineNumber>	                                tMUL
%token <lineNumber>	                                tDIV
%type <AttributeSetPtr> 			setStatement
%type <AttributeSetPtr> 			if
%type <AttributeSetPtr> 			print
%type <AttributeSetPtr> 			expression
%type <AttributeSetPtr> 			returnStatement
%type <AttributeSetPtr> 			getExpression
%type <AttributeSetPtr> 			operation
%type <AttributeSetPtr> 			function
%type <AttributeSetPtr> 			condition
%type <AttributeSetPtr> 			expressionList

%start program

%%
program:		'[' statementList ']' {
			struct Node * ptr;
			ptr = head;
			while (ptr != NULL)
			{
				printResults(ptr-> AttributeSetPtr);
				ptr = ptr->next;
			}
		}
;

statementList:	statementList statement | 
;

statement:		setStatement {insertNode($1);}
		| if {insertNode($1);}
		| print {insertNode($1);}
		| unaryOperation
		| expression {insertNode($1);}
		| returnStatement {insertNode($1);}
;

getExpression:	'[' tGET ',' tIDENT ',' '[' expressionList ']' ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = numLines;
			attrSet->isConstant = false;
			attrSet->hasOnlyLiteral = false;

			$$ = attrSet;			
		}
		| '[' tGET ',' tIDENT ',' '[' ']' ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = numLines;
			attrSet->isConstant = false;
			attrSet->hasOnlyLiteral = false;

			$$ = attrSet;
		}
		| '[' tGET ',' tIDENT ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = numLines;
			attrSet->isConstant = false;
			attrSet->hasOnlyLiteral = false;

			$$ = attrSet;
		}
;

setStatement:	'[' tSET ',' tIDENT ',' expression ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = (*$6).lineNumber;
			attrSet->isConstant = (*$6).isConstant;
			attrSet->typeMismatch = (*$6).typeMismatch;
			attrSet->hasOnlyLiteral = (*$6).hasOnlyLiteral;
			attrSet->returnType = (*$6).returnType;
			attrSet->value = (*$6).value;

			$$ = attrSet;			

		}
;

if:		'[' tIF ',' condition ',' '[' statementList ']' ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
                        attrSet->lineNumber = numLines;
                        attrSet->isConstant = false;
                        attrSet->typeMismatch = false;

                        $$ = attrSet;
		}
		| '[' tIF ',' condition ',' '[' statementList ']' '[' statementList ']' ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
                        attrSet->lineNumber = numLines;
                        attrSet->isConstant = false;
                        attrSet->typeMismatch = false;

                        $$ = attrSet;
		}
;

print:		'[' tPRINT ',' '[' expression ']' ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = (*$5).lineNumber;
			attrSet->isConstant = (*$5).isConstant;
			attrSet->typeMismatch = (*$5).typeMismatch;
			attrSet->hasOnlyLiteral = (*$5).hasOnlyLiteral;
			attrSet->returnType = (*$5).returnType;
			attrSet->value = (*$5).value;

			$$ = attrSet;
			
		}
;

operation:	'[' tADD ',' expression ',' expression ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = $2;
			attrSet->isConstant = (*$4).isConstant && (*$6).isConstant;			


			if (attrSet->isConstant == true)
			{
				if(((*$4).returnType == INT || (*$4).returnType == REAL) && (*$6).returnType == STRING ||
			   	   ((*$6).returnType == INT || (*$6).returnType == REAL) && (*$4).returnType == STRING) attrSet->typeMismatch = true;
				else attrSet->typeMismatch = false;
			}
			else attrSet->typeMismatch = true;			

			attrSet->hasOnlyLiteral = false;
			
			if (attrSet->typeMismatch == false)
			{
				if ((*$4).returnType == INT && (*$6).returnType == INT) {attrSet->returnType = INT; attrSet->value.integerValue = (*$4).value.integerValue + (*$6).value.integerValue;}
                        	else if ((*$4).returnType == INT && (*$6).returnType == REAL) {attrSet->returnType = REAL; attrSet->value.realValue = (double) (*$4).value.integerValue + (*$6).value.realValue;}
                        	else if ((*$4).returnType == REAL && (*$6).returnType == INT) {attrSet->returnType = REAL; attrSet->value.realValue = (*$4).value.realValue + (double) (*$6).value.integerValue;}
                        	else if ((*$4).returnType == REAL && (*$6).returnType == REAL) {attrSet->returnType = REAL; attrSet->value.realValue = (*$4).value.realValue + (*$6).value.realValue;}
				else 
				{
					attrSet->returnType = STRING;
				
					char str1[strlen((*$4).value.stringValue) + strlen((*$6).value.stringValue)], str2[strlen((*$6).value.stringValue)];
					strcpy(str1, (*$4).value.stringValue);
					strcpy(str2, (*$6).value.stringValue);
					strcat(str1, str2);
					char * addResult = (char *) malloc(strlen(str1) + 1);
					strcpy(addResult, str1);
					attrSet->value.stringValue = addResult;
				}
			}
			$$ = attrSet;

		}
		| '[' tSUB ',' expression',' expression ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = $2;
                        attrSet->isConstant = (*$4).isConstant && (*$6).isConstant;
			
			if (attrSet->isConstant == true)
			{
                        	if ((*$4).returnType == STRING || (*$6).returnType == STRING) attrSet->typeMismatch = true;
				else attrSet->typeMismatch = false;
			}
			else attrSet-> typeMismatch = true;
			
			attrSet->hasOnlyLiteral = false;
			
			if (attrSet-> typeMismatch == false)
			{
				if ((*$4).returnType == INT && (*$6).returnType == INT) {attrSet->returnType = INT; attrSet->value.integerValue = (*$4).value.integerValue - (*$6).value.integerValue;}
				else if ((*$4).returnType == INT && (*$6).returnType == REAL) {attrSet->returnType = REAL; attrSet->value.realValue = (double) (*$4).value.integerValue - (*$6).value.realValue;}
				else if ((*$4).returnType == REAL && (*$6).returnType == INT) {attrSet->returnType = REAL; attrSet->value.realValue = (*$4).value.realValue - (double) (*$6).value.integerValue;}
				else {attrSet->returnType = REAL; attrSet->value.realValue = (*$4).value.realValue - (*$6).value.realValue;}
			}
			$$ = attrSet;

		}
		| '[' tMUL ',' expression ',' expression ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = $2;
                       	attrSet->isConstant = (*$4).isConstant && (*$6).isConstant;
			
			if (attrSet->isConstant == true)
			{
				if ((*$4).returnType == STRING || (*$4).returnType == REAL && (*$6).returnType == STRING  ||
			    	    (*$4).returnType == INT && (*$4).value.integerValue < 0 && (*$6).returnType == STRING) attrSet->typeMismatch = true;
				else attrSet-> typeMismatch = false;
                        }
			else attrSet-> typeMismatch = true;
			 
                        attrSet->hasOnlyLiteral = false;
			
			if (attrSet-> typeMismatch == false)
			{
				if ((*$4).returnType == INT && (*$6).returnType == INT) {attrSet->returnType = INT; attrSet->value.integerValue = (*$4).value.integerValue * (*$6).value.integerValue;}
                        	else if ((*$4).returnType == INT && (*$6).returnType == REAL) {attrSet->returnType = REAL; attrSet->value.realValue = (double) (*$4).value.integerValue * (*$6).value.realValue;}
                        	else if ((*$4).returnType == REAL && (*$6).returnType == INT) {attrSet->returnType = REAL; attrSet->value.realValue = (*$4).value.realValue * (double) (*$6).value.integerValue;}
                        	else if ((*$4).returnType == REAL && (*$6).returnType == REAL) {attrSet->returnType = REAL; attrSet->value.realValue = (*$4).value.realValue * (*$6).value.realValue;}



                        	else   
                        	{
					attrSet->returnType = STRING;

					char str1[((*$4).value.integerValue + 1) * strlen((*$6).value.stringValue)], str2[strlen((*$6).value.stringValue)];
					strcpy(str1, "");
					strcpy(str2, (*$6).value.stringValue);
					
					int i = 0;
					for (; i < (*$4).value.integerValue; i++) strcat(str1, str2);
					char * multiplyResult = (char *) malloc(strlen(str1) + 1);
					strcpy(multiplyResult, str1);
					attrSet->value.stringValue = multiplyResult;
                        	}
			}
			$$ = attrSet;

		}
		| '[' tDIV ',' expression ',' expression ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = $2;
                        attrSet->isConstant = (*$4).isConstant && (*$6).isConstant;
                       	
			if (attrSet->isConstant == true)
			{
				if ((*$4).returnType == STRING || (*$6).returnType == STRING) attrSet->typeMismatch = true;
                        	else attrSet-> typeMismatch = false;
			}
			else attrSet-> typeMismatch = true;			

                        attrSet->hasOnlyLiteral = false;
			
			if (attrSet-> typeMismatch == false)
			{
				if ((*$4).returnType == INT && (*$6).returnType == INT) {attrSet->returnType = INT; attrSet->value.integerValue = (*$4).value.integerValue / (*$6).value.integerValue;}
                        	else if ((*$4).returnType == INT && (*$6).returnType == REAL) {attrSet->returnType = REAL; attrSet->value.realValue = (double) (*$4).value.integerValue / (*$6).value.realValue;}
                        	else if ((*$4).returnType == REAL && (*$6).returnType == INT) {attrSet->returnType = REAL; attrSet->value.realValue = (*$4).value.realValue / (double) (*$6).value.integerValue;}
                        	else {attrSet->returnType = REAL; attrSet->value.realValue = (*$4).value.realValue / (*$6).value.realValue; 
				}
			}
			$$ = attrSet;

		}
;	

unaryOperation: '[' tINC ',' tIDENT ']'
		| '[' tDEC ',' tIDENT ']'
;

expression:		tNUM {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = numLines;
			attrSet->isConstant = true;
			attrSet->typeMismatch = false;
			attrSet->hasOnlyLiteral = true;
			attrSet->returnType = (*$1).returnType;
			if ((*$1).returnType == INT) attrSet->value.integerValue = (*$1).integerValue;
			else attrSet->value.realValue = (*$1).realValue;

			$$ = attrSet;
		} 
		| tSTRING {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = numLines;
			attrSet->isConstant = true;
			attrSet->typeMismatch = false;
			attrSet->hasOnlyLiteral = true;
			attrSet->returnType = (*$1).returnType;
			attrSet->value.stringValue = (*$1).stringValue;
			
			$$ = attrSet;

		}
		| getExpression {
			$$ = $1;

		} 
		| function {
			$$ = $1;
			
		} 
		| operation {
                        $$ = $1;
			
		}
		| condition {
                        $$ = $1;

		}
;

function:	'[' tFUNCTION ',' '[' parametersList ']' ',' '[' statementList ']' ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = numLines;
						
			$$ = attrSet;
		}
		| '[' tFUNCTION ',' '[' ']' ',' '[' statementList ']' ']' {
			AttributeSet  * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = numLines;
			
			$$ = attrSet;
		}
;

condition:	'[' tEQUALITY ',' expression ',' expression ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = numLines;

			$$ = attrSet;
			
			insertNode($4);
			insertNode($6);
		}
		| '[' tGT ',' expression ',' expression ']' {
			AttributeSet *	attrSet	= (AttributeSet *) malloc(sizeof(AttributeSet));
                        attrSet->lineNumber	= numLines;

                        $$ = attrSet;
			
			insertNode($4);
                        insertNode($6);
		}
		| '[' tLT ',' expression ',' expression ']' {
			AttributeSet *	attrSet	= (AttributeSet *) malloc(sizeof(AttributeSet));
                        attrSet->lineNumber	= numLines;

                        $$ = attrSet;
			
			insertNode($4);
                        insertNode($6);
		}
		| '[' tGEQ ',' expression ',' expression ']' {
			AttributeSet *	attrSet	= (AttributeSet *) malloc(sizeof(AttributeSet));
                        attrSet->lineNumber	= numLines;

                        $$ = attrSet;
			
			insertNode($4);
                        insertNode($6);
		}
		| '[' tLEQ ',' expression ',' expression ']' {
			AttributeSet *	attrSet	= (AttributeSet *) malloc(sizeof(AttributeSet));
                        attrSet->lineNumber	= numLines;

                        $$ = attrSet;
			
			insertNode($4);
                        insertNode($6);
		}
;

returnStatement:	'[' tRETURN ',' expression ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = (*$4). lineNumber;
			attrSet->isConstant = (*$4).isConstant;
			attrSet->typeMismatch = (*$4).typeMismatch;
			attrSet->hasOnlyLiteral = (*$4).hasOnlyLiteral;			
			attrSet->returnType = (*$4).returnType;
			attrSet->value = (*$4).value;
                        
			$$ = attrSet;
			
		}
		| '[' tRETURN ']' {
			AttributeSet * attrSet = (AttributeSet *) malloc(sizeof(AttributeSet));
			attrSet->lineNumber = numLines;
			attrSet->isConstant = false;
			attrSet->typeMismatch = false;		

			$$ = attrSet;
		}
;

parametersList: parametersList ',' tIDENT | tIDENT
;

expressionList:	expressionList ',' expression {insertNode($3);} 
		| expression {insertNode($1);}
;

%%

void insertNode(AttributeSet * attrSet)
{
	if (head == NULL)
	{
		struct Node * new_node = (struct Node*) malloc(sizeof(struct Node));
		new_node-> AttributeSetPtr = attrSet;
		new_node->next = NULL;
		head = new_node;
	}

	else
	{
		struct Node * ptr;
		ptr = head; 
		while (ptr->next != NULL) ptr = ptr->next;
		
		struct Node * new_node = (struct Node*) malloc(sizeof(struct Node));
		new_node-> AttributeSetPtr = attrSet;
		new_node->next = NULL;
		ptr->next = new_node;
	}
}

int myRound(double x)
{
	if (x < 0.0)	return (int)(x - 0.5);
	else		return (int)(x + 0.5);
}

void printResults(AttributeSet * attrSet)
{
	if ((* attrSet).hasOnlyLiteral == true || (* attrSet).isConstant == false)
	{
		printf("");
	}
	
	else if ((* attrSet).typeMismatch == true)
	{
		printf("Type mismatch on %d\n", (* attrSet).lineNumber);
	}

	else if ((* attrSet).returnType == INT)
	{
		printf("Result of expression on %d is (%d)\n", (* attrSet).lineNumber, (* attrSet).value.integerValue);
	}
	
	else if ((* attrSet).returnType == REAL)
	{
		double realValue = (* attrSet).value.realValue;
		realValue = (double) myRound(realValue * 10)/10;

		printf("Result of expression on %d is (%.1f)\n", (* attrSet).lineNumber, realValue);
	}

	else if ((* attrSet).returnType == STRING)
	{
		printf("Result of expression on %d is (%s)\n", (* attrSet).lineNumber, (* attrSet).value.stringValue);
	}

	else
	{
		printf("PROGRAM HAS A BUG ON PRINT STATEMENT WHICH ENTERS ELSE!!!\n");       
	}
}

int main ()
{
	if (yyparse()) {
		// parse error
		printf("ERROR\n");
		return 1;
	}
	else {
		// successful parsing
		//printf("OK\n");
		return 0;
	}
}
