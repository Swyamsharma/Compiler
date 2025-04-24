%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern FILE *yyin;
void yyerror(const char *s);

int a_count = 0;
int b_count = 0;
%}

%token T_A T_B T_NL

%start program

%% 

program:
       | program line
       | program last_line
       ;

line: sequence T_NL {
          if (a_count != b_count) {
              printf("Result: ACCEPT (a=%d, b=%d)\n", a_count, b_count);
          } else {
              printf("Result: REJECT (Counts mismatch: a=%d vs b=%d)\n", a_count, b_count);
          }
          a_count = 0;
          b_count = 0;
      }
    | T_NL {
          a_count = 0;
          b_count = 0;
      }
    ;
    
last_line: sequence {
             if (a_count != b_count) {
                 printf("Result: ACCEPT (a=%d, b=%d)\n", a_count, b_count);
             } else {
                 printf("Result: REJECT (Counts mismatch: a=%d vs b=%d)\n", a_count, b_count);
             }
           }
         ;

sequence: a_part b_part
        ;

a_part: 
      | a_part T_A { a_count++;}
      ;

b_part:
      | b_part T_B { b_count++; }
      ;

%%
void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error: %s\n", s);
}

int main(int argc, char **argv) {
    a_count = 0;
    b_count = 0;

    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror(argv[1]);
            return 1;
        }
        yyin = file;
    } else {
        printf("Reading from standard input (Ctrl+D/Ctrl+Z to end):\n");
        yyin = stdin;
    }

    yyparse(); 
    return 0;
}
