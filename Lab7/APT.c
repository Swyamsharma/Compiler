#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define MAX_EXPR 100

typedef enum {
    NUMBER,
    PLUS,
    MINUS,
    MULTIPLY,
    DIVIDE,
    LPAREN,
    RPAREN,
    END
} TokenType;

typedef enum {
    PT_EXPR,
    PT_TERM,
    PT_FACTOR,
    PT_NUMBER,
    PT_OPERATOR,
    PT_LPAREN,
    PT_RPAREN
} ParseNodeType;

typedef struct {
    TokenType type;
    int value;
} Token;

typedef struct ParseNode {
    ParseNodeType type;
    int value;
    char op;
    struct ParseNode* left;
    struct ParseNode* right;
    struct ParseNode* middle;
} ParseNode;

typedef struct ASTNode {
    TokenType type;
    int value;
    struct ASTNode* left;
    struct ASTNode* right;
} ASTNode;

char input[MAX_EXPR];
int pos = 0;
Token currentToken;

Token getNextToken();
ParseNode* createParseNode(ParseNodeType type, int value, char op);
ASTNode* createASTNode(TokenType type, int value);
ParseNode* expression();
ParseNode* term();
ParseNode* factor();
ASTNode* buildAST(ParseNode* parseNode);
void printParseTree(ParseNode* node, int level, char* branch);
void printAST(ASTNode* node, int level, char* branch);
int evaluate(ASTNode* node);
void freeParseTree(ParseNode* node);
void freeAST(ASTNode* node);

Token getNextToken() {
    while (input[pos] == ' ') pos++;
    
    Token token;
    if (isdigit(input[pos])) {
        token.type = NUMBER;
        token.value = 0;
        while (isdigit(input[pos])) {
            token.value = token.value * 10 + (input[pos] - '0');
            pos++;
        }
    } else if (input[pos] == '+') { token.type = PLUS; pos++; }
    else if (input[pos] == '-') { token.type = MINUS; pos++; }
    else if (input[pos] == '*') { token.type = MULTIPLY; pos++; }
    else if (input[pos] == '/') { token.type = DIVIDE; pos++; }
    else if (input[pos] == '(') { token.type = LPAREN; pos++; }
    else if (input[pos] == ')') { token.type = RPAREN; pos++; }
    else { token.type = END; }
    return token;
}

ParseNode* createParseNode(ParseNodeType type, int value, char op) {
    ParseNode* node = (ParseNode*)malloc(sizeof(ParseNode));
    node->type = type;
    node->value = value;
    node->op = op;
    node->left = node->right = node->middle = NULL;
    return node;
}

ASTNode* createASTNode(TokenType type, int value) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = type;
    node->value = value;
    node->left = node->right = NULL;
    return node;
}

ParseNode* factor() {
    ParseNode* node;
    if (currentToken.type == NUMBER) {
        node = createParseNode(PT_FACTOR, 0, 0);
        node->left = createParseNode(PT_NUMBER, currentToken.value, 0);
        currentToken = getNextToken();
    } else if (currentToken.type == LPAREN) {
        node = createParseNode(PT_FACTOR, 0, 0);
        node->left = createParseNode(PT_LPAREN, 0, '(');
        currentToken = getNextToken();
        node->middle = expression();
        if (currentToken.type == RPAREN) {
            node->right = createParseNode(PT_RPAREN, 0, ')');
            currentToken = getNextToken();
        }
    }
    return node;
}

ParseNode* term() {
    ParseNode* node = createParseNode(PT_TERM, 0, 0);
    node->left = factor();
    
    while (currentToken.type == MULTIPLY || currentToken.type == DIVIDE) {
        ParseNode* opNode = createParseNode(PT_TERM, 0, 0);
        opNode->left = node;
        opNode->middle = createParseNode(PT_OPERATOR, 0, 
            currentToken.type == MULTIPLY ? '*' : '/');
        currentToken = getNextToken();
        opNode->right = factor();
        node = opNode;
    }
    return node;
}

ParseNode* expression() {
    ParseNode* node = createParseNode(PT_EXPR, 0, 0);
    node->left = term();
    
    while (currentToken.type == PLUS || currentToken.type == MINUS) {
        ParseNode* opNode = createParseNode(PT_EXPR, 0, 0);
        opNode->left = node;
        opNode->middle = createParseNode(PT_OPERATOR, 0, 
            currentToken.type == PLUS ? '+' : '-');
        currentToken = getNextToken();
        opNode->right = term();
        node = opNode;
    }
    return node;
}

