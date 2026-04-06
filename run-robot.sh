#!/bin/bash

# Activate virtual environment
source venv/bin/activate

# Ensure a test file was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <test-file.robot>"
    exit 1
fi

TESTFILE="$1"
TESTNAME=$(basename "$TESTFILE" .robot)
TS=$(date +%Y-%m-%d_%H-%M-%S)
OUTDIR="results/${TESTNAME}_${TS}"

echo "Running test: $TESTFILE"
echo "Output directory: $OUTDIR"

robot --outputdir "$OUTDIR" "$TESTFILE"