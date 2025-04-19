%{
#include "y.tab.h"
extern int yylineno;
%}

%%

[ \t]             ;
\n                { yylineno++; return '\n'; }
"the"|"a"|"an"|"The"|"A"|"An"   { return ARTICLE; }
"cat"|"dog"|"man"|"woman"|"book"|"table"|"animal"  { return NOUN; }
"runs"|"sleeps"|"reads"|"jumps"|"writes"|"is"  { return VERB; }
"big"|"small"|"quick"|"lazy"|"red"       { return ADJECTIVE; }
"and"|"but"|"or"  { return CONJUNCTION; }
"on"|"under"|"with" { return PREPOSITION; }
.                 { printf("Unrecognized word: %s\n", yytext); }
<<EOF>>           { return 0; }

%%

int yywrap() {
    return 1;
}