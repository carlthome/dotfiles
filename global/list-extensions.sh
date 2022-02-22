# List all file extensions recursively from working directory.
# Reference: https://stackoverflow.com/a/55317141
function ls-extensions {
  find . -type f | rev | cut -d. -f1 | rev  | tr '[:upper:]' '[:lower:]' | sort | uniq --count | sort -rn | less
}
