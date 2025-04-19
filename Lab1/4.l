%{
#include<stdio.h>
int lc=0,sc=0,ch=0,wc=0;
%}

%%
[\n] { lc++;}
[ \t] { sc++;}
[a-zA-Z0-9]+ { wc++; ch += yyleng; }
[~]$ {exit(0);}
. {}
%%

int yywrap(){ return 1; }
int main(){
	yylex();
	printf("Number of lines : %d\n",lc);
	printf("Number of spaces : %d\n",sc);
	printf("Number of words, charc : %d , %d\n",wc,ch);
	
	return 0;
}
