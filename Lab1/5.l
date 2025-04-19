%{ 
#include<stdio.h> 
%} 
%% 
([0-2][1-9]|[3][0-1])\/((0(1|3|5|7|8))|(10|12))\/([1-2][0-9][0-9][-0-9]) {printf("valid date: %s\n", yytext);} 

([0-2][1-9]|30)\/((0(4|6|9))|11)\/([1-2][0-9][0-9][0-9]) {printf("valid date: %s\n", yytext);} 

([0-1][1-9]|2[0-8])\/02\/([1-2][0-9][0-9][0-9]) {printf("valid date: %s\n", yytext);} 

29\/02\/([1-2][0-9][0-9][0-9]) { 
    int i=0, yr=0; 
    while(yytext[i]!='/')i++; i++; 
    while(yytext[i]!='/')i++;i++;
    while(i<yyleng)yr=(10*yr)+(yytext[i++]-'0');
    if(yr%4==0||(yr%100==0&&yr%400!=0)) 
    printf("valid date: %s\n", yytext); 
    else printf("invalid date: %s\n", yytext);} 

[\t\n]+ {}
[\n] {}
[~]$ {exit(0);}
[0-9\/]+[0-9] {printf("invalid date: %s\n", yytext);}
. {printf("Incorrect format\n");}
%% 

int main() 
{ 
    yylex(); 
} 
int yywrap() 
{ 
    return 1; 
} 
