#! /bin/bash
if [ -z ${1} ] || [ -z ${2} ]; then
	echo "Usage: voedl.sh <url> <filename>"
	exit 1
fi

ENCODED=$(curl -s "${1}" | rg -e 'sources\["mp4"\]\s=\s[^\(]+\(([^\)]+)\);' -r '$1')

URL=$(node -e "let input = ${ENCODED}; input = input.join('').split('').reverse().join(''); input = atob(input); console.log(input)")

curl "${URL}" -o ${2}
