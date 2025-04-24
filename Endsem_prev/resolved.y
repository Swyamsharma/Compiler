%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern char *yytext;
extern FILE *yyin;
void yyerror(const char *s);

%}

%token T_A T_X T_EOL
%left T_X

%start line

%%

line:    A T_EOL { printf("Parse Successful (Conflict Resolved).\n"); return 0; }
       | error T_EOL { fprintf(stderr, "Parse Error near end of line.\n"); return 1;}
       ;

A:       B        { printf("Reduced B to A (Rule A -> B)\n"); }
       | B T_X    { printf("Reduced B T_X to A (Rule A -> B 'x')\n"); }
       ;

B:       T_A      { printf("Reduced T_A to B (Rule B -> 'a')\n"); }
       ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "YACC Syntax Error: %s near '%s'\n", s, yytext);
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror(argv[1]);
            return 1;
        }
    } else {
        printf("Reading from standard input.\n");
        yyin = stdin;
    }

    if (yyparse() == 0) {
       return 0;
    } else {
       fprintf(stderr, "Parsing failed.\n");
       return 1;
    }
}