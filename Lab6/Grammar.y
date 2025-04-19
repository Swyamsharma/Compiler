%{
#include <stdio.h>
#include <stdlib.h>
int yylex();
void yyerror(char *s);
extern int yylineno;
extern FILE *yyin;
%}

%token ARTICLE NOUN VERB ADJECTIVE CONJUNCTION PREPOSITION

%%

input:
    
    | input sentence '\n'  { printf("Valid English sentence accepted\n"); }
    | input error '\n'     { yyerrok; }
    ;

sentence:
    simple_sentence
    | compound_sentence
    ;

simple_sentence:
    subject verb
    | subject verb object
    | subject verb PREPOSITION phrase
    ;

subject:
    ARTICLE NOUN
    | NOUN
    | ADJECTIVE NOUN
    | ARTICLE ADJECTIVE NOUN
    ;

verb:
    VERB
    ;

object:
    ARTICLE NOUN
    | ADJECTIVE NOUN
    | ARTICLE ADJECTIVE NOUN
    ;

phrase:
    ARTICLE NOUN
    | ADJECTIVE NOUN
    | ARTICLE ADJECTIVE NOUN
    ;

compound_sentence:
    simple_sentence CONJUNCTION simple_sentence
    ;

%%

void yyerror(char *s) {
    fprintf(stderr, "Error: %s at line %d\n", s, yylineno);
}

int main() {
    yyin = stdin;
    printf("Enter English sentence (one per line, Ctrl+D to exit):\n");
    int result = yyparse();
    if (result == 0) {
        printf("Parsing completed successfully\n");
    } else {
        printf("Parsing ended with status %d (EOF or error)\n", result);
    }
    return result;
}