#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

void followFirst(char, int, int);
void findFirst(char, int, int);
void follow(char c);

int prodCount, firstCount = 0;
char firstSets[10][100];
char followSets[10][100];
int followCount = 0;
char productions[10][10], first[10];
char followTemp[10];
int prodIndex;
char currentSymbol;
int epsilonIndex;

int main(int argc, char **argv) {
    int firstMarker = 0;
    int followMarker = 0;
    int i, choice;
    char symbol, tempChar;

    printf("\nEnter the number of productions: ");
    scanf("%d", &prodCount);
    printf("\nEnter %d productions in the form A=B (A and B are grammar symbols):\n\n", prodCount);
    for (i = 0; i < prodCount; i++) {
        scanf("%s%c", productions[i], &tempChar);
    }

    int j;
    char processed[prodCount];
    int processedCount = -1;

    for (prodIndex = 0; prodIndex < prodCount; prodIndex++) {
        for (j = 0; j < 100; j++) {
            firstSets[prodIndex][j] = '!';
        }
    }
    int setIndex = 0, symbolIndex, isDuplicate;

    printf("\n+==================+\n");
    printf("|    FIRST Sets    |\n");
    printf("+==================+\n");
    for (prodIndex = 0; prodIndex < prodCount; prodIndex++) {
        symbol = productions[prodIndex][0];
        symbolIndex = 0;
        isDuplicate = 0;
        for (j = 0; j <= processedCount; j++)
            if (symbol == processed[j])
                isDuplicate = 1;
        if (isDuplicate == 1)
            continue;

        findFirst(symbol, 0, 0);
        processedCount += 1;
        processed[processedCount] = symbol;
        printf("| %-3c | { ", symbol);
        firstSets[setIndex][symbolIndex++] = symbol;
        for (i = 0 + firstMarker; i < firstCount; i++) {
            int exists = 0, check = 0;
            for (exists = 0; exists < symbolIndex; exists++) {
                if (first[i] == firstSets[setIndex][exists]) {
                    check = 1;
                    break;
                }
            }
            if (check == 0) {
                printf("%c", first[i]);
                if (i < firstCount - 1) printf(", ");
                firstSets[setIndex][symbolIndex++] = first[i];
            }
        }
        printf(" }\n");
        firstMarker = firstCount;
        setIndex++;
    }
    printf("+-----------------+\n");

    printf("\n+===================+\n");
    printf("|    FOLLOW Sets    |\n");
    printf("+===================+\n");
    char processedFollow[prodCount];
    processedCount = -1;
    for (prodIndex = 0; prodIndex < prodCount; prodIndex++) {
        for (j = 0; j < 100; j++) {
            followSets[prodIndex][j] = '!';
        }
    }
    setIndex = 0;
    int uniqueCount = 0;
    for (epsilonIndex = 0; epsilonIndex < prodCount; epsilonIndex++) {
        currentSymbol = productions[epsilonIndex][0];
        symbolIndex = 0;
        isDuplicate = 0;
        for (j = 0; j <= processedCount; j++)
            if (currentSymbol == processedFollow[j])
                isDuplicate = 1;
        if (isDuplicate == 1)
            continue;

        uniqueCount += 1;
        follow(currentSymbol);
        processedCount += 1;
        processedFollow[processedCount] = currentSymbol;
        printf("| %-3c | { ", currentSymbol);
        followSets[setIndex][symbolIndex++] = currentSymbol;
        for (i = 0 + followMarker; i < followCount; i++) {
            int exists = 0, check = 0;
            for (exists = 0; exists < symbolIndex; exists++) {
                if (followTemp[i] == followSets[setIndex][exists]) {
                    check = 1;
                    break;
                }
            }
            if (check == 0) {
                printf("%c", followTemp[i]);
                if (i < followCount - 1) printf(", ");
                followSets[setIndex][symbolIndex++] = followTemp[i];
            }
        }
        printf(" }\n");
        followMarker = followCount;
        setIndex++;
    }
    printf("+-----------------+\n");

    char terminals[10];
    for (prodIndex = 0; prodIndex < 10; prodIndex++) {
        terminals[prodIndex] = '!';
    }
    int termIndex, termCheck, termCount = 0;
    for (prodIndex = 0; prodIndex < prodCount; prodIndex++) {
        for (j = 0; j < prodCount; j++) {
            if (!isupper(productions[prodIndex][j]) && productions[prodIndex][j] != '#' && productions[prodIndex][j] != '=' && productions[prodIndex][j] != '\0') {
                termCheck = 0;
                for (termIndex = 0; termIndex < termCount; termIndex++) {
                    if (productions[prodIndex][j] == terminals[termIndex]) {
                        termCheck = 1;
                        break;
                    }
                }
                if (termCheck == 0) {
                    terminals[termCount] = productions[prodIndex][j];
                    termCount++;
                }
            }
        }
    }
    terminals[termCount] = '$';
    termCount++;

    printf("\n");
    printf("╔════════════════════════════════════╗\n");
    printf("║      LL(1) Parsing Table           ║\n");
    printf("╚════════════════════════════════════╝\n");
    printf("| %-10s ", "NT \\ T");
    for (termIndex = 0; termIndex < termCount; termIndex++) {
        printf("| %-10c ", terminals[termIndex]);
    }
    printf("|\n");
    printf("|------------");
    for (termIndex = 0; termIndex < termCount; termIndex++) {
        printf("|------------");
    }
    printf("|\n");

    char firstProd[prodCount][termCount];
    for (termIndex = 0; termIndex < prodCount; termIndex++) {
        int resultIndex = 0;
        prodIndex = 2;
        int tempCount = 0;
        char tempSymbols[100];
        while (productions[termIndex][prodIndex] != '\0') {
            if (!isupper(productions[termIndex][prodIndex])) {
                tempSymbols[tempCount++] = productions[termIndex][prodIndex];
                tempSymbols[tempCount++] = '_';
                tempSymbols[tempCount++] = '\0';
                prodIndex++;
                break;
            } else {
                int setFound = 0, symbolPos = 0;
                for (setFound = 0; setFound < prodCount; setFound++) {
                    if (firstSets[setFound][0] == productions[termIndex][prodIndex]) {
                        for (symbolPos = 1; symbolPos < 100; symbolPos++) {
                            if (firstSets[setFound][symbolPos] != '!') {
                                tempSymbols[tempCount++] = firstSets[setFound][symbolPos];
                            } else {
                                break;
                            }
                        }
                        break;
                    }
                }
                tempSymbols[tempCount++] = '_';
            }
            prodIndex++;
        }
        int setFound = 0, symbolPos;
        for (symbolPos = 0; symbolPos < tempCount; symbolPos++) {
            if (tempSymbols[symbolPos] == '#') {
                setFound = 1;
            } else if (tempSymbols[symbolPos] == '_') {
                if (setFound == 1) {
                    setFound = 0;
                } else {
                    break;
                }
            } else {
                firstProd[termIndex][resultIndex++] = tempSymbols[symbolPos];
            }
        }
    }

    char parseTable[uniqueCount][termCount + 1];
    processedCount = -1;
    for (termIndex = 0; termIndex < uniqueCount; termIndex++) {
        for (j = 0; j < (termCount + 1); j++) {
            parseTable[termIndex][j] = '!';
        }
    }

    for (termIndex = 0; termIndex < prodCount; termIndex++) {
        currentSymbol = productions[termIndex][0];
        isDuplicate = 0;
        for (j = 0; j <= processedCount; j++)
            if (currentSymbol == parseTable[j][0])
                isDuplicate = 1;
        if (isDuplicate == 1)
            continue;
        processedCount = processedCount + 1;
        parseTable[processedCount][0] = currentSymbol;
    }

    for (termIndex = 0; termIndex < prodCount; termIndex++) {
        int symbolPos = 0;
        while (firstProd[termIndex][symbolPos] != '\0') {
            int termMatch, found = 0;
            for (termMatch = 0; termMatch < termCount; termMatch++) {
                if (firstProd[termIndex][symbolPos] == terminals[termMatch]) {
                    found = 1;
                }
            }
            if (found == 1) {
                char nonTerminal = productions[termIndex][0];
                int row = 0;
                while (parseTable[row][0] != nonTerminal) {
                    row = row + 1;
                }
                int col = 0;
                while (terminals[col] != firstProd[termIndex][symbolPos]) {
                    col = col + 1;
                }
                parseTable[row][col + 1] = (char)(termIndex + 65);
            }
            symbolPos++;
        }
    }

    for (prodIndex = 0; prodIndex < termCount; prodIndex++) {
        for (j = 0; j < 100; j++) {
            if (firstSets[prodIndex][j] == '!') {
                break;
            } else if (firstSets[prodIndex][j] == '#') {
                int followPos = 1;
                while (followSets[prodIndex][followPos] != '!') {
                    char nonTerminal = productions[prodIndex][0];
                    int row = 0;
                    while (parseTable[row][0] != nonTerminal) {
                        row = row + 1;
                    }
                    int col = 0;
                    while (terminals[col] != followSets[prodIndex][followPos]) {
                        col = col + 1;
                    }
                    parseTable[prodIndex][col + 1] = '#';
                    followPos++;
                }
                break;
            }
        }
    }
    for (termIndex = 0; termIndex < uniqueCount; termIndex++) {
        printf("| %-10c ", parseTable[termIndex][0]);
        for (j = 1; j < (termCount + 1); j++) {
            if (parseTable[termIndex][j] == '!') {
                printf("| %-10s ", "");
            } else if (parseTable[termIndex][j] == '#') {
                printf("| %-10s ", "ε");
            } else {
                int prodNum = (int)(parseTable[termIndex][j]);
                prodNum -= 65;
                printf("| %-10s ", productions[prodNum]);
            }
        }
        printf("|\n");
    }
    printf("|------------");
    for (int i = 0; i < termCount; i++) {
        printf("|------------");
    }
    printf("|\n");

    // Parse input string
    printf("\nEnter the desired input string (end with $): ");
    char input[100];
    scanf("%s%c", input, &tempChar);

    printf("\n+--------------------------------------------+\n");
    printf("| Stack         | Input         | Action      |\n");
    printf("+--------------------------------------------+\n");

    int inputPos = 0, stackPos = 1;
    char stack[100];
    stack[0] = '$';
    stack[1] = parseTable[0][0];

    while (stackPos != -1) {
        printf("| %-13.*s| %-13s| ", stackPos + 1, stack, &input[inputPos]);
        char currentInput = input[inputPos];
        char topSymbol = stack[stackPos];
        stackPos--;

        if (!isupper(topSymbol)) {
            if (currentInput == topSymbol) {
                inputPos++;
                printf("Pop %-9c|\n", topSymbol);
            } else {
                printf("Reject         |\n");
                break;
            }
        } else {
            int i;
            for (i = 0; i < termCount; i++) {
                if (terminals[i] == currentInput)
                    break;
            }
            char productionStr[100];
            for (int j = 0; j < uniqueCount; j++) {
                if (topSymbol == parseTable[j][0]) {
                    if (parseTable[j][i + 1] == '#') {
                        printf("%c -> ε       |\n", parseTable[j][0]);
                        productionStr[0] = '#';
                        productionStr[1] = '\0';
                    } else if (parseTable[j][i + 1] != '!') {
                        int prodNum = (int)(parseTable[j][i + 1]);
                        prodNum -= 65;
                        strcpy(productionStr, productions[prodNum]);
                        printf("%-14s|\n", productionStr);
                    } else {
                        printf("Reject         |\n");
                        goto end;
                    }
                }
            }
            int length = strlen(productionStr);
            length = length - 1;
            if (length == 0) {
                continue;
            }
            for (int j = length; j >= 2; j--) {
                stackPos++;
                stack[stackPos] = productionStr[j];
            }
        }
    }

end:
    printf("+--------------------------------------------+\n");
    if (input[inputPos] == '\0') {
        printf("|        String Accepted Successfully        |\n");
    } else {
        printf("|        String Rejected by Parser           |\n");
    }
    printf("+--------------------------------------------+\n");

    return 0;
}

