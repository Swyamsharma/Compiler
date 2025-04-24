%{
#include "y.tab.h"
#include <string.h>
#include <ctype.h>

extern int meta_error_detected;

%}

%option noyywrap case-insensitive

ID      [a-zA-Z][a-zA-Z0-9_]*
NUMBER  [0-9]+(\.[0-9]+)?

%%
[ \t]+          ;
\n              { return T_EOL; }

"select"        { return T_SELECT; }
"from"          { return T_FROM; }
"where"         { return T_WHERE; }
"and"           { return T_AND; }

{ID}            { yylval.sval = strdup(yytext); return T_ID; }
{NUMBER}        { yylval.sval = strdup(yytext); return T_NUMBER; }

">="            { return T_GE; }
"="             { return T_EQ; }
"+"             { return T_PLUS; }
"-"             { return T_MINUS; }
"*"             { return T_MUL; }
"/"             { return T_DIV; }
"("             { return T_LPAREN; }
")"             { return T_RPAREN; }
","             { return T_COMMA; }

"'"             { meta_error_detected = 1; return T_META_ERROR; }
"--"            { meta_error_detected = 1; return T_META_ERROR; }
";"             { meta_error_detected = 1; return T_META_ERROR; }


.               {
                   return yytext[0];
                }
%%