/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    T_ID = 258,                    /* T_ID  */
    T_NUMBER = 259,                /* T_NUMBER  */
    T_SELECT = 260,                /* T_SELECT  */
    T_FROM = 261,                  /* T_FROM  */
    T_WHERE = 262,                 /* T_WHERE  */
    T_AND = 263,                   /* T_AND  */
    T_STAR = 264,                  /* T_STAR  */
    T_EQ = 265,                    /* T_EQ  */
    T_GE = 266,                    /* T_GE  */
    T_PLUS = 267,                  /* T_PLUS  */
    T_MINUS = 268,                 /* T_MINUS  */
    T_MUL = 269,                   /* T_MUL  */
    T_DIV = 270,                   /* T_DIV  */
    T_LPAREN = 271,                /* T_LPAREN  */
    T_RPAREN = 272,                /* T_RPAREN  */
    T_COMMA = 273,                 /* T_COMMA  */
    T_EOL = 274,                   /* T_EOL  */
    T_UMINUS = 275                 /* T_UMINUS  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif
/* Token kinds.  */
#define YYEMPTY -2
#define YYEOF 0
#define YYerror 256
#define YYUNDEF 257
#define T_ID 258
#define T_NUMBER 259
#define T_SELECT 260
#define T_FROM 261
#define T_WHERE 262
#define T_AND 263
#define T_STAR 264
#define T_EQ 265
#define T_GE 266
#define T_PLUS 267
#define T_MINUS 268
#define T_MUL 269
#define T_DIV 270
#define T_LPAREN 271
#define T_RPAREN 272
#define T_COMMA 273
#define T_EOL 274
#define T_UMINUS 275

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 22 "SQL.y"

        char *sval; // For storing strings like identifiers and numbers
    

#line 112 "y.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