ASTNode* buildAST(ParseNode* parseNode) {
    if (!parseNode) return NULL;
    
    if (parseNode->type == PT_NUMBER) {
        return createASTNode(NUMBER, parseNode->value);
    }
    
    if (parseNode->type == PT_FACTOR) {
        if (parseNode->left->type == PT_NUMBER) {
            return createASTNode(NUMBER, parseNode->left->value);
        }
        return buildAST(parseNode->middle);
    }
    
    if (parseNode->type == PT_TERM || parseNode->type == PT_EXPR) {
        if (!parseNode->middle) return buildAST(parseNode->left);
        
        ASTNode* node = createASTNode(
            parseNode->middle->op == '+' ? PLUS :
            parseNode->middle->op == '-' ? MINUS :
            parseNode->middle->op == '*' ? MULTIPLY : DIVIDE,
            0
        );
        node->left = buildAST(parseNode->left);
        node->right = buildAST(parseNode->right);
        return node;
    }
    return NULL;
}

void printParseTree(ParseNode* node, int level, char* branch) {
    if (!node) return;
    
    for (int i = 0; i < level; i++) printf("│   ");
    printf("%s── ", branch);
    
    if (node->type == PT_EXPR) printf("Expression\n");
    else if (node->type == PT_TERM) printf("Term\n");
    else if (node->type == PT_FACTOR) printf("Factor\n");
    else if (node->type == PT_NUMBER) printf("Number: %d\n", node->value);
    else if (node->type == PT_OPERATOR) printf("Operator: %c\n", node->op);
    else if (node->type == PT_LPAREN) printf("Open Parenthesis: (\n");
    else if (node->type == PT_RPAREN) printf("Close Parenthesis: )\n");
    
    printParseTree(node->left, level + 1, "├");
    printParseTree(node->middle, level + 1, "├");
    printParseTree(node->right, level + 1, "└");
}

void printAST(ASTNode* node, int level, char* branch) {
    if (!node) return;
    
    for (int i = 0; i < level; i++) printf("│   ");
    printf("%s── ", branch);
    
    if (node->type == NUMBER) printf("Number: %d\n", node->value);
    else if (node->type == PLUS) printf("Operator: +\n");
    else if (node->type == MINUS) printf("Operator: -\n");
    else if (node->type == MULTIPLY) printf("Operator: *\n");
    else if (node->type == DIVIDE) printf("Operator: /\n");
    
    printAST(node->left, level + 1, "├");
    printAST(node->right, level + 1, "└");
}

int evaluate(ASTNode* node) {
    if (!node) return 0;
    
    if (node->type == NUMBER) return node->value;
    if (node->type == PLUS) return evaluate(node->left) + evaluate(node->right);
    if (node->type == MINUS) return evaluate(node->left) - evaluate(node->right);
    if (node->type == MULTIPLY) return evaluate(node->left) * evaluate(node->right);
    if (node->type == DIVIDE) {
        int right = evaluate(node->right);
        if (right == 0) { printf("Error: Division by zero\n"); return 0; }
        return evaluate(node->left) / right;
    }
    return 0;
}

void freeParseTree(ParseNode* node) {
    if (!node) return;
    freeParseTree(node->left);
    freeParseTree(node->middle);
    freeParseTree(node->right);
    free(node);
}

void freeAST(ASTNode* node) {
    if (!node) return;
    freeAST(node->left);
    freeAST(node->right);
    free(node);
}

int main() {
    printf("Enter an arithmetic expression: ");
    fgets(input, MAX_EXPR, stdin);
    input[strcspn(input, "\n")] = 0;
    
    printf("\nInput expression: %s\n", input);
    
    pos = 0;
    currentToken = getNextToken();
    ParseNode* parseRoot = expression();
    ASTNode* astRoot = buildAST(parseRoot);
    
    printf("\n--- Parse Tree ---\n");
    printParseTree(parseRoot, 0, "──");
    
    printf("\n--- Abstract Syntax Tree ---\n");
    printAST(astRoot, 0, "──");
    
    printf("\n--- Evaluation ---\n");
    printf("Result: %d\n", evaluate(astRoot));
    
    freeParseTree(parseRoot);
    freeAST(astRoot);
    return 0;
}