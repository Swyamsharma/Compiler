%{
#include "y.tab.h"
extern int yylineno;
%}

%%

[ \t]             ;
\n                { yylineno++; return '\n'; }
"SELECT"          { return SELECT; }
"FROM"            { return FROM; }
"WHERE"           { return WHERE; }
"INSERT"          { return INSERT; }
"INTO"            { return INTO; }
"VALUES"          { return VALUES; }
"UPDATE"          { return UPDATE; }
"SET"             { return SET; }
"ORDER"           { return ORDER; }
"BY"              { return BY; }
">"|"<"|"="       { return COMPARISON; }
[a-zA-Z][a-zA-Z0-9_]* { return ID; }
[0-9]+            { return NUMBER; }
\"[^\"]*\"        { return STRING; }
","               { return ','; }
"("               { return '('; }
")"               { return ')'; }
.                 { printf("Unexpected character: %s\n", yytext); }
<<EOF>>           { return 0; }

%%

int yywrap() {
    return 1;
}