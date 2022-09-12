# List PDFs containing phrase.
function paper {
  query=$@
  path=$HOME/Documents/Papers

  echo "Searching for \"$query\"..."
  pdfgrep --ignore-case --count --recursive "$query" $path | sed "/:0/d"
}
