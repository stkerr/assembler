%token NEWLINE 

%token <value> VALUE REGISTER
%token <string_val> WORD LABEL COMMAND NEWLABEL EXIT

%{
extern "C" int yylex();
extern "C" int yyerror(const char*);
#include <stdio.h>
#include <string>
#include <vector>
#include <signal.h>
#include <unistd.h>
#include <fcntl.h>

#define yylex yylex

struct dictionary {
	std::string name;
	int memoryLoc;
};


char *int2bin(unsigned int a)
{
		char *str,*tmp;
		int cnt = 31;
		str = (char *) malloc(33); /*32 + 1 , becoz its a 32 bit bin number*/
		tmp = str;
		while ( cnt > -1 )
		{
			str[cnt]= '0';
			cnt--;
		}
		cnt = 31;
		while (a > 0)
		{
            if (a%2==1)
			{
            	str[cnt] = '1';
			}
			cnt--;
			a = a/2 ;
		}
		return tmp;   
} 

std::vector<dictionary> labels;

int secondPassNeeded = 0;
int memLocation = 0, labelUsed = 0, commandType = 0;
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
		lines line
        |
        line		
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
			if(labelUsed == 1)
				command <<= 17;
			labelUsed = 0;

			char* temp = int2bin(command);
			printf("%s\n", temp);
			free(temp);

			printf("Command: %d\n", command);
			command = 0;
		}
		|
		NEWLINE
		;

	command:
		COMMAND
		{
			if(strcmp($1, "add") == 0)
			{	
				commandType = 1;
				command = 0;
			}
			else if(strcmp($1, "adc") == 0)
			{	
				commandType = 1;
				command = 1;
			}
			else if(strcmp($1, "adi") == 0)
			{	
				commandType = 1;
				command = 2;
			}
			else if(strcmp($1, "sub") == 0)
			{	
				commandType = 1;
				command = 3;
			}
			else if(strcmp($1, "sbb") == 0)
			{	
				commandType = 1;
				command = 4;
			}
			else if(strcmp($1, "sbi") == 0)
			{	
				commandType = 1;
				command = 5;
			}
			else if(strcmp($1, "xor") == 0)
			{	
				commandType = 1;
				command = 6;
			}
			else if(strcmp($1, "or") == 0)
			{	
				commandType = 1;
				command = 7;
			}
			else if(strcmp($1, "and") == 0)
			{	
				commandType = 1;
				command = 8;
			}
			else if(strcmp($1, "not") == 0)
			{	
				commandType = 1;
				command = 9;
			}
			else if(strcmp($1, "sll") == 0)
			{	
				commandType = 1;
				command = 10;
			}
			else if(strcmp($1, "slr") == 0)
			{	
				commandType = 1;
				command = 11;
			}
			else if(strcmp($1, "rar") == 0)
			{	
				commandType = 1;
				command = 12;
			}
			else if(strcmp($1, "loa") == 0)
			{	
				commandType = 2;
				command = 13;
            }
			else if(strcmp($1, "stp") == 0)
			{	
				commandType = 2;
				command = 14;
			}
            else if(strcmp($1, "sto") == 0)
			{	
				commandType = 2;
				command = 15;
			}
			else if(strcmp($1, "cmp") == 0)
			{	
				commandType = 2;
				command = 16;
			}
			else if(strcmp($1, "br") == 0)
			{	
				commandType = 2;
				command = 17;
			}
			else if(strcmp($1, "brz") == 0)
			{	
				commandType = 2;
				command = 18;
			}
			else if(strcmp($1, "bnz") == 0)
			{	
				commandType = 2;
				command = 19;
			}
			else if(strcmp($1, "nop") == 0)
			{	
				commandType = 3;
				command = 30;
			}
			else if(strcmp($1, "hlt") == 0)
			{	
				commandType = 3;
				command = 31;
			}
			else
			{
				printf("Invalid command: %s\n", $1);
				return 1;
			}
		}
        |
		error
        {
            printf("Invalid command!\n");
            return 1;
        }
	;
        
		;
	
	args:
		REGISTER REGISTER REGISTER // type 1
        {
            if(commandType != 1)
            {
                printf("Invalid arguments!\n");
                return 1;
            }
            command = (command << 3) | $1; // register 1
            command = (command << 3) | $2; // register 2
            command = (command << 3) | $3; // register 3
            command = (command << 18); // pad it
        }
        |
        REGISTER LABEL // type 2
        {
            if(commandType != 2)
            {
                printf("Invalid arguments!\n");
                return 1;
            }
            command = (command << 3) | $1; // register 1
            int value = -1;
            for(int i = 0; i < labels.size(); i++)
            {
                if(strcmp(labels[i].name.c_str(), $2) == 0) // found a match
                {
                    value = labels[i].memoryLoc;
                }
            }

            if(value < 0)
                secondPassNeeded = 1;
            else
                command = (command << 24) | value;
        }
        |
        REGISTER VALUE // type 2
        {
            if(commandType != 2)
            {
                printf("Invalid arguments!\n");
                return 1;
            }
            command = (command << 3) | $1;
            command = (command << 24) | $2;
        }
        |
        {
            if(commandType != 3)
            {
                printf("Invalid arguments!\n");
                return 1;
            }
            
            command = (command << 27);
        }
        |
		error
        {
            printf("Invalid arguments!\n");
            yyerrok;
        }
	;
%%

int main(int argc, char* argv[])
{

    if(argc < 1 || strcmp(argv[1],"-h")==0 || 0==strcmp(argv[1],"--help"))
	{
		//printf("%s\n", usage);
		return 1;
	}
    
    // redirect stdin to the file pointer
    int stdin = dup(0);
    close(0);
    
    // pass 1 on the file
    int fp = open(argv[1], O_RDONLY, "r");
    dup2(fp, 0);
	
    yyparse();
    
    lseek(fp, SEEK_SET, 0);
    
    // pass 2 on the file
    if(secondPassNeeded)
    {
        fp = open(argv[1], O_RDONLY, "r");
        dup2(fp, 0);
        
        yyparse();
 		secondPassNeeded = 0;       
    }
    
    close(fp);
        
    // restore stdin
    dup2(0, stdin);
    
    

	for(int i = 0; i < labels.size(); i++)
	{
		printf("Label: %s, Loc: %d\n", labels[i].name.c_str(), labels[i].memoryLoc);
	}
	return 0;
}
