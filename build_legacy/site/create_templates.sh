#!/bin/bash

## 20220109 creates the templates for a course
## uses a CSV file as the point of departure and creates a set of
## template files in as many languages as records in the file

## Parameters
## DEST_FOLDER=$1
## SETUP_FOLDER=$2
## TEMPLATE_FILE=$3

## Defaults
DEST_FOLDER="config"
SETUP_FOLDER="config"
TEMPLATE_FILE="templates.csv"
PAGES_FOLDER="pages"    ## was "exercises"

## The possible parameters are:
## ** -d: destination folder
## ** -c: config / setup folder
## ** -f: data file
## ** -p: pages folder

while getopts ":d:c:f:p:" opt; do
  case $opt in
    d) DEST_FOLDER="$OPTARG"
    ;;
    c) SETUP_FOLDER="$OPTARG"
    ;;
    f) TEMPLATE_FILE="$OPTARG"
    ;;
    p) PAGES_FOLDER="$OPTARG"
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

DATA_FILE="${SETUP_FOLDER}/${TEMPLATE_FILE}"
SEPARATOR='¤'

[ ! -f $DATA_FILE ] && { echo "$DATA_FILE file not found"; exit 99; }

OFS=$IFS
IFS=$SEPARATOR

## Create the folder for the templates if it doesn't exist
[ ! -d "${DEST_FOLDER}" ] && mkdir ${DEST_FOLDER}
[ ! -d "${DEST_FOLDER}/templates" ] && mkdir "${DEST_FOLDER}/templates"
[ ! -d "${DEST_FOLDER}/templates/${PAGES_FOLDER}" ] && mkdir "${DEST_FOLDER}/templates/${PAGES_FOLDER}"

## Read all fields in a record as an array
while read -ra array; do

    ## Create the folder for the locale, which is the first field
    [ ! -d "${DEST_FOLDER}/templates/${PAGES_FOLDER}/${array[0]}" ] && mkdir "${DEST_FOLDER}/templates/${PAGES_FOLDER}/${array[0]}"

    ## Create the template file
    echo -e "** CREATE TEMPLATE FOR LOCALE: ${array[0]} ** \n"
    TEMPLATE_FILE="${DEST_FOLDER}/templates/${PAGES_FOLDER}/${array[0]}/template_${array[1]}.md"
    ##echo "" > $TEMPLATE_FILE

    for i in "${!array[@]}"
    do :
        if [ "$i" -gt 1 ]; then
            echo "${array[$i]}" >> $TEMPLATE_FILE
            echo "" >> $TEMPLATE_FILE
        else
            >$TEMPLATE_FILE
        fi
    done

done < $DATA_FILE

## Done
echo -e "** Done generating templates"
