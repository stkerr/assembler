#include <stdio.h>
#include <string.h>
#include "y.tab.h"

char* usage =
"assembler input-file";

extern void yyparse();

int main(int argc, char* argv[])
{
	if(argc < 1 || strcmp(argv[1],"-h")==0 || 0==strcmp(argv[1],"--help"))
	{
		printf("%s\n", usage);
		return 1;
	}
	FILE* fp = (FILE*)fopen(argv[1], "r");
	yyparse();
	fclose(fp);
}
