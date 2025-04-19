#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#define MAX_STATES 20
#define MAX_SYMBOLS 10
#define MAX_PRODUCTIONS 10
#define MAX_INPUT 50

typedef struct {
    char name;
    char type[20];
} Token;

typedef struct {
    char lhs;
    char rhs[10];
    int rhsLength;
} Production;

typedef enum {
    ACTION_NONE,
    ACTION_SHIFT,
    ACTION_REDUCE,
    ACTION_ACCEPT,
    ACTION_ERROR
} ActionType;

typedef struct {
    ActionType type;
    int value;
} TableCell;

typedef struct {
    TableCell action[MAX_STATES][MAX_SYMBOLS];
    int goTo[MAX_STATES][MAX_SYMBOLS];
} ParseTable;

Token tokenList[MAX_INPUT];
char inputText[MAX_INPUT], parseStack[MAX_INPUT], displayText[MAX_INPUT];
int stateStack[MAX_INPUT];
int inputLength = 0, stackPointer = 0;
Production grammar[MAX_PRODUCTIONS];
int numProductions = 0;
ParseTable parseTable;

typedef enum {
    SYMBOL_TERMINAL,
    SYMBOL_NONTERMINAL
} SymbolType;

typedef struct {
    char symbol;
    SymbolType type;
    int index;
} SymbolInfo;

SymbolInfo symbols[] = {
    {'+', SYMBOL_TERMINAL, 0},
    {'-', SYMBOL_TERMINAL, 1},
    {'*', SYMBOL_TERMINAL, 2},
    {'/', SYMBOL_TERMINAL, 3},
    {'%', SYMBOL_TERMINAL, 4},
    {'i', SYMBOL_TERMINAL, 5},
    {'n', SYMBOL_TERMINAL, 6},
    {'$', SYMBOL_TERMINAL, 7},
    {'E', SYMBOL_NONTERMINAL, 0}
};
int numSymbols = 9;

void initializeGrammar();
void initializeParseTable();
void tokenizeInput();
void performParsing();
void displayParseTable();
void stackPush(char, int);
void stackPop(int);
int getSymbolIndex(char, SymbolType);
char getTokenSymbol(char);

int main() {
    printf("╔═══════════════════════════════════════╗\n");
    printf("║       Bottom-Up Parser Implementation ║\n");
    printf("╚═══════════════════════════════════════╝\n\n");
    printf("Supported Grammar Rules:\n");
    printf("  E = E + E\n");
    printf("  E = E - E\n");
    printf("  E = E * E\n");
    printf("  E = E / E\n");
    printf("  E = E %% E\n");
    printf("  E = identifier | number\n\n");
    
    initializeGrammar();
    initializeParseTable();
    
    tokenizeInput();
    performParsing();
    
    return 0;
}

