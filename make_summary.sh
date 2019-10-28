#!/bin/bash

SPACING="  "
BASE="src"
RETCODE=$((0))
SUMMARY="${BASE}/SUMMARY.md"

lint_check() {
  CHECKFILE=$@

  # Check that the filename does not contain spaces
  if [[ $CHECKFILE = *" "* ]]; then
    echo "ERROR: File path [${CHECKFILE}] contains spaces.  This is not allowed, please replace with underscores '_'"
    RETCODE=$((1))
  fi

  # Check that the first line of the file starts with a '#', otherwise throw an error
  # Otherwise, set the TITLE to the string that follows

  MDTOK=`head -n1 "${CHECKFILE}" | cut -f1 -d ' '`
  if [ "${MDTOK}" != "#" ]; then
    echo "ERROR: Summary generation failed because the first line of '$CHECKFILE' is not in the format '# <title text>'"
    RETCODE=$((1))
  fi
  TITLE=`head -n1 "${CHECKFILE}" | cut -f2- -d ' '`
}

make_indent() {
  INDENT=''
  DEPTH=$1

  if [[ $((DEPTH-1)) -gt 0 ]]; then
    i=$((0))
    while [ $i -lt $((DEPTH-1)) ]
    do
      INDENT="${INDENT}${SPACING}" 
      i=$((i+1))
    done
  fi
}

parse_files() {
  ROOT=$@
  DEPTH=$((`echo ${ROOT} | tr -cd '/' | wc -c`))
  make_indent $DEPTH

  if [[ $DEPTH -gt 0 ]]; then
    if [ ! -f "${ROOT}/HEADER.md" ]; then
      echo "ERROR: Summary generation failed because '${ROOT}/HEADER.md' does not exist"
      RETCODE=$((1))
    else
      lint_check "${ROOT}/HEADER.md"
      SUMMARY_TEXT=$(echo "${ROOT}/HEADER.md" | cut -f2- -d '/')
      echo "${INDENT}- [${TITLE}](${SUMMARY_TEXT})" >> ${SUMMARY}
    fi
  else
    echo -e '# Summary\n' > ${SUMMARY}
  fi 

  make_indent $((DEPTH+1))
  while IFS= read -r FILE; do
    lint_check ${FILE}
    SUMMARY_TEXT=$(echo "${FILE}" | cut -f2- -d '/')
    echo "${INDENT}- [${TITLE}](${SUMMARY_TEXT})" >> ${SUMMARY}
  done < <( find "$ROOT" -name "*.md" -maxdepth 1 -mindepth 1 -type f | grep -Ev 'SUMMARY.md|HEADER.md' | sort )
}

parse_directories() {
  ROOT=$@  
  parse_files "$ROOT"
  while IFS= read -r DIRECTORY; do
    parse_directories $DIRECTORY 
  done < <( find "$ROOT" -maxdepth 1 -mindepth 1 -type d | sort )
}

parse_directories $BASE 
echo "${BASE}/SUMMARY.md built successfully!" 
