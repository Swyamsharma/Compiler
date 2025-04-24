%{
#include "y.tab.h"
#include <math.h>
%}

%%
[0-9]+              { yylval.dval = atof(yytext); return NUM; }
"regular"           { return REGULAR; }
"simple"            { return SIMPLE; }
"compound"          { return COMPOUND; }
"("                 { return LPAREN; }
")"                 { return RPAREN; }
","                 { return COMMA; }
[ \t\n]+            ;
.                   { fprintf(stderr, "Error: Invalid character '%s'\n", yytext); }
%%

int yywrap() {
    return 1;
}
