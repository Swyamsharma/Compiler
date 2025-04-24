%{
#include <stdio.h>
#include "y.tab.h"
%}

%%
[ \t]+           ;
\n               { return T_NL; }
a                { return T_A; }
b                { return T_B; }
.                { fprintf(stderr, "Lexer Error: Invalid character '%c'\n", *yytext); }
%%

int yywrap() {
    return 1;
}
