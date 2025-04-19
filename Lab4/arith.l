%{
    #include <stdio.h>
    #include "y.tab.h"
    extern int yylval ;
%}

%%

[0-9]+          { yylval = atoi(yytext); return NUMBER; } 
[a-zA-Z]+       { yylval = atoi(yytext); return VARS; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULT; }
"/"             { return DIV; }
[ \t\n]         ;
.               { return yytext[0]; }

%%

int yywrap() {
    return 1;
}