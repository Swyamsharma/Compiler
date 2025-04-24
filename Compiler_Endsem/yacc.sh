#!/bin/bash

# Variables for filenames
lexfilename=""
yaccfilename=""
inputfile=""

# Parse command-line arguments
if [ -n "$1" ]; then
    lexfilename="$1"
else
    echo "Error: No Lex filename provided."
    echo "Usage: $0 <lexfilename.l> [yaccfilename.y] [input_file]"
    exit 1
fi

if [ -n "$2" ]; then
    yaccfilename="$2"
fi

if [ -n "$3" ]; then
    inputfile="$3"
fi

# Validate Lex file existence
if [ ! -f "$lexfilename" ]; then
    echo "Error: Lex file '$lexfilename' does not exist."
    exit 1
fi

# Compile Lex file
echo "Compiling Lex file: $lexfilename"
lex "$lexfilename"
if [ $? -ne 0 ]; then
    echo "Error: Lex compilation failed."
    exit 1
fi

# Compile Yacc file if provided
if [ -n "$yaccfilename" ]; then
    if [ ! -f "$yaccfilename" ]; then
        echo "Error: Yacc file '$yaccfilename' does not exist."
        exit 1
    fi
    echo "Compiling Yacc file: $yaccfilename"
    yacc -d "$yaccfilename"
    if [ $? -ne 0 ]; then
        echo "Error: Yacc compilation failed."
        exit 1
    fi
fi

# Determine output executable name (strip .l from lexfilename)
outputname="${lexfilename%.*}"

# Compile the generated C files into an executable
echo "Linking and compiling to create executable: $outputname"
if [ -n "$yaccfilename" ]; then
    gcc lex.yy.c y.tab.c -o "$outputname" -lm
else
    gcc lex.yy.c -o "$outputname" -lm # Also add -lm here for consistency, though not strictly needed for the current error
fi
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
rm -f lex.yy.c y.tab.c y.tab.h "$outputname" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Cleanup completed successfully."
else
    echo "Warning: Some temporary files could not be removed."
fi
