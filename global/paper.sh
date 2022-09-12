# List PDFs containing phrase. Can be run as `paper constant-q transform`.
function paper {
  query=$@
  path=$HOME/Documents/Papers

  echo "Searching for \"$query\"..."
  pdfgrep --ignore-case --count --recursive "$query" $path | sed "/:0/d"
}
