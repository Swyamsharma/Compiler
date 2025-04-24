%{
#include <stdio.h>
#include "y.tab.h"
%}

%%
[ \t\n]+          ;
a                {return T_A; }
b                {return T_B; }
c                {return T_C; }
d                {return T_D; }
.                { fprintf(stderr, "Lexer Error: Invalid character '%c'\n", *yytext);}
%%

int yywrap() {
    return 1;
}