%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "common.h"

void yyerror(const char *s);
int yylex(void);
char *new_temp();
char *new_label();
void generate_code(const char *op, const char *arg1, const char *arg2, const char *result);

char current_token_text[256] = "";

int temp_count = 0;
int label_count = 0;

%}

%token <sval> IDENTIFIER NUMBER
%token INT FLOAT IF ELSE WHILE RETURN
%token LE GE EQ NE AND OR

%union {
    char *sval;
    ExprInfo expr;
    struct { char *truelist; char *falselist; char *nextlist; } stmt;
}

%type <expr> expression primary_expression assignment_expression logical_and_expression logical_or_expression equality_expression relational_expression additive_expression multiplicative_expression unary_expression
%type <stmt> statement expression_statement compound_statement selection_statement iteration_statement jump_statement M
%type <sval> type_specifier

%left OR
%left AND
%left EQ NE
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/' '%'
%right '!'
%nonassoc IFX
%nonassoc ELSE

%%

program: external_declaration_list ;

external_declaration_list: external_declaration_list external_declaration
                         |
                         ;

external_declaration: declaration
                    | function_definition
                    ;


declaration: type_specifier IDENTIFIER ';' { } ;

type_specifier: INT { $$ = "int"; } | FLOAT { $$ = "float"; } ;

function_definition: type_specifier IDENTIFIER '(' ')' compound_statement {
                        printf("Function Definition: %s %s()\n", $1, $2);
                        free($2);
                     }
                   ;


statement_list: statement_list statement | statement ;

statement: expression_statement
         | compound_statement
         | selection_statement { $$ = $1; }
         | iteration_statement { $$ = $1; }
         | jump_statement { $$ = $1; }
         | declaration /* Allow declarations as statements */
         ;

expression_statement: assignment_expression ';' { $$.truelist = NULL; $$.falselist = NULL; $$.nextlist = NULL; }
                    | ';' { $$.truelist = NULL; $$.falselist = NULL; $$.nextlist = NULL; }
                    ;

compound_statement: '{' statement_list '}' { $$.truelist = NULL; $$.falselist = NULL; $$.nextlist = NULL; }
                  | '{' '}' { $$.truelist = NULL; $$.falselist = NULL; $$.nextlist = NULL; }
                  ;

assignment_expression: IDENTIFIER '=' expression {
                         generate_code("=", $3.place, NULL, $1);
                         $$ = $3;
                         free($1);
                       }

                     ;


expression: logical_or_expression { $$ = $1; } ;

logical_or_expression: logical_or_expression OR logical_and_expression {
                           char *temp = new_temp();
                           generate_code("||", $1.place, $3.place, temp);
                           free($1.place); free($3.place);
                           $$.place = temp;
                       }
                     | logical_and_expression { $$ = $1; }
                     ;

logical_and_expression: logical_and_expression AND equality_expression {
                            char *temp = new_temp();
                            generate_code("&&", $1.place, $3.place, temp);
                            free($1.place); free($3.place);
                            $$.place = temp;
                        }
                      | equality_expression { $$ = $1; }
                      ;

equality_expression: equality_expression EQ relational_expression {
                         char *temp = new_temp();
                         generate_code("==", $1.place, $3.place, temp);
                         free($1.place); free($3.place);
                         $$.place = temp;
                     }
                   | equality_expression NE relational_expression {
                         char *temp = new_temp();
                         generate_code("!=", $1.place, $3.place, temp);
                         free($1.place); free($3.place);
                         $$.place = temp;
                     }
                   | relational_expression { $$ = $1; }
                   ;

relational_expression: relational_expression '<' additive_expression {
                           char *temp = new_temp();
                           generate_code("<", $1.place, $3.place, temp);
                           free($1.place); free($3.place);
                           $$.place = temp;
                       }
                     | relational_expression '>' additive_expression {
                           char *temp = new_temp();
                           generate_code(">", $1.place, $3.place, temp);
                           free($1.place); free($3.place);
                           $$.place = temp;
                       }
                     | relational_expression LE additive_expression {
                           char *temp = new_temp();
                           generate_code("<=", $1.place, $3.place, temp);
                           free($1.place); free($3.place);
                           $$.place = temp;
                       }
                     | relational_expression GE additive_expression {
                           char *temp = new_temp();
                           generate_code(">=", $1.place, $3.place, temp);
                           free($1.place); free($3.place);
                           $$.place = temp;
                       }
                     | additive_expression { $$ = $1; }
                     ;

additive_expression: additive_expression '+' multiplicative_expression {
                         char *temp = new_temp();
                         generate_code("+", $1.place, $3.place, temp);
                         free($1.place); free($3.place);
                         $$.place = temp;
                     }
                   | additive_expression '-' multiplicative_expression {
                         char *temp = new_temp();
                         generate_code("-", $1.place, $3.place, temp);
                         free($1.place); free($3.place);
                         $$.place = temp;
                     }
                   | multiplicative_expression { $$ = $1; }
                   ;

