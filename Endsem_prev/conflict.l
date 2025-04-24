%{
#include "y.tab.h"
#include <stdio.h>
%}

%%
[ \t]+          ;
\n              { return T_EOL; }
a               { return T_A; }
x               { return T_X; }
.               { fprintf(stderr, "Lexer Error: Unknown character %c\n", *yytext); }
%%

int yywrap() {
    return 1;
}