void initializeGrammar() {
    // Production 0: E = E + E
    grammar[0].lhs = 'E';
    strcpy(grammar[0].rhs, "E+E");
    grammar[0].rhsLength = 3;
    
    // Production 1: E = E - E
    grammar[1].lhs = 'E';
    strcpy(grammar[1].rhs, "E-E");
    grammar[1].rhsLength = 3;
    
    // Production 2: E = E * E
    grammar[2].lhs = 'E';
    strcpy(grammar[2].rhs, "E*E");
    grammar[2].rhsLength = 3;
    
    // Production 3: E = E / E
    grammar[3].lhs = 'E';
    strcpy(grammar[3].rhs, "E/E");
    grammar[3].rhsLength = 3;
    
    // Production 4: E = E % E
    grammar[4].lhs = 'E';
    strcpy(grammar[4].rhs, "E%E");
    grammar[4].rhsLength = 3;
    
    // Production 5: E = i (identifier)
    grammar[5].lhs = 'E';
    strcpy(grammar[5].rhs, "i");
    grammar[5].rhsLength = 1;
    
    // Production 6: E = n (number)
    grammar[6].lhs = 'E';
    strcpy(grammar[6].rhs, "n");
    grammar[6].rhsLength = 1;
    
    numProductions = 7;
}
int getSymbolIndex(char sym, SymbolType type) {
    for (int i = 0; i < numSymbols; i++) {
        if (symbols[i].symbol == sym && symbols[i].type == type) {
            if (type == SYMBOL_TERMINAL) {
                return symbols[i].index;
            } else {
                return symbols[i].index;
            }
        }
    }
    return -1;
}
char getTokenSymbol(char token) {
    if (isalpha(token) && token != 'E') return 'i';
    if (isdigit(token)) return 'n';
    return token;
}
void initializeParseTable() {
    for (int i = 0; i < MAX_STATES; i++) {
        for (int j = 0; j < MAX_SYMBOLS; j++) {
            parseTable.action[i][j].type = ACTION_ERROR;
            parseTable.goTo[i][j] = -1;
        }
    }
    // State 0
    parseTable.action[0][5].type = ACTION_SHIFT;
    parseTable.action[0][5].value = 3;
    parseTable.action[0][6].type = ACTION_SHIFT;
    parseTable.action[0][6].value = 4;
    parseTable.goTo[0][0] = 1;
    
    // State 1
    parseTable.action[1][0].type = ACTION_SHIFT;
    parseTable.action[1][0].value = 5;
    parseTable.action[1][1].type = ACTION_SHIFT;
    parseTable.action[1][1].value = 6;
    parseTable.action[1][2].type = ACTION_SHIFT;
    parseTable.action[1][2].value = 7;
    parseTable.action[1][3].type = ACTION_SHIFT;
    parseTable.action[1][3].value = 8;
    parseTable.action[1][4].type = ACTION_SHIFT;
    parseTable.action[1][4].value = 9;
    parseTable.action[1][7].type = ACTION_ACCEPT;
    
    // State 3 (after identifier)
    parseTable.action[3][0].type = ACTION_REDUCE;
    parseTable.action[3][0].value = 5;
    parseTable.action[3][1].type = ACTION_REDUCE;
    parseTable.action[3][1].value = 5;
    parseTable.action[3][2].type = ACTION_REDUCE;
    parseTable.action[3][2].value = 5;
    parseTable.action[3][3].type = ACTION_REDUCE;
    parseTable.action[3][3].value = 5;
    parseTable.action[3][4].type = ACTION_REDUCE;
    parseTable.action[3][4].value = 5;
    parseTable.action[3][7].type = ACTION_REDUCE;
    parseTable.action[3][7].value = 5;
    
    // State 4 (after number)
    parseTable.action[4][0].type = ACTION_REDUCE;
    parseTable.action[4][0].value = 6;
    parseTable.action[4][1].type = ACTION_REDUCE;
    parseTable.action[4][1].value = 6;
    parseTable.action[4][2].type = ACTION_REDUCE;
    parseTable.action[4][2].value = 6;
    parseTable.action[4][3].type = ACTION_REDUCE;
    parseTable.action[4][3].value = 6;
    parseTable.action[4][4].type = ACTION_REDUCE;
    parseTable.action[4][4].value = 6;
    parseTable.action[4][7].type = ACTION_REDUCE;
    parseTable.action[4][7].value = 6;
    
    // State 5 (after E+)
    parseTable.action[5][5].type = ACTION_SHIFT;
    parseTable.action[5][5].value = 3;
    parseTable.action[5][6].type = ACTION_SHIFT;
    parseTable.action[5][6].value = 4;
    parseTable.goTo[5][0] = 10;
    
    // State 6 (after E-)
    parseTable.action[6][5].type = ACTION_SHIFT;
    parseTable.action[6][5].value = 3;
    parseTable.action[6][6].type = ACTION_SHIFT;
    parseTable.action[6][6].value = 4;
    parseTable.goTo[6][0] = 11;
    
    // State 7 (after E*)
    parseTable.action[7][5].type = ACTION_SHIFT;
    parseTable.action[7][5].value = 3;
    parseTable.action[7][6].type = ACTION_SHIFT;
    parseTable.action[7][6].value = 4;
    parseTable.goTo[7][0] = 12;
    
    // State 8 (after E/)
    parseTable.action[8][5].type = ACTION_SHIFT;
    parseTable.action[8][5].value = 3;
    parseTable.action[8][6].type = ACTION_SHIFT;
    parseTable.action[8][6].value = 4;
    parseTable.goTo[8][0] = 13;
    
    // State 9 (after E%)
    parseTable.action[9][5].type = ACTION_SHIFT;
    parseTable.action[9][5].value = 3;
    parseTable.action[9][6].type = ACTION_SHIFT;
    parseTable.action[9][6].value = 4;
    parseTable.goTo[9][0] = 14;
    
    // State 10 (after E+E)
    parseTable.action[10][0].type = ACTION_REDUCE;
    parseTable.action[10][0].value = 0;
    parseTable.action[10][1].type = ACTION_REDUCE;
    parseTable.action[10][1].value = 0;
    parseTable.action[10][2].type = ACTION_SHIFT; 
    parseTable.action[10][2].value = 7;
    parseTable.action[10][3].type = ACTION_SHIFT;
    parseTable.action[10][3].value = 8;
    parseTable.action[10][4].type = ACTION_SHIFT;
    parseTable.action[10][4].value = 9;
    parseTable.action[10][7].type = ACTION_REDUCE;
    parseTable.action[10][7].value = 0;
    
    // State 11 (after E-E)
    parseTable.action[11][0].type = ACTION_REDUCE;
    parseTable.action[11][0].value = 1;
    parseTable.action[11][1].type = ACTION_REDUCE;
    parseTable.action[11][1].value = 1;
    parseTable.action[11][2].type = ACTION_SHIFT; 
    parseTable.action[11][2].value = 7;
    parseTable.action[11][3].type = ACTION_SHIFT; 
    parseTable.action[11][3].value = 8;
    parseTable.action[11][4].type = ACTION_SHIFT; 
    parseTable.action[11][4].value = 9;
    parseTable.action[11][7].type = ACTION_REDUCE;
    parseTable.action[11][7].value = 1;
    
    // State 12 (after E*E)
    parseTable.action[12][0].type = ACTION_REDUCE;
    parseTable.action[12][0].value = 2;
    parseTable.action[12][1].type = ACTION_REDUCE;
    parseTable.action[12][1].value = 2;
    parseTable.action[12][2].type = ACTION_REDUCE;
    parseTable.action[12][2].value = 2;
    parseTable.action[12][3].type = ACTION_REDUCE;
    parseTable.action[12][3].value = 2;
    parseTable.action[12][4].type = ACTION_REDUCE;
    parseTable.action[12][4].value = 2;
    parseTable.action[12][7].type = ACTION_REDUCE;
    parseTable.action[12][7].value = 2;
    
    // State 13 (after E/E)
    parseTable.action[13][0].type = ACTION_REDUCE;
    parseTable.action[13][0].value = 3;
    parseTable.action[13][1].type = ACTION_REDUCE;
    parseTable.action[13][1].value = 3;
    parseTable.action[13][2].type = ACTION_REDUCE;
    parseTable.action[13][2].value = 3;
    parseTable.action[13][3].type = ACTION_REDUCE;
    parseTable.action[13][3].value = 3;
    parseTable.action[13][4].type = ACTION_REDUCE;
    parseTable.action[13][4].value = 3;
    parseTable.action[13][7].type = ACTION_REDUCE;
    parseTable.action[13][7].value = 3;
    
    // State 14 (after E%E)
    parseTable.action[14][0].type = ACTION_REDUCE;
    parseTable.action[14][0].value = 4;
    parseTable.action[14][1].type = ACTION_REDUCE;
    parseTable.action[14][1].value = 4;
    parseTable.action[14][2].type = ACTION_REDUCE;
    parseTable.action[14][2].value = 4;
    parseTable.action[14][3].type = ACTION_REDUCE;
    parseTable.action[14][3].value = 4;
    parseTable.action[14][4].type = ACTION_REDUCE;
    parseTable.action[14][4].value = 4;
    parseTable.action[14][7].type = ACTION_REDUCE;
    parseTable.action[14][7].value = 4;
}



