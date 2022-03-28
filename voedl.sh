#! /bin/bash

# Check if two arguments were passed
if [ -z ${1} ] || [ -z ${2} ]; then
	# Print usage and exit if not
	echo "Usage: voedl.sh <url> <filename>"
	exit 1
fi

# Download the html file and search for the encoded mp4 source
ENCODED=$(curl -s "${1}" | rg -e 'sources\["mp4"\]\s=\s[^\(]+\(([^\)]+)\);' -r '$1')

# Decode the mp4 source with node
URL=$(node -e "let input = ${ENCODED}; input = input.join('').split('').reverse().join(''); input = atob(input); console.log(input)")

# Download the mp4 video and write it to the specified filename
curl "${URL}" -o ${2}

