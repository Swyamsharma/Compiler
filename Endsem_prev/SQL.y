%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern char *yytext;
extern FILE *yyin;
void yyerror(const char *s);

int meta_error_detected = 0;
int parse_error_occurred = 0;

%}
%union {
        char *sval;
    }

%token <sval> T_ID T_NUMBER

%token T_SELECT T_FROM T_WHERE T_AND
%token T_STAR
%token T_EQ T_GE
%token T_PLUS T_MINUS T_MUL T_DIV
%token T_LPAREN T_RPAREN T_COMMA
%token T_EOL
%token T_META_ERROR

%left T_PLUS T_MINUS
%left T_MUL T_DIV
%nonassoc T_UMINUS

%start sql_statement

%%

sql_statement   : T_SELECT select_list T_FROM table_list where_clause_opt T_EOL
                  {
                      if (!parse_error_occurred) {
                          printf("SQL select statement consist by correct arithmetic expression .\n");
                      }
                      return 0;
                  }
                | error T_EOL
                  {
                     return 1;
                  }
                ;

select_list     : T_STAR
                | column_list
                ;

column_list     : T_ID
                | column_list T_COMMA T_ID
                ;

table_list      : T_ID
                | table_list T_COMMA T_ID
                ;

where_clause_opt:
                | T_WHERE condition_list 
                ;

condition_list  : condition
                | condition_list T_AND condition
                ;

condition       : arith_expr comparison_op arith_expr
                ;

comparison_op   : T_EQ
                | T_GE
                ;

arith_expr      : term
                | arith_expr T_PLUS term
                | arith_expr T_MINUS term
                ;

term            : factor
                | term T_MUL factor
                | term T_DIV factor
                ;

factor          : primary
                | T_MINUS factor %prec T_UMINUS
                | T_PLUS factor
                ;

primary         : T_ID
                | T_NUMBER
                | T_LPAREN arith_expr T_RPAREN
                ;

%%
void yyerror(const char *s) {
    if (parse_error_occurred) return;
    parse_error_occurred = 1;

    if (meta_error_detected) {
         fprintf(stderr, "SQL select statement is incorrect or consists by incorrect arithmetic expression.\n");
         fprintf(stderr, "(Reason: Detected meta-character like ', --, or ;)\n");
    } else {
         fprintf(stderr, "SQL select statement is incorrect or consists by incorrect arithmetic expression.\n");
         fprintf(stderr, "(Reason: Syntax error near '%s' or invalid arithmetic structure)\n", yytext ? yytext : "<end of input>");
    }
}
int main() {
    printf("Enter SQL SELECT statement (end with newline):\n");
    meta_error_detected = 0;
    parse_error_occurred = 0;
    if (yyparse() == 0 && !parse_error_occurred) {
    } else {
        fprintf(stderr, "Parsing failed.\n");
    }
    return 0;
}