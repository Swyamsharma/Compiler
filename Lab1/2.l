%{
#include <stdio.h>
%}

%%
(run|eat|speak|write|jump|read|swim|sing|walk|laugh) { printf("Verb found: %s\n", yytext); }
[~]$ {exit(0);}
. {}
%%

int main(){
    printf("\n Enter the string: \n");
    yylex();
}

int yywrap(){
    return 1;
}