%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
extern int yylex();
%}

%token NUMBER PLUS MINUS MULT DIV VARS

%left PLUS MINUS   
%left MULT DIV     
%left '(' ')'

%%

program:
    expr '\n'    { printf("Valid arithmetic expression\n"); return 0; }
    | expr       { printf("Valid arithmetic expression\n"); return 0; }
    ;

expr:
    NUMBER     
    | VARS        
    | expr PLUS expr   
    | expr MINUS expr  
    | expr MULT expr   
    | expr DIV expr 
    |   '('expr')' 
    ;

%%

void yyerror(const char *s) {
    printf("Entered arithmetic expression is Invalid.\n");
}

int main() {
    printf("Enter an arithmetic expression (e.g., 3 + 5 * 2):\n");
    yyparse();
    return 0;
}