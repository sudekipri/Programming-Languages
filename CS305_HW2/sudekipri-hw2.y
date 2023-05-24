%{
	#include<stdio.h>
	void yyerror(const char *s)
	{
	}
%}


%token	tSTRING
%token	tNUM
%token	tPRINT
%token	tGET
%token	tSET
%token	tFUNCTION
%token	tRETURN
%token	tIDENT
%token	tEQUALITY
%token	tIF
%token	tGT
%token	tLT
%token	tGEQ
%token	tLEQ
%token	tINC
%token	tDEC
%token 	tADD
%token	tSUB
%token	tMUL
%token	tDIV






%start program

%%

program:	'[' statementlist ']'
		;

statementlist:	 
		| statementlist statement
		;

statement:	set
		| if
		| print
		| increment
		| decrement
		| return
		| expression  
		;

set:		'[' tSET ',' tIDENT ',' expression ']'
		;

if:		'[' tIF ',' condition ',' then else ']'
		| '[' tIF ',' condition ',' then ']'
		;

print:		'[' tPRINT ',' '[' expression ']' ']'
		;

increment:	'[' tINC ',' tIDENT ']' 
		;

decrement:	'[' tDEC ',' tIDENT ']'
		;

return:		'[' tRETURN ',' expression ']'
		| '[' tRETURN ']'
		;

expression:	tNUM
		| tSTRING
		| get
		| function
		| operator
		| condition
		;

condition:	'[' tLEQ ',' expression ',' expression ']'
		| '[' tGEQ ',' expression ',' expression ']'
		| '[' tEQUALITY ',' expression ',' expression ']'
		| '[' tGT ',' expression ',' expression ']'
		| '[' tLT ',' expression ',' expression ']'
 		;

then:		'[' statementlist  ']'
		;

else:		'[' statementlist ']'
		;

get:		'[' tGET ',' tIDENT ']'
		| '[' tGET ',' tIDENT ',' '[' ']' ']'
		| '[' tGET ',' tIDENT ',' '[' expressionlist ']' ']'
		;

function:	'[' tFUNCTION ',' '[' ']' ',' '[' statementlist ']' ']'
		| '[' tFUNCTION ',' '[' parameterlist ']' ',' '[' statementlist ']' ']' 
		;

operator:	'[' tADD ',' expression ',' expression ']'
		| '[' tSUB ',' expression ',' expression ']'
		| '[' tMUL ',' expression ',' expression ']'
		| '[' tDIV ',' expression ',' expression ']'
		;

expressionlist:	expression ',' expressionlist
		| expression
		;

parameterlist:	parameterlist ',' tIDENT
		| tIDENT
		;

%%
int main()
{
	if (yyparse())
	{
		// parse error
		printf("ERROR\n");
		return 1;
	}
	else
	{
		// successful parsing
         	printf("OK\n");
		return 0;
	}
}

