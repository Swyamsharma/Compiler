#include <stdio.h>
#include <string.h>
#include <math.h>

typedef struct {
    double value;
    int error;
} SemanticValue;

SemanticValue parseBinary(char *input, int *pos);
SemanticValue parseInteger(char *input, int *pos);
SemanticValue parseFraction(char *input, int *pos);

int isBinaryDigit(char c) {
    return (c == '0' || c == '1');
}

SemanticValue parseBinary(char *input, int *pos) {
    SemanticValue result = {0.0, 0};
    SemanticValue intPart = {0.0, 0};
    SemanticValue fracPart = {0.0, 0};

    intPart = parseInteger(input, pos);

    if (intPart.error) {
        result.error = 1;
        return result;
    }

    result.value = intPart.value;

    if (input[*pos] == '.') {
        (*pos)++;
        fracPart = parseFraction(input, pos);
        
        if (fracPart.error) {
            result.error = 1;
            return result;
        }
        
        result.value += fracPart.value;
    }

    return result;
}

SemanticValue parseInteger(char *input, int *pos) {
    SemanticValue result = {0.0, 0};
    double value = 0.0;

    if (!isBinaryDigit(input[*pos])) {
        result.error = 1;
        return result;
    }

    while (isBinaryDigit(input[*pos])) {
        value = value * 2 + (input[*pos] - '0');
        (*pos)++;
    }

    result.value = value;
    return result;
}

SemanticValue parseFraction(char *input, int *pos) {
    SemanticValue result = {0.0, 0};
    double value = 0.0;
    double power = -1.0;

    while (isBinaryDigit(input[*pos])) {
        value += (input[*pos] - '0') * pow(2, power);
        power--;
        (*pos)++;
    }

    result.value = value;
    return result;
}

int main() {
    char input[100];
    printf("Enter a binary number (integer or floating-point, e.g., 101.11): ");
    fgets(input, sizeof(input), stdin);
    
    input[strcspn(input, "\n")] = 0;

    int pos = 0;
    SemanticValue result = parseBinary(input, &pos);

    if (result.error || input[pos] != '\0') {
        printf("Error: Invalid binary number format\n");
    } else {
        printf("Binary: %s\n", input);
        printf("Decimal: %.10f\n", result.value);
    }

    return 0;
}