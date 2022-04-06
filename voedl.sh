#!/bin/bash

# Check if at least one argument is given
if [[ -z "${1}" ]]; then
	# If not print usage and exit else continue
	echo "Usage: voedl.sh <url> <filename>"
	exit 1
fi

# Check if a second argument is given
if [[ -z "${2}" ]]; then
	# If not set FILENAME to default
	FILENAME="voedl-0.mp4"
elif [[ "${2}" == *.mp4 ]]; then
	# If it is a mp4 file set FILENAME to the given filename
	FILENAME="${2}"
else
	# If it is not a mp4 file set FILENAME to the given filename with .mp4 extension
	FILENAME="${2}.mp4"
fi

# Check if the file already exists
if [[ -f ${FILENAME} ]]; then
	# If it does print a warning and exit if the second argument is set
	if [[ -n "${2}" ]]; then
		echo "File ${FILENAME} already exists"
		exit 1
	fi

	# If the second argument is not set increment the number in the filename until it is unique
	while [[ -f ${FILENAME} ]]; do
		# Remove .mp4 extension because it contains a number
		FILENAME=${FILENAME%.mp4}
		# Get the number from the filename
		FILENAME=${FILENAME//[!0-9]/}
		# Create a new filename with the incremented number
		FILENAME="voedl-$((${FILENAME}+1)).mp4"
	done
fi

echo "Downloading \"${1}\" to \"${FILENAME}\""

# Download the html file and use a regex to search for the encoded mp4 source (group 1 is the encoded mp4 source)
ENCODED=$(curl -s "${1}" | rg -e 'sources\["mp4"\]\s=\s[^\(]+\(([^\)]+)\);' -r '$1')

# Decode the mp4 source with node (console.log == return in case you don't know how bash works)
URL=$(node -e "let input = ${ENCODED}; input = input.join('').split('').reverse().join(''); input = atob(input); console.log(input)")

# Download the mp4 video and write it to the specified filename
curl "${URL}" -o "${FILENAME}"

