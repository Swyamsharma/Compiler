%{
    #include <stdio.h>
    #include "y.tab.h"
    extern int yylval;
%}

%%

[0-9]+          { yylval = atoi(yytext); return NUMBER; } 
[a-zA-Z]+       { yylval = atoi(yytext); return VARS; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULT; }
"/"             { return DIV; }
"="             { return EQUAL; }   
"("             { return '('; }
")"             { return ')'; }
";"             { return SEMICOLON; }
[ \t\n]         ;
.               { printf("Invalid character: %s\n", yytext); return 0; }

%%

int yywrap() {
    return 1;
}