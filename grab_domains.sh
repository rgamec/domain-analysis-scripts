#! /bin/bash
# Grab the related domains for a host on ViewDNS.info

# Fail if we don't have curl installed
if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed.' >&2
  exit 1
fi

# Fail if no host argument was passed
if [ $# -ne 1 ]; then
  echo "Usage: ./grab_domains.sh [domain]"
  exit 1
fi

# Build the URL we're going to fetch
LOCATION="https://viewdns.info/reverseip/?host=$1&t=1"

# Set a user agent for curl
USERAGENT="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)"

# Fetch the page
echo "Now fetching $LOCATION"
curl -s -A "$USERAGENT" "$LOCATION" -o tempfile.tmp

# Search the retrieved page for all related domains - save output to domains_HOST.txt in current dir.
perl -lne 'print $& while / <td>\K.*?<\/td><td/g' tempfile.tmp | sed -e "s/<\/td><td//g" > domains_$1.txt

# Display how many domains were found for this host
DOMAINSFOUND=`wc -l domains_$1.txt | awk '{print $1}'`
echo "$DOMAINSFOUND related domains were found. Output saved to domains_$1.txt"

# Removing the tmp file 
# TODO: Refactor since this isn't really necessary
rm tempfile.tmp
