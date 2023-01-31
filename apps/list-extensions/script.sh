#!/bin/sh
set -e

# List all file extensions recursively from working directory.
# Reference: https://stackoverflow.com/a/55317141
find . -type f | rev | cut -d. -f1 | rev | tr '[:upper:]' '[:lower:]' | sort | uniq --count | sort -rn | less
