#include <stdio.h>
int main() {
    int var1 = 10;
    int var2 = var1 + 5;
    int var3;
    add(var1, var2);
    return var2;
}
int add(int var1, int var2){
    return var1 + var2;
}