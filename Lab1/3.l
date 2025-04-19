%{
#include <stdio.h>
%}

%%
[a-z] { printf("Small letter: %s\n", yytext); }
[~]$ {exit(0);}
. {}
%%

int main(){
    yylex();
}

int yywrap(){
    return 1;
}