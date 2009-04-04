%{
	#include "y.tab.h"
%}

DIGIT [0-9]
HDIGIT [0-9a-fA-F]

%%

[ \t]+ {

}

^EXIT$ {
	return EXIT;
}

^exit$ {
	return EXIT;
}

^[^ \t\n][^ \t\n]* {
		yylval.string_val = strdup(yytext);
		return COMMAND;
}

^[^ \t\n]+:$ {
		yylval.string_val = strdup(yytext);
		return NEWLABEL;
}

r[0-3] {
        char temp = strdup(yytext)[1];
        yylval.value = temp - '0';
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

[^ \t\n]+ {
		yylval.string_val = strdup(yytext);
		return LABEL;
}

\n {
	return NEWLINE;
}

%%
