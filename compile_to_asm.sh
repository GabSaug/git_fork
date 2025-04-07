#!/bin/bash

set -e

# Input arguments
SRC_FILE="$1"       # e.g., path/to/sparse-index.c
OUT_FILE="$2"       # e.g., sparse-index.s
opt="$3"    # e.g., -O2 -Wall
EXTRA_FLAGS="$(echo $3 | sed -e "s/-O0/$(cat /etc/gcc.opt)/g") -fno-dce -fno-tree-dce -fno-inline -Wno-error -finline-limit=2"

# Ensure inputs are provided
if [ -z "$SRC_FILE" ] || [ -z "$OUT_FILE" ]; then
    echo "Usage: $0 <source_file.c> <output_file.s> [extra_compilation_flags]"
    exit 1
fi

# Get object file name from source
SRC_BASENAME=$(basename "$SRC_FILE")                   # e.g., sparse-index.c
OBJ_NAME="${SRC_BASENAME%.c}.o"                        # e.g., sparse-index.o

# Clean the object file if it exists
[ -f "$OBJ_NAME" ] && rm "$OBJ_NAME"

# Try to find the actual compilation command from make
echo "[*] Searching for compilation command for $OBJ_NAME..."
MAKE_OUTPUT=$(make V=1 "$OBJ_NAME" 2>&1 || true)

# Find the relevant compilation line
COMPILE_LINE=$(echo "$MAKE_OUTPUT" | grep -E " -c .*${SRC_BASENAME}" | head -n 1)


if [ -z "$COMPILE_LINE" ]; then
	echo "[!] Could not find compilation command for $OBJ_NAME"
	# Extract the source file name from the input string
	SRC_FILE=$(echo "$SRC_FILE" | awk -F'/' '{print $NF}' | cut -d'+' -f2)

	# Replace '@' with '/'
	SRC_FILE=${SRC_FILE//@//}

	# Get object file name from source
	OBJ_NAME="${SRC_FILE%.c}.o"                        # e.g., sparse-index.o

	# Clean the object file if it exists
	[ -f "$OBJ_NAME" ] && rm "$OBJ_NAME"

	# Try to find the actual compilation command from make
	echo "[*] Searching for compilation command for $OBJ_NAME..."
	MAKE_OUTPUT=$(make V=1 "$OBJ_NAME" 2>&1 || true)

	# Find the relevant compilation line
	COMPILE_LINE=$(echo "$MAKE_OUTPUT" | grep -E " -c .*${SRC_FILE}" | head -n 1)
	if [ -z "$COMPILE_LINE" ]; then
		echo "[!] Could not find compilation command for $OBJ_NAME"
		exit 1
	fi
fi

echo "[*] Found compile command:"
echo "$COMPILE_LINE"

# Modify the compile command:
# - Replace -c with -S (compile to assembly)
# - Replace -o <objfile> with -o $OUT_FILE
# - Append any extra flags

ASM_COMMAND=$(echo "$COMPILE_LINE" | sed -E \
    -e 's/-c /-S -masm=intel /' \
    -e 's/-g / /' \
	-e "s@[^ ]+\.c@$SRC_FILE@" \
    -e 's/-o [^ ]*/-o $OUT_FILE/' )

# Add extra flags, if any
if [ -n "$EXTRA_FLAGS" ]; then
    ASM_COMMAND="$ASM_COMMAND $EXTRA_FLAGS"
fi

echo "[*] Compiling to assembly..."
echo "$ASM_COMMAND"
eval "$ASM_COMMAND"

echo "[✓] Assembly written to $OUT_FILE"

