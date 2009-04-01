%token NOTOKEN NEWLINE 

%token <string_val> WORD LABEL COMMAND REGISTER

%{
extern "C" int yylex();
extern "C" int yyerror(const char*);
#include <stdio.h>
#define yylex yylex
%}

%union {
	char* string_val;
	}

%%
	goal:
		lines
		;

	lines:
		line
		|
		lines line
		;
	
	line: oneline
	;

	oneline:
		command args NEWLINE
		{
		}
		|
		NEWLINE
		|
		error { yyerrok; }
		;

	command:
		COMMAND
		{
			printf("COMMAND %s\n", $1);
		}
		;
	
	args:
		args arg
		|
	;

	arg:
		REGISTER
		{
			printf("REGISTER %s\n", $1);
		}
		|
		LABEL
		{
			printf("LABEL %s\n", $1);
		}
	;
%%

#define BUILTIN
#ifdef BUILTIN
int main()
{
	yyparse();
	return 0;
}
#endif
