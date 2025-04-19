#!/bin/bash

filename=""
run_with_input=""

if [ -n "$1" ]; then
    filename="$1"
fi

if [ -n "$2" ]; then
    run_with_input="$2"
fi

if [ -z "$filename" ]; then
    echo "Error: No filename provided."
    echo "Usage: $0 <filename.l> [input_file]"
    exit 1
fi

lex "$filename"
gcc -o "${filename%.*}" lex.yy.c 

if [ -n "$run_with_input" ]; then
    echo "Running ${filename%.*} with input $run_with_input"
    echo "----------------------------------------"
    ./"${filename%.*}" < "$run_with_input"
    echo "----------------------------------------"
else
    echo "Running ${filename%.*}"
    ./"${filename%.*}"
    echo "----------------------------------------"
fi

rm -f "${filename}.lex.c" "${filename%.*}" "$filename%}"
rm -f lex.yy.c