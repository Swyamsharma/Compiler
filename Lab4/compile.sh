#!/bin/bash

# Fixed filenames for Lex and C source
lexfilename="lexer.l"
cfile="parser.c"
outputname="parser"
inputfile=""

# Parse optional input file argument
if [ -n "$1" ]; then
    inputfile="$1"
fi

# Validate file existence
if [ ! -f "$lexfilename" ]; then
    echo "Error: Lex file '$lexfilename' does not exist."
    exit 1
fi
if [ ! -f "$cfile" ]; then
    echo "Error: C file '$cfile' does not exist."
    exit 1
fi

# Compile Lex file
echo "Compiling Lex file: $lexfilename"
lex "$lexfilename"
if [ $? -ne 0 ]; then
    echo "Error: Lex compilation failed."
    exit 1
fi

# Compile the generated C file and parser.c into executable
echo "Linking and compiling to create executable: $outputname"
gcc -o "$outputname" "$cfile" lex.yy.c
if [ $? -ne 0 ]; then
    echo "Error: GCC compilation failed."
    exit 1
fi

# Run the executable
if [ -n "$inputfile" ]; then
    if [ ! -f "$inputfile" ]; then
        echo "Error: Input file '$inputfile' does not exist."
        exit 1
    fi
    echo "Running $outputname with input from $inputfile"
    echo "----------------------------------------"
    ./"$outputname" < "$inputfile"
    echo "----------------------------------------"
else
    echo "Running $outputname without input"
    echo "----------------------------------------"
    ./"$outputname"
    echo "----------------------------------------"
fi

# Clean up temporary files
echo "Cleaning up temporary files"
rm -f lex.yy.c "$outputname" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Cleanup completed successfully."
else
    echo "Warning: Some temporary files could not be removed."
fi