%{
#include "common.h"
#include "y.tab.h"
#include <stdlib.h>
#include <string.h>

extern char current_token_text[256];
void yyerror(const char *s);
%}

%x COMMENT

digit       [0-9]
letter      [a-zA-Z_]
identifier  {letter}({letter}|{digit})*
number      {digit}+(\.{digit}+)?(E[+-]?{digit}+)?

%%

"int"       { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return INT; }
"float"     { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return FLOAT; }
"if"        { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return IF; }
"else"      { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return ELSE; }
"while"     { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return WHILE; }
"return"    { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return RETURN; }

{identifier} { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; yylval.sval = strdup(yytext); return IDENTIFIER; }
{number}    { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; yylval.sval = strdup(yytext); return NUMBER; }

"+"         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return '+'; }
"-"         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return '-'; }
"*"         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return '*'; }
"/"         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return '/'; }
"%"         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return '%'; }
"="         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return '='; }
"<"         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return '<'; }
">"         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return '>'; }
"<="        { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return LE; }
">="        { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return GE; }
"=="        { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return EQ; }
"!="        { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return NE; }
"&&"        { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return AND; }
"||"        { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return OR; }
"!"         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return '!'; }

";"         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return ';'; }
","         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return ','; }
"("         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return '('; }
")"         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return ')'; }
"{"         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return '{'; }
"}"         { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; return '}'; }

"/*"        { BEGIN(COMMENT); }
<COMMENT>"*/" { BEGIN(INITIAL); }
<COMMENT>.|\n { }

"//".*      ;
^#[^\n]*    ;

[ \t\n]+    ;
.           { strncpy(current_token_text, yytext, 255); current_token_text[255] = '\0'; fprintf(stderr, "Warning: Unrecognized character '%s'\n", yytext); }

%%

int yywrap() {
    return 1;
}
