%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

int identifierCount = 0;
int operatorCount = 0;
int expressionLength = 0;
char identifiers[100][100];
char operators[100];
char expression[100];

void appendToExpression(const char* text) {
    int len = strlen(text);
    strcat(expression, text);
    expressionLength += len;
}

bool isValidExpression(char* expression) {
    char stack[100];
    int top = -1;
    int identCount = 0;
    int operCount = 0;
    bool lastWasOperator = true;
    
    for(int i = 0; i < strlen(expression); i++) {
        char current = expression[i];
        
        if(current == '(' || current == '[' || current == '{') {
            stack[++top] = current;
        }
        else if(current == ')' || current == ']' || current == '}') {
            if(top == -1) {   
                return false;
            }
            if(stack[top] == '(' || stack[top] == '[' || stack[top] == '{') {
                top--;
            } else {
                return false;   
            }
        }
        
        else if((current >= 'a' && current <= 'z') || 
                (current >= 'A' && current <= 'Z') ||
                (current >= '0' && current <= '9')) {
            identCount++;
            lastWasOperator = false;
            
            while(i + 1 < strlen(expression) && 
                  ((expression[i+1] >= 'a' && expression[i+1] <= 'z') ||
                   (expression[i+1] >= 'A' && expression[i+1] <= 'Z') ||
                   (expression[i+1] >= '0' && expression[i+1] <= '9') ||
                   expression[i+1] == '_')) {
                i++;
            }
        }
        
        else if(current == '+' || current == '-' || 
                current == '*' || current == '/' || 
                current == '=') {
            if(lastWasOperator) { 
                return false;
            }
            operCount++;
            lastWasOperator = true;
        }
    }
    
    if(top != -1) {
        return false;
    }
    
    if(operCount > 0 && operCount != identCount - 1) {
        return false;
    }
    
    if(strlen(expression) > 0) {
        char first = expression[0];
        char last = expression[strlen(expression) - 1];
        if((first == '+' || first == '-' || first == '*' || first == '/' || first == '=') ||
           (last == '+' || last == '-' || last == '*' || last == '/' || last == '=')) {
            return false;
        }
    }
    
    return true;
}


%}

%%
[a-zA-Z_][a-zA-Z0-9_]* { 
    strcpy(identifiers[identifierCount++], yytext); 
    appendToExpression(yytext);
    printf("Identifier: %s\n", identifiers[identifierCount-1]); 
}

[0-9]+ { 
    strcpy(identifiers[identifierCount++], yytext); 
    appendToExpression(yytext);
    printf("Number: %s\n", identifiers[identifierCount-1]);
}

[+-/*=] { 
    operators[operatorCount++] = yytext[0]; 
    appendToExpression(yytext);
    printf("Operator: %c\n", operators[operatorCount-1]); 
}

[ \t\n] ;

. { 
    printf("character: %s\n", yytext);
    appendToExpression(yytext);
}

%%

int main() {
    expression[0] = '\0';
    
    printf("Enter an arithmetic expression: ");
    yylex();
    
    printf("\nComplete Expression: %s\n", expression);
    if(isValidExpression(expression)){
        printf("Valid Expression\n");
    } else {
        printf("Invalid Expression\n");
    }

    printf("\nTokens found:\n");
    printf("Identifiers/Numbers: ");
    for (int i = 0; i < identifierCount; i++) {
        printf("%s ", identifiers[i]);
    }
    
    printf("\nOperators: ");
    for (int i = 0; i < operatorCount; i++) {
        printf("%c ", operators[i]);
    }
    
    return 0;
}

int yywrap() {
    return 1;
}

void yyerror() {
    printf("Error\n");
    exit(1);
}