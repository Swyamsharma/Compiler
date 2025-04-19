%{
#include<stdio.h>
%}

%%
[ \t\n]+(a|an|the)+[ \t\n]|^(A|An|The)[ \t\n]+         { printf("Article found: %s\n", yytext); }
[~]$ {exit(0);}
.            {}
%%

int main(){
    printf("\n Enter the string: \n");
    yylex();
}

int yywrap(){
    return 1;
}