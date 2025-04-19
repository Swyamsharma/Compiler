%{
#include <stdio.h>
#include <string.h>
FILE *Docfile;
%}

%%
\/\*\*([^*]|\*+[^*/]|\n)*\*\/ {
    for (int i = 3; i < strlen(yytext) - 2; i++) {
        if (yytext[i] == '*'||yytext[i]=='\t'||yytext[i]==' ') {
            continue;
        }
        else {
            fprintf(Docfile, "%c", yytext[i]);
        }
    }
    fprintf(Docfile, "\n");
}
\/\*.*\*\/  {}
\/\/.*                     {}
%%

int main() {
    yyout = fopen("output.java", "w");
    Docfile = fopen("Docfile.txt", "w");
    yylex();
    fclose(yyout);
    fclose(Docfile);
    return 0;
}

int yywrap() {
    return 1;
}