void tokenizeInput() {
    int position = -1, typeCheckIndex;
    char operators[] = {'+', '-', '*', '/', '%'};
    
    printf("Enter expression (end with $): ");
    do {
        position += 1;
        scanf(" %c", &inputText[position]);
    } while(inputText[position] != '$');

    inputLength = strlen(inputText);
    printf("\nExpression: ");
    for (int i = 0; i < inputLength; i++) {
        printf("%c ", inputText[i]);
    }
    printf("\n");

    int processed[inputLength];
    memset(processed, 0, sizeof(processed));
    
    for (int i = 0; i < inputLength; i++) {
        if (processed[i]) continue;
        
        int isOperator = 0;
        for (typeCheckIndex = 0; typeCheckIndex < 15; typeCheckIndex++) {
            if (inputText[i] == operators[typeCheckIndex]) {
                tokenList[i].name = inputText[i];
                strcpy(tokenList[i].type, "Operator");
                processed[i] = 1;
                isOperator = 1;
                break;
            }
        }
        
        if (!isOperator) {
            if (inputText[i] == '$') {
                tokenList[i].name = '$';
                strcpy(tokenList[i].type, "EndMarker");
                processed[i] = 1;
            } else if (isdigit(inputText[i])) {
                tokenList[i].name = inputText[i];
                strcpy(tokenList[i].type, "Number");
                processed[i] = 1;
            } else {
                tokenList[i].name = inputText[i];
                strcpy(tokenList[i].type, "Identifier");
                processed[i] = 1;
            }
        }
    }
}

