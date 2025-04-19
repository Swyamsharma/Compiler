%{
#include <stdio.h>
#include <stdlib.h>
int yylex();
void yyerror(char *s);
extern int yylineno;
extern FILE *yyin;
%}

%token SELECT FROM WHERE INSERT INTO VALUES UPDATE SET ORDER BY
%token ID NUMBER STRING COMPARISON

%%

input:
                                {}
    | input sql_statement '\n'  { printf("Valid SQL query accepted\n"); }
    | input error '\n'         { yyerrok; }
    ;

sql_statement:
    select_statement
    | insert_statement
    | update_statement
    ;

select_statement:
    SELECT column_list FROM ID where_clause order_clause
    | SELECT column_list FROM ID where_clause
    | SELECT column_list FROM ID
    ;

column_list:
    ID
    | column_list ',' ID
    ;

where_clause:
    WHERE condition
    ;

condition:
    ID COMPARISON NUMBER
    | ID COMPARISON STRING
    ;

order_clause:
    ORDER BY ID
    ;

insert_statement:
    INSERT INTO ID '(' column_list ')' VALUES '(' value_list ')'
    ;

value_list:
    literal
    | value_list ',' literal
    ;

literal:
    NUMBER
    | STRING
    ;

update_statement:
    UPDATE ID SET ID COMPARISON literal where_clause
    | UPDATE ID SET ID COMPARISON literal
    ;

%%

void yyerror(char *s) {
    fprintf(stderr, "Error: %s at line %d\n", s, yylineno);
}

int main() {
    yyin = stdin;
    printf("Enter SQL query (one per line, Ctrl+D to exit):\n");
    int result = yyparse();
    return result;
}