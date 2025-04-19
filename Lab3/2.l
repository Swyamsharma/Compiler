%{
#include <stdio.h>
#include <string.h>
int identifier_count = 0;
char identifiers[100][100];char* keywords[] = {"int", "float", "char", "return", "if", "else", "while", "for", "void", "double""include","stdio.h"};
int keyword_count = 10;
%}

%%

"int"|"float"|"char"|"return"|"if"|"else"|"while"|"for"|"void"|"double"|"include"|"stdio.h" {}

[a-zA-Z_][a-zA-Z0-9_]* {
    int found = 0;
    for (int i = 0; i < keyword_count; i++) {
        if (strcmp(keywords[i], yytext) == 0) {
            found = 1;
            break;
        }
    }
    if (!found) {
        for (int i = 0; i < identifier_count; i++) {
            if (strcmp(identifiers[i], yytext) == 0) {
                found = 1;
                break;
            }
        }
    }
    if (!found) {
        strcpy(identifiers[identifier_count], yytext);
        identifier_count++;
        printf("%s ", yytext);
    }
}

[ \t\n]+ ;
. ;

%%

int yywrap() {
    return 1;
}

int main() {
    yylex();
    printf("Number of unique identifiers: %d\n", identifier_count);
    return 0;
}
