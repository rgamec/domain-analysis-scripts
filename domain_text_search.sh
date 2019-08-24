#! /bin/bash
# Search for a given string across a list of domains
# Input: Search query and a text file of domains (one per line)
# Output: Generates a searchoutput_[TIMESTAMP].csv file in current dir

# Fail if we don't have curl installed
if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed.' >&2
  exit 1
fi

# Fail if incorrect arguments passed
if [ $# -ne 2 ]; then
  echo "Usage: ./domain_text_search.sh [search query] [domains list file]"
  exit 1
fi

# Sanity check that we've gotten the right arguments
INPUTFILE=$2
SEARCHTEXT=$1

# Fail if domains list file cannot be read
echo "Text to search for: $SEARCHTEXT"
echo "Input file: $INPUTFILE"
if ! [[ -f "$INPUTFILE" ]]; then
    echo "$INPUTFILE file cannot be read. Is it in the current directory?"
    exit 1
fi

# Set a fake user agent
USERAGENT="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)"

# Establish a filename to output to
OUTPUTFILE=searchoutput_`date +%Y%m%d%H%M%S`.csv

# Establish counter for stats at the end...
DOMAINSWITHTEXT=0

while IFS= read -r line
do
  echo -n "Domain being tested: $line ... "
  SEARCHCOUNT=`curl -L -s -A "$USERAGENT" "$line" | grep -c "$SEARCHTEXT"`
  echo "$line,\"$SEARCHTEXT\",$SEARCHCOUNT" >> $OUTPUTFILE
  echo "$SEARCHCOUNT occurrences found."
  
  if [ "$SEARCHCOUNT" -ne "0" ]; then
    DOMAINSWITHTEXT=$((DOMAINSWITHTEXT+1))
  fi

  sleep 3
done < "$INPUTFILE"

# Some final output with stats
echo "$DOMAINSWITHTEXT domains were found to contain the text \"$SEARCHTEXT\". CSV output saved to $OUTPUTFILE."