void performParsing() {
    printf("\nPARSING STEPS\n");
    printf("----------------------------------------------------------\n");
    printf("      STACK       |     INPUT BUFFER   |       ACTION      \n");
    printf("----------------------------------------------------------\n");
    stackPointer = 0;
    stackPush('$', 0);
    strcpy(displayText, inputText);
    int currentPos = 0;
    printf(" [$,0]            | %-18s | ---               \n", displayText);
    while (1) {
        char currentSymbol = getTokenSymbol(inputText[currentPos]);
        int currentState = stateStack[stackPointer-1];
        int symbolIndex = getSymbolIndex(currentSymbol, SYMBOL_TERMINAL);
        TableCell action = parseTable.action[currentState][symbolIndex];
        
        switch (action.type) {
            case ACTION_SHIFT:
            
                stackPush(currentSymbol, action.value);
                
                displayText[currentPos] = ' ';
                currentPos++;
                
                printf(" %-16s | %-18s | SHIFT %-12d \n", 
                       parseStack, displayText, action.value);
                break;
            case ACTION_REDUCE:
                Production prod = grammar[action.value];
                for (int i = 0; i < prod.rhsLength; i++) {
                    stackPop(1);
                }
                currentState = stateStack[stackPointer-1];
                int gotoState = parseTable.goTo[currentState][getSymbolIndex(prod.lhs, SYMBOL_NONTERMINAL)];
                stackPush(prod.lhs, gotoState);
                printf(" %-16s | %-18s | REDUCE %-10d \n", 
                       parseStack, displayText, action.value);
                break;
                
            case ACTION_ACCEPT:
                printf(" %-16s | %-18s | ACCEPT            \n", 
                       parseStack, displayText);
                printf("----------------------------------------------------------\n");
                printf(" Input string accepted according to the grammar!\n");
                printf("----------------------------------------------------------\n");
                return;
                
            case ACTION_ERROR:
                printf(" %-16s | %-18s | ERROR             \n", 
                       parseStack, displayText);
                printf("----------------------------------------------------------\n");
                printf(" Input string rejected! Does not conform to grammar.\n");
                printf("----------------------------------------------------------\n");
                return;
            default:
                printf(" Unknown action encountered!\n");
                return;
        }
    }
}
void stackPush(char symbol, int state) {
    if (stackPointer >= MAX_INPUT) {
        printf("Stack overflow error\n");
        exit(1);
    }
    parseStack[stackPointer] = symbol;
    stateStack[stackPointer] = state;
    stackPointer++;
    char stackDisplay[MAX_INPUT*4] = "[";
    for (int i = 0; i < stackPointer; i++) {
        char buffer[10];
        sprintf(buffer, "%c,%d", parseStack[i], stateStack[i]);
        strcat(stackDisplay, buffer);
        if (i < stackPointer-1) strcat(stackDisplay, " ");
    }
    strcat(stackDisplay, "]");
}

void stackPop(int count) {
    if (stackPointer - count < 0) {
        printf("Stack underflow error\n");
        exit(1);
    }
    stackPointer -= count;
}