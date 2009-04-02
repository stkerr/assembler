%token NOTOKEN NEWLINE 

%token <value> VALUE
%token <string_val> WORD LABEL COMMAND REGISTER NEWLABEL EXIT

%{
extern "C" int yylex();
extern "C" int yyerror(const char*);
#include <stdio.h>
#include <string>
#include <vector>
#include <signal.h>

#define yylex yylex

struct dictionary {
	std::string name;
	int memoryLoc;
};

std::vector<dictionary> labels;

int memLocation = 0;
const int sizeOfCommand = 4; // 4 bytes

unsigned int command = 0;
%}

%union {
	int value;
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
		EXIT NEWLINE
		{
			return 0;
		}
		|
		NEWLABEL NEWLINE
		{
			struct dictionary temp;
			temp.name = std::string($1);
			temp.memoryLoc = memLocation;
			labels.push_back(temp);
		}
		|
		command args NEWLINE
		{
			memLocation += sizeOfCommand;
			printf("Command: %x\n", command);
			command = 0;
		}
		|
		NEWLINE
		|
		error { yyerrok; }
		;

	command:
		COMMAND
		{
			if(strcmp($1, "add") == 0)
				command = 0;
			else if(strcmp($1, "adc") == 0)
				command = 1;
			else if(strcmp($1, "adi") == 0)
				command = 2;
			else if(strcmp($1, "sub") == 0)
				command = 3;
			else if(strcmp($1, "sbb") == 0)
				command = 4;
			else if(strcmp($1, "sbi") == 0)
				command = 5;
			else if(strcmp($1, "xor") == 0)
				command = 6;
			else if(strcmp($1, "or") == 0)
				command = 7;
			else if(strcmp($1, "and") == 0)
				command = 8;
			else if(strcmp($1, "not") == 0)
				command = 9;
			else if(strcmp($1, "sll") == 0)
				command = 10;
			else if(strcmp($1, "slr") == 0)
				command = 11;
			else if(strcmp($1, "rar") == 0)
				command = 12;
			else if(strcmp($1, "loa") == 0)
				command = 13;
			else if(strcmp($1, "stp") == 0)
				command = 14;
			else if(strcmp($1, "sto") == 0)
				command = 15;
			else if(strcmp($1, "cmp") == 0)
				command = 16;
			else if(strcmp($1, "br") == 0)
				command = 17;
			else if(strcmp($1, "brz") == 0)
				command = 18;
			else if(strcmp($1, "bnz") == 0)
				command = 19;
			else if(strcmp($1, "nop") == 0)
				command = 30;
			else if(strcmp($1, "hlt") == 0)
				command = 31;
		}
		;
	
	args:
		args arg
		|
	;

	arg:
		REGISTER
		{
			int val = 0;
			if(strcmp($1, "r0") == 0)
				val = 0;
			else if(strcmp($1, "r1") == 0)
				val = 1;
			else if(strcmp($1, "r2") == 0)
				val = 2;
			else if(strcmp($1, "r3") == 0)
				val = 3;
			command = (command << 5) | val; 
		}
		|
		LABEL
		{	
			int labelVal;
			for(int i = 0; i < labels.size(); i++)
			{
				if((labels[i].name.c_str(), $1) == 0)
				{
					labelVal = labels[i].memoryLoc;
				}
			}
			command =  (command << 22) | labelVal;
		}
		|
		VALUE
		{
			command =  (command << 23) | $1;
		}
	;
%%

int main()
{
	yyparse();

	for(int i = 0; i < labels.size(); i++)
	{
		printf("Label: %s, Loc: %d\n", labels[i].name.c_str(), labels[i].memoryLoc);
	}
	return 0;
}
