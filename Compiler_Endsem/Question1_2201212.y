%{
#include <stdio.h>
int yylex(void);
void yyerror(const char *s);
%}

%union {
    int ival;
}
/* 
Grammar being used:
E -> E + E
E -> E * E 
E -> i
*/
%token <ival> T_ID
%token T_EOL

/* %left '+'
%left '*' */

%type <ival> expr

%%

line: expr T_EOL { printf("Result: %d\n", $1); }
    | error T_EOL {  }
    ;

expr: T_ID          { $$ = $1; }
    | expr '+' expr { $$ = $1 + $3; }
    | expr '*' expr { $$ = $1 * $3; }
    ;

%%

void yyerror(const char *s) {
}

int main() {
    if (yyparse() == 0) {
        printf("Parsing successful.\n");
    } else {
        printf("Parsing failed.\n");
    }
    return 0;
}
