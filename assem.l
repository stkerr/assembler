%{
	#include "y.tab.h"
%}

DIGIT [0-9]
HDIGIT [0-9a-fA-F]

%%

[ \t]+ {

}

^[^ \t\n][^ \t\n]* {
		yylval.string_val = strdup(yytext);
		return COMMAND;
}

r3[0-1] {
		yylval.string_val = strdup(yytext);
		return REGISTER;
}

r[1-2][0-9] {
		yylval.string_val = strdup(yytext);
		return REGISTER;
}

r[0-9] {
		yylval.string_val = strdup(yytext);
		return REGISTER;
}

[[:digit:]]+ {
		printf("Decimal %s\n", strdup(yytext));
		yylval.value = atoi(strdup(yytext));
		return VALUE;
}

0x[[:xdigit:]]+ {
		printf("Hex digit %s\n", strdup(yytext));
		yylval.value = strtol(strdup(yytext), 0, 16);
		return VALUE;
}

[^ \t\n][^ \t\n]* {
		yylval.string_val = strdup(yytext);
		return LABEL;
}

\n {
	return NEWLINE;
}

%%
