%{    
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
struct tag{
    char name[10];
    int count;
};
struct tag tags[100];
%}

%%

"<"[^>]+">" {
        char name[100];
        int x = 0, y = 0;
        while (yytext[x] != ' ' && yytext[x] != '>') {
            if (yytext[x] != '<' && yytext[x] != '/') {
                name[y++] = yytext[x];
            }
            x++;
        }
        name[y] = '\0';
        int last = -1;
        for(int i=0; i< 100; i++){
            if(strcmp(name, tags[i].name) == 0 || strcmp(tags[i].name, "") == 0){
                last = i;
                break;
            }
        }
        strcpy(tags[last].name, name);
        if(!tags[last].count)
            tags[last].count = 1;
        else
            tags[last].count ++;
}

.|\n {}

%%

int main() {
    yylex();
    for (int i = 0; i < 100; i++) {
        if(strcmp(tags[i].name, "")!=0)
        printf("%s: %d\n", tags[i].name, tags[i].count);
    }
    return 0;
}

int yywrap() {
    return 1;
}
