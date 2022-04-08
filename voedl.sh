#!/bin/bash

# Print Usage
function usage() {
	echo "Usage: voedl.sh <url> [<filename>]"
}

# Print usage if first argument is --help
if [ "${1}" == "--help" ]; then
	usage
	exit 0
fi

# Check if first argument is a valid VOE.sx URL
if [[ ${1} =~ ^https?://(www\.)?voe\.sx/.+$ ]]; then
	# Write first argument to variable
	URL=${1}
else
	# Print usage and exit
	usage
	exit 1
fi

# Check if a second argument is given
if [[ -z "${2}" ]]; then
	# If not set FILENAME to default and go to the Downloads folder
	FILENAME="voedl-0.mp4"
	cd ~/Downloads
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

# Print where the file will be saved
if [[ -z "${2}" ]]; then
	echo "Downloading \"${URL}\" to \"~/Downloads/${FILENAME}\""
else
	echo "Downloading \"${URL}\" to \"${FILENAME}\""
fi

# Download the html file and use a regex to search for the encoded mp4 source (group 1 is the encoded mp4 source)
ENCODED=$(curl -s "${URL}" | rg -e 'sources\["mp4"\]\s=\s[^\(]+\(([^\)]+)\);' -r '$1')

# Decode the mp4 source with node (console.log == return in case you don't know how bash works)
SOURCE=$(node -e "let input = ${ENCODED}; input = input.join('').split('').reverse().join(''); input = atob(input); console.log(input)")

# Download the mp4 video and write it to the specified filename
curl "${SOURCE}" -o "${FILENAME}"

