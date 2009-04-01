%{
	#include "y.tab.h"
%}

%%

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

[^ \t\n][^ \t\n]* {
		yylval.string_val = strdup(yytext);
		return LABEL;
}

\n {
	return NEWLINE;
}

%%
