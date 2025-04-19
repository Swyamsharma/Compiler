%{
#include <stdio.h>
#include <string.h>

int operators_count = 0, operands_count = 0, valid = 1, top = -1, l = 0, j = 0;
char operands[10][10], operators[10][10], stack[100];
int last_was_operand = 0;
%}

%%
"("         { top++; stack[top] = '('; last_was_operand = 0; }
"{"         { top++; stack[top] = '{'; last_was_operand = 0; }
"["         { top++; stack[top] = '['; last_was_operand = 0; }
")"         { if (top >= 0 && stack[top] == '(') top--; else valid = 0; last_was_operand = 1; }
"}"         { if (top >= 0 && stack[top] == '{') top--; else valid = 0; last_was_operand = 1; }
"]"         { if (top >= 0 && stack[top] == '[') top--; else valid = 0; last_was_operand = 1; }

"+"|"-"|"*"|"/"|"=" {
                if (last_was_operand == 0 && yytext[0] != '(') {
                    valid = 0;
                    printf("Invalid: Operator '%s' found without preceding operand\n", yytext);
                }
                operators_count++;
                strcpy(operators[l], yytext);
                l++;
                last_was_operand = 0; 
              }

"-"[A-Za-z0-9]+|"+"[A-Za-z0-9]+ {
                if (last_was_operand) {
                   valid = 0;
                   printf("Invalid: Operand '%s' found directly after another operand\n", yytext);
                }
                operands_count++;
                strcpy(operands[j], yytext);
                j++;
                last_was_operand = 1;
              }

[0-9]+|[a-zA-Z][a-zA-Z0-9_]* {
                if (last_was_operand) {
                   valid = 0;
                   printf("Invalid: Operand '%s' found directly after another operand\n", yytext);
                }
                operands_count++;
                strcpy(operands[j], yytext);
                j++;
                last_was_operand = 1;
              }

[ \t\n]     ;
.           { valid = 0; printf("Invalid character: %s\n", yytext); } 

%%

int yywrap() { return 1; }

int main() {
    printf("Enter the arithmetic expression: ");
    yylex();

    if (valid == 1 && top == -1 && operands_count == operators_count + 1 && last_was_operand == 1) { 
        printf("\nValid Expression\n");
        printf("Operands: ");
        for (int k = 0; k < j; k++) {
            printf("%s ", operands[k]);
        }
        printf("\nOperators: ");
        for (int k = 0; k < l; k++) {
            printf("%s ", operators[k]);
        }
        printf("\n");

    } else {
        printf("\nInvalid Expression\n");
        if (top != -1) {
           printf("Unmatched parentheses\n");
        }
    }

    return 0;
}
