%{    
#include <stdio.h>
%}

%%

"#"|"("|")" {printf("Token and Lexeme : %s\n", yytext);}
"Reverse"   {printf("Token : REVERSE; Lexeme : Reverse\n");}
\n          {printf("Token and Lexeme : <newline>\n");}
[a-z]+      {printf("Token : STRING; Lexeme : %s\n", yytext);}
[ \t]+        
.           {printf("Error");}
%%

int main() {
    yylex();
    return 0;
}

int yywrap() {
    return 1;
}