multiplicative_expression: multiplicative_expression '*' unary_expression {
                               char *temp = new_temp();
                               generate_code("*", $1.place, $3.place, temp);
                               free($1.place); free($3.place);
                               $$.place = temp;
                           }
                         | multiplicative_expression '/' unary_expression {
                               char *temp = new_temp();
                               generate_code("/", $1.place, $3.place, temp);
                               free($1.place); free($3.place);
                               $$.place = temp;
                           }
                         | multiplicative_expression '%' unary_expression { // Added modulo rule
                               char *temp = new_temp();
                               generate_code("%", $1.place, $3.place, temp);
                               free($1.place); free($3.place);
                               $$.place = temp;
                           }
                         | unary_expression { $$ = $1; }
                         ;

unary_expression: '-' primary_expression {
                      char *temp = new_temp();
                      generate_code("UMINUS", $2.place, NULL, temp);
                      free($2.place);
                      $$.place = temp;
                  }
                | '!' primary_expression {
                      char *temp = new_temp();
                      generate_code("!", $2.place, NULL, temp);
                      free($2.place);
                      $$.place = temp;
                  }
                | primary_expression { $$ = $1; }
                ;

primary_expression: IDENTIFIER { $$.place = $1; }
                  | NUMBER { $$.place = $1; }
                  | '(' expression ')' { $$ = $2; }
                  ;


selection_statement: IF '(' expression ')' M statement ELSE M statement {
                        char *label1 = $5.truelist;
                        char *label2 = $8.truelist;
                        char *label3 = new_label();

                        printf("%s:\n", label1);
                        generate_code("goto", label3, NULL, NULL);
                        printf("%s:\n", label2);
                        printf("%s:\n", label3);

                        free(label1); free(label2); free(label3);
                        free($3.place);
                     }
                   | IF '(' expression ')' M statement {
                        char *label1 = $5.truelist;
                        char *label2 = new_label();

                        printf("%s:\n", label1);
                        printf("%s:\n", label2);

                        free(label1); free(label2);
                        free($3.place);
                     } %prec IFX
                   ;

M: {
     char *label = new_label();
     $$.truelist = label;
   }
 ;


iteration_statement: M WHILE '(' expression ')' M statement {
                       char *label_check = $1.truelist;
                       char *label_body = $6.truelist;
                       char *label_after = new_label();

                       printf("%s:\n", label_check);
                       generate_code("if_false", $4.place, "goto", label_after);
                       printf("%s:\n", label_body);
                       generate_code("goto", label_check, NULL, NULL);
                       printf("%s:\n", label_after);

                       free(label_check); free(label_body); free(label_after);
                       free($4.place);
                   }
                   ;

jump_statement: RETURN expression ';' { generate_code("return", $2.place, NULL, NULL); free($2.place); $$.truelist = NULL; $$.falselist = NULL; $$.nextlist = NULL; }
              | RETURN ';' { generate_code("return", NULL, NULL, NULL); $$.truelist = NULL; $$.falselist = NULL; $$.nextlist = NULL; }
              ;


%%

char *new_temp() {
    char *temp = (char *)malloc(10 * sizeof(char));
    sprintf(temp, "t%d", temp_count++);
    return temp;
}
char *new_label() {
    char *label = (char *)malloc(10 * sizeof(char));
    sprintf(label, "L%d", label_count++);
    return label;
}

void generate_code(const char *op, const char *arg1, const char *arg2, const char *result) {
    if (strcmp(op, "=") == 0) {
        printf("%s = %s\n", result, arg1);
    } else if (strcmp(op, "+") == 0 || strcmp(op, "-") == 0 || strcmp(op, "*") == 0 || strcmp(op, "/") == 0 ||
               strcmp(op, "<") == 0 || strcmp(op, ">") == 0 || strcmp(op, "<=") == 0 || strcmp(op, ">=") == 0 ||
               strcmp(op, "==") == 0 || strcmp(op, "!=") == 0 || strcmp(op, "&&") == 0 || strcmp(op, "||") == 0 ||
               strcmp(op, "%") == 0) {
        printf("%s = %s %s %s\n", result, arg1, op, arg2);
    } else if (strcmp(op, "UMINUS") == 0) {
        printf("%s = -%s\n", result, arg1);
    } else if (strcmp(op, "!") == 0) {
         printf("%s = !%s\n", result, arg1);
    } else if (strcmp(op, "if_false") == 0) {
        printf("if_false %s %s %s\n", arg1, arg2, result);
    } else if (strcmp(op, "goto") == 0) {
        printf("goto %s\n", arg1);
    } else if (strcmp(op, "return") == 0) {
        if (arg1) {
            printf("return %s\n", arg1);
        } else {
            printf("return\n");
        }
    }
}

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error: %s near '%s'\n", s, current_token_text);
    exit(1);
}
extern FILE *yyin;

int main(int argc, char *argv[]) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror("Error opening file");
            return 1;
        }
        yyin = file;
    } else {
        printf("Reading from standard input.\n");
        yyin = stdin;
    }

    printf("--- Intermediate Code Generation ---\n");
    if (yyparse() == 0) {

    } else {
        printf("Parsing failed.\n");
    }
    printf("--- End of Intermediate Code ---\n");


    if (yyin != stdin) {
        fclose(yyin);
    }

    return 0;
}
