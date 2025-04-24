/* resolved.l - Lexer for simple A/B/x grammar */
%{
#include "y.tab.h" // Use the new header name
#include <stdio.h>
%}

%%
[ \t]+          ; /* Ignore whitespace */
\n              { return T_EOL; } /* End of line/input */
a               { return T_A; }
x               { return T_X; }
.               { fprintf(stderr, "Lexer Error: Unknown character %c\n", *yytext); }
%%

int yywrap() {
    return 1; // Indicate no more files to read
}