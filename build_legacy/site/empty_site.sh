#!/bin/bash

## 20220127 creates the pages files for all locales declared
## uses a templates.CSV file as the point of departure and
## creates a set of page files in different languages, also
## takes a string as parameter indicating the structure of the site

## Parameters
## DEST_FOLDER=$1
## SETUP_FOLDER=$2
## TEMPLATE_FILE=$3
## LOCALE=$4

## Defaults
DEST_FOLDER="config"
SETUP_FOLDER="config"
TEMPLATE_FILE="templates.csv"
LOCALE="en"
SITE_FOLDER="site"
PAGES_FOLDER="pages"    ## was "exercises"
OUTPUT_FILE="pages.csv" ## was "exercises.csv"

## The possible parameters are:
## ** -l: locale (default en)
## ** -c: config / setup folder (default config)
## ** -f: data file (default pages.csv)
## ** -d: destination folder
## ** -s: site subfolder where to store templates
## ** -f: pages subfolder
## ** -o: destination file for each locale

while getopts ":l:c:f:d:s:p:o:" opt; do
  case $opt in
    l) LOCALE="$OPTARG"
    ;;
    c) SETUP_FOLDER="$OPTARG"
    ;;
    f) TEMPLATE_FILE="$OPTARG"
    ;;
    d) DEST_FOLDER="$OPTARG"
    ;;
    s) SITE_FOLDER="$OPTARG"
    ;;
    p) PAGES_FOLDER="$OPTARG"
    ;;
    o) OUTPUT_FILE="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

SEPARATOR='¤'
PARAMETER_SEPARATOR=','

DATA_FILE="${SETUP_FOLDER}/${TEMPLATE_FILE}"

[ ! -f $DATA_FILE ] && { echo "$DATA_FILE file not found"; exit 99; }

OFS=$IFS
IFS=$SEPARATOR

## Create the folder for the exercises if it doesn't exist
[ ! -d "${DEST_FOLDER}" ] && mkdir ${DEST_FOLDER}
[ ! -d "${DEST_FOLDER}/${SITE_FOLDER}" ] && mkdir "${DEST_FOLDER}/${SITE_FOLDER}"
[ ! -d "${DEST_FOLDER}/${SITE_FOLDER}/${PAGES_FOLDER}" ] && mkdir "${DEST_FOLDER}/${SITE_FOLDER}/${PAGES_FOLDER}"

## Declare the variables we will use to store the data
TEMPLATE_NAME=""
TEXT_LINE=""
VALUE_LINE=""
total_fields=0

## Create the exercises file
echo -e "** CREATE PAGES FILE FOR LOCALE: ${array[0]} ** \n"
PAGES_FILE="${DEST_FOLDER}/${SITE_FOLDER}/${PAGES_FOLDER}/${LOCALE}/${OUTPUT_FILE}"

## Read all fields in a record as an array
while read -ra array; do
  if [[ "$LOCALE" == "${array[0]}" ]]; then
    ## echo -e "${array[*]}"

    ## Create the folder for the locale, which is the first field
    [ ! -d "${DEST_FOLDER}/${SITE_FOLDER}/${PAGES_FOLDER}/${array[0]}" ] && mkdir "${DEST_FOLDER}/${SITE_FOLDER}/${PAGES_FOLDER}/${array[0]}"

    for i in "${!array[@]}"
    do :

        ## The first field contains the name
        ## TODO: This is hardcoded, should be fixed later to take NAME from "# [NAME]"
        if [ "$i" -eq 2 ]; then
            TEXT_LINE="${TEXT_LINE}NUMBER${PARAMETER_SEPARATOR}NAME${PARAMETER_SEPARATOR}"
            VALUE_LINE="${VALUE_LINE}${PARAMETER_SEPARATOR}${PARAMETER_SEPARATOR}"
            let total_fields++
        fi

        ## The second field contains the title to the index
        if [ "$i" -eq 3 ]; then
            TEXT_LINE="${TEXT_LINE}INDEX${PARAMETER_SEPARATOR}"
            VALUE_LINE="${VALUE_LINE}${array[$i]}${PARAMETER_SEPARATOR}"
            let total_fields++
        fi

        ## The even lines are values, the odd ones are field names
        ## We add boolean fields for all fields, by default we activate them to true
        if [ "$i" -gt 4 ]; then
            let total_fields++

            ## Remove []
            INSERT="${array[$i]//\[/}"
            INSERT="${INSERT//\]/}"

            ## Concatenate strings
            (( i % 2 )) && VALUE_LINE="${VALUE_LINE}${array[$i]}${PARAMETER_SEPARATOR}true${PARAMETER_SEPARATOR}"
            (( (i % 2) - 1 )) && TEXT_LINE="${TEXT_LINE}${INSERT}${PARAMETER_SEPARATOR}has${INSERT}${PARAMETER_SEPARATOR}"
        fi

    done

    TEMPLATE_NAME="${TEMPLATE_NAME}${array[1]}${SEPARATOR}"
    TEXT_LINE="${TEXT_LINE}${SEPARATOR}"
    VALUE_LINE="${VALUE_LINE}${SEPARATOR}"
  fi
done < $DATA_FILE

## Print out the two lines
## Take the chance to create the file when reading a new locale
## if the file doesn't exist, yet
if [ "$total_fields" -gt 0 ]; then
    [ ! -f "${PAGES_FILE}" ] && >$PAGES_FILE || { echo -e "** Error: $PAGES_FILE exists, exiting"; exit 99; }
    echo "${TEMPLATE_NAME}" >> $PAGES_FILE
    echo "${TEXT_LINE}" >> $PAGES_FILE
    echo "${VALUE_LINE}" >> $PAGES_FILE
fi

## Done
echo -e "** Done generating exercise files"
