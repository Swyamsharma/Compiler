#ifndef COMMON_H
#define COMMON_H

// Structure to hold information about expressions (result variable)
typedef struct {
    char *place;
} ExprInfo;

// We could also put token definitions here if needed,
// but y.tab.h usually handles that.

#endif // COMMON_H
