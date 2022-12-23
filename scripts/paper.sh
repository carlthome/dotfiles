#!/bin/sh
set -e

# List PDFs containing phrase.
query=$*
path=$HOME/Documents

echo "Searching for \"$query\"..."
pdfgrep --ignore-case --count --recursive "$query" "$path" | sed "/:0/d"
