%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
extern int yylex();
%}

%token NUMBER PLUS MINUS MULT DIV VARS SEMICOLON EQUAL

%left PLUS MINUS   
%left MULT DIV     
%left EQUAL        
%left '(' ')'

%%

program:
    expr SEMICOLON  { printf("Valid arithmetic expression\n"); return 0; }
    ;

expr:
    NUMBER     
    | VARS        
    | expr PLUS expr   
    | expr MINUS expr  
    | expr MULT expr   
    | expr DIV expr 
    | expr EQUAL expr 
    | '(' expr ')'     
    ;

%%

void yyerror(const char *s) {
    printf("Entered arithmetic expression is Invalid.\n");
}

int main() {
    printf("Enter an arithmetic expression ending with ';' (e.g., x = 5 + 3;):\n");
    yyparse();
    return 0;
}