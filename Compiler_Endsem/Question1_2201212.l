%{
#include <stdio.h>
#include "y.tab.h" 
extern YYSTYPE yylval; 
%}
/* 
Grammar being used:
E -> E + E
E -> E * E 
E -> i
*/
%%
[0-9]+      { yylval.ival = atoi(yytext); return T_ID; }
"+"         { return '+'; }
"*"         { return '*'; }
\n          { return T_EOL; }
[ \t]+      {}
.           { fprintf(stderr, "Lexer Error: Unexpected character %s\n", yytext); }
%%

int yywrap() {
    return 1;
}