void follow(char c) {
    int i, j;
    if (productions[0][0] == c) {
        followTemp[followCount++] = '$';
    }
    for (i = 0; i < 10; i++) {
        for (j = 2; j < 10; j++) {
            if (productions[i][j] == c) {
                if (productions[i][j + 1] != '\0') {
                    followFirst(productions[i][j + 1], i, (j + 2));
                }
                if (productions[i][j + 1] == '\0' && c != productions[i][0]) {
                    follow(productions[i][0]);
                }
            }
        }
    }
}

void findFirst(char c, int prodPos, int symbolPos) {
    int j;
    if (!(isupper(c))) {
        first[firstCount++] = c;
    }
    for (j = 0; j < prodCount; j++) {
        if (productions[j][0] == c) {
            if (productions[j][2] == '#') {
                if (productions[prodPos][symbolPos] == '\0')
                    first[firstCount++] = '#';
                else if (productions[prodPos][symbolPos] != '\0' && (prodPos != 0 || symbolPos != 0))
                    findFirst(productions[prodPos][symbolPos], prodPos, (symbolPos + 1));
                else
                    first[firstCount++] = '#';
            } else if (!isupper(productions[j][2])) {
                first[firstCount++] = productions[j][2];
            } else {
                findFirst(productions[j][2], j, 3);
            }
        }
    }
}

void followFirst(char c, int prodIndex, int pos) {
    int k;
    if (!(isupper(c)))
        followTemp[followCount++] = c;
    else {
        int i = 0, j = 1;
        for (i = 0; i < prodCount; i++) {
            if (firstSets[i][0] == c)
                break;
        }
        while (firstSets[i][j] != '!') {
            if (firstSets[i][j] != '#') {
                followTemp[followCount++] = firstSets[i][j];
            } else {
                if (productions[prodIndex][pos] == '\0') {
                    follow(productions[prodIndex][0]);
                } else {
                    followFirst(productions[prodIndex][pos], prodIndex, pos + 1);
                }
            }
            j++;
        }
    }
}