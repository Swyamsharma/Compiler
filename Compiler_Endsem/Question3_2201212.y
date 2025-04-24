%{
#include <stdio.h>
#include <math.h>

extern int yylex();
void yyerror(const char *s);
extern FILE *yyin;

%}

%union {
    double dval;
}

%token <dval> NUM
%token REGULAR SIMPLE COMPOUND
%token LPAREN RPAREN COMMA

%type <dval> E

%start S

%%

S   :
    | S E { printf("Result: %f\n", $2); }
    ;

E   : NUM             { $$ = $1; }
    | REGULAR LPAREN E COMMA E RPAREN { $$ = $3 + ($3 * 2.01 / 100.0) * $5; }
    | SIMPLE LPAREN E COMMA E RPAREN  { $$ = $3 + ($3 * 5.5 * $5) / 100.0; }
    | COMPOUND LPAREN E COMMA E RPAREN {
        if ($5 == 0) {
            yyerror("Error: Division by zero in compound interest calculation (k cannot be 0)");
            YYERROR;
        }
        $$ = $3 * pow((1.0 + 5.7 / $5), $5);
      }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error: %s\n", s);
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror(argv[1]);
            return 1;
        }
    } else {
        printf("Enter expression (or provide input file):\n");
        yyin = stdin;
    }

    if (yyparse() == 0) {
        printf("Parsing completed successfully.\n");
    } else {
        printf("Parsing failed.\n");
    }

    if (yyin != stdin) {
        fclose(yyin);
    }

    return 0;
}
