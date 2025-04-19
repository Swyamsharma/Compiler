#!/bin/bash

# Generate parser code from YACC file
yacc -d parser.y
echo "Generated y.tab.c and y.tab.h"

# Generate lexer code from Lex file
lex parser.l
echo "Generated lex.yy.c"

# Compile the generated C files and the main program logic
# -lfl is needed to link the flex library
gcc y.tab.c lex.yy.c -o codegen -lfl
echo "Compiled codegen executable"

echo "Compilation complete. Run with ./codegen <input_file.c>"